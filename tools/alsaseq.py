"""Minimal pure-ioctl ALSA sequencer client (no libasound needed).

Used by fm1_ota.py to talk to the FM-1's kernel MIDI port. Layouts verified
against /usr/include/sound/asequencer.h.
"""
import fcntl, os, select, struct, time

_IOC_WRITE = 1
_IOC_READ = 2
def _IOWR(t, n, sz): return ((_IOC_READ | _IOC_WRITE) << 30) | (sz << 16) | (ord(t) << 8) | n
def _IOW(t, n, sz):  return (_IOC_WRITE << 30) | (sz << 16) | (ord(t) << 8) | n
def _IOR(t, n, sz):  return (_IOC_READ << 30) | (sz << 16) | (ord(t) << 8) | n

CLIENT_ID = _IOR('S', 0x01, 4)
SET_CLIENT_INFO = _IOW('S', 0x11, 188)
CREATE_PORT = _IOWR('S', 0x20, 168)
SUBSCRIBE_PORT = _IOW('S', 0x30, 80)
QUERY_NEXT_CLIENT = _IOWR('S', 0x51, 188)
QUERY_NEXT_PORT = _IOWR('S', 0x52, 168)

EV_SYSEX = 130
EV_LENGTH_VARIABLE = 4
CAP_READ, CAP_WRITE, CAP_SUBS_READ, CAP_SUBS_WRITE = 1, 2, 0x20, 0x40
TYPE_MIDI_GENERIC = 2


def _client_info(client=-1, name=b""):
    b = bytearray(188)
    struct.pack_into('<ii', b, 0, client, 0)
    b[8:8 + 64] = (name + bytes(64))[:64]
    return b


def _port_info(client=-1, port=-1, caps=0, name=b""):
    b = bytearray(168)
    b[0] = client & 0xFF if client >= 0 else 0xFF
    b[1] = port & 0xFF if port >= 0 else 0xFF
    b[2:66] = (name + bytes(64))[:64]
    struct.pack_into('<II', b, 66, caps, TYPE_MIDI_GENERIC)
    return b


def _subscription(sender, dest):
    b = bytearray(80)
    b[0], b[1] = sender
    b[2], b[3] = dest
    return bytes(b)


class SeqClient:
    def __init__(self, name=b"fm1-ota"):
        self.fd = os.open('/dev/snd/seq', os.O_RDWR)
        self.client = struct.unpack('<i', fcntl.ioctl(self.fd, CLIENT_ID, struct.pack('<i', 0)))[0]
        pi = fcntl.ioctl(self.fd, CREATE_PORT,
                         bytes(_port_info(self.client, 0xFF,
                                          CAP_READ | CAP_WRITE | CAP_SUBS_READ | CAP_SUBS_WRITE,
                                          name)))
        self.port = pi[1]
        self.rbuf = bytearray()

    def find_port(self, client_name_substr, port_name_substr=b""):
        ci = _client_info(-1)
        while True:
            try:
                fcntl.ioctl(self.fd, QUERY_NEXT_CLIENT, ci, True)
            except OSError:
                return None
            client = struct.unpack('<i', ci[0:4])[0]
            if client < 0:
                return None
            cname = bytes(ci[8:72]).split(b'\0')[0]
            pi = _port_info(client, 0xFF)
            while True:
                try:
                    fcntl.ioctl(self.fd, QUERY_NEXT_PORT, pi, True)
                except OSError:
                    break
                pclient, pport = pi[0], pi[1]
                if pclient != client or pport == 0xFF:
                    break
                pname = bytes(pi[2:66]).split(b'\0')[0]
                if client_name_substr in cname and port_name_substr in pname:
                    return (client, pport)
                pi[0], pi[1] = client, pport

    def subscribe_from(self, addr):
        fcntl.ioctl(self.fd, SUBSCRIBE_PORT, _subscription(addr, (self.client, self.port)))

    def subscribe_to(self, addr):
        """Write subscription me->addr; required before sending to a hardware port."""
        fcntl.ioctl(self.fd, SUBSCRIBE_PORT, _subscription((self.client, self.port), addr))

    def send(self, data, dest):
        hdr = struct.pack('<BBBB8sBBBB12s', EV_SYSEX, EV_LENGTH_VARIABLE, 0, 253,
                          bytes(8), self.client, self.port, dest[0], dest[1],
                          struct.pack('<I8x', len(data)))
        pad = (-len(data)) % 4
        os.write(self.fd, hdr + data + bytes(pad))

    def recv(self, timeout):
        end = time.time() + timeout
        out = []
        while True:
            left = end - time.time()
            if left <= 0:
                return out
            r, _, _ = select.select([self.fd], [], [], left)
            if not r:
                return out
            d = os.read(self.fd, 65536)
            if not d:
                return out
            self.rbuf += d
            while len(self.rbuf) >= 28:
                typ, flags = self.rbuf[0], self.rbuf[1]
                if flags & EV_LENGTH_VARIABLE:
                    ln = struct.unpack('<I', self.rbuf[16:20])[0]
                    total = 28 + ln + ((-ln) % 4)
                    if len(self.rbuf) < total:
                        break
                    if typ == EV_SYSEX:
                        out.append(bytes(self.rbuf[28:28 + ln]))
                    del self.rbuf[:total]
                else:
                    del self.rbuf[:28]

    def close(self):
        try:
            os.close(self.fd)
        except OSError:
            pass
