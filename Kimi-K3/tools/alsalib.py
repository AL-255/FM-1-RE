"""ALSA sequencer access via libasound (ctypes) — used by fm1_ota.py.

Mirrors what RtMidi does: open the sequencer, create a port, connect to the
FM-1's kernel MIDI port both ways, send/recv raw SysEx byte streams.
Variable-length events carry their payload via data.ext.ptr (see alsa-lib).
"""
import ctypes, struct, select

lib = ctypes.CDLL("libasound.so.2")

lib.snd_seq_open.argtypes = [ctypes.POINTER(ctypes.c_void_p), ctypes.c_char_p,
                             ctypes.c_int, ctypes.c_int]
lib.snd_seq_client_id.argtypes = [ctypes.c_void_p]
lib.snd_seq_create_simple_port.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                           ctypes.c_uint, ctypes.c_uint]
lib.snd_seq_connect_from.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int]
lib.snd_seq_connect_to.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int]
lib.snd_seq_event_input.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_void_p)]
lib.snd_midi_event_new.argtypes = [ctypes.c_size_t, ctypes.POINTER(ctypes.c_void_p)]
lib.snd_midi_event_encode.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_long, ctypes.c_void_p]
lib.snd_midi_event_free.argtypes = [ctypes.c_void_p]
lib.snd_seq_event_output.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
lib.snd_seq_event_output_buffer.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
lib.snd_seq_drain_output.argtypes = [ctypes.c_void_p]
lib.snd_seq_free_event.argtypes = [ctypes.c_void_p]
lib.snd_seq_close.argtypes = [ctypes.c_void_p]
lib.snd_seq_poll_descriptors_count.argtypes = [ctypes.c_void_p, ctypes.c_short]
lib.snd_seq_poll_descriptors.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_uint, ctypes.c_short]

SND_SEQ_OPEN_DUPLEX = 3
CAP_READ, CAP_WRITE, CAP_SUBS_READ, CAP_SUBS_WRITE = 1, 2, 32, 64
TYPE_MIDI_GENERIC = 2
EV_SYSEX = 130
EV_LENGTH_VARIABLE = 4
QUEUE_DIRECT = 253

# struct snd_seq_event (28 bytes):
#   0 type, 1 flags, 2 tag, 3 queue, 4..11 time, 12 src.client, 13 src.port,
#  14 dst.client, 15 dst.port, 16..27 data union (ext: u32 len @16, u64 ptr @20? )
# NOTE: snd_seq_ev_ext = { u32 len; void *ptr; } -> len at 16, ptr at 20
# (the union is 12 bytes; ptr is 64-bit but stored unaligned per alsa headers)


class MidiLink:
    def __init__(self, client_name=b"fm1-ota"):
        self.seq = ctypes.c_void_p()
        rc = lib.snd_seq_open(ctypes.byref(self.seq), b"default", SND_SEQ_OPEN_DUPLEX, 0)
        assert rc == 0, f"snd_seq_open: {rc}"
        self.client = lib.snd_seq_client_id(self.seq)
        self.port = lib.snd_seq_create_simple_port(
            self.seq, client_name,
            CAP_READ | CAP_WRITE | CAP_SUBS_READ | CAP_SUBS_WRITE,
            TYPE_MIDI_GENERIC)
        assert self.port >= 0, f"create_simple_port: {self.port}"
        self._keep = None

    def connect(self, addr):
        rc1 = lib.snd_seq_connect_from(self.seq, self.port, addr[0], addr[1])
        rc2 = lib.snd_seq_connect_to(self.seq, self.port, addr[0], addr[1])
        assert rc1 == 0 and rc2 == 0, f"connect: {rc1} {rc2}"
        self.dest = addr

    def fileno(self):
        n = lib.snd_seq_poll_descriptors_count(self.seq, 1)
        arr = (ctypes.c_int * n)()
        lib.snd_seq_poll_descriptors(self.seq, arr, n, 1)
        return arr[0]

    def send(self, data):
        if not hasattr(self, '_mev'):
            self._mev = ctypes.c_void_p()
            rc = lib.snd_midi_event_new(65536, ctypes.byref(self._mev))
            assert rc == 0
        ev = bytearray(28)
        ev[3] = QUEUE_DIRECT            # snd_seq_ev_set_direct
        ev[12] = self.client            # snd_seq_ev_set_source(client, port)
        ev[13] = self.port
        ev[14] = self.dest[0]           # snd_seq_ev_set_dest
        ev[15] = self.dest[1]
        evbuf = ctypes.create_string_buffer(bytes(ev), 28)
        rc = lib.snd_midi_event_encode(self._mev, bytes(data), len(data), evbuf)
        assert rc >= 0, f"midi_event_encode: {rc}"
        rc = lib.snd_seq_event_output(self.seq, evbuf)
        assert rc >= 0, f"event_output: {rc}"
        rc = lib.snd_seq_drain_output(self.seq)
        assert rc == 0, f"drain_output: {rc}"

    def recv_sysex(self, timeout_ms=1000):
        r, _, _ = select.select([self.fileno()], [], [], timeout_ms / 1000)
        if not r:
            return None
        pev = ctypes.c_void_p()
        rc = lib.snd_seq_event_input(self.seq, ctypes.byref(pev))
        if rc < 0 or not pev:
            return None
        raw = ctypes.string_at(pev.value, 28)
        if raw[0] != EV_SYSEX:
            lib.snd_seq_free_event(pev)
            return b""
        ln = struct.unpack('<I', raw[16:20])[0]
        ptr = struct.unpack('<Q', raw[20:28])[0]
        payload = ctypes.string_at(ptr, ln)
        lib.snd_seq_free_event(pev)
        return payload

    def close(self):
        try:
            lib.snd_seq_close(self.seq)
        except Exception:
            pass
