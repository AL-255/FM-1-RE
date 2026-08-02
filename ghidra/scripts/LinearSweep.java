import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.mem.*;
import ghidra.app.cmd.disassemble.DisassembleCommand;
import java.io.*;

public class LinearSweep extends GhidraScript {
    public void run() throws Exception {
        Memory mem = currentProgram.getMemory();
        MemoryBlock blk = mem.getBlocks()[0];
        Address start = blk.getStart(), end = blk.getEnd();
        // Linear sweep: try to disassemble at every 2-byte boundary not already code
        long decoded = 0;
        Address a = start;
        Listing l = currentProgram.getListing();
        while (a.compareTo(end) < 0) {
            if (l.getInstructionAt(a) == null && l.getDefinedDataAt(a) == null) {
                DisassembleCommand c = new DisassembleCommand(a, null, false);
                c.applyTo(currentProgram, monitor);
            }
            a = a.add(2);
            if ((a.getOffset() & 0x3fff) == 0) monitor.setMessage("sweep " + a);
        }
        InstructionIterator it = l.getInstructions(true);
        String out = System.getenv("ASM_OUT");
        PrintWriter pw = new PrintWriter(new BufferedWriter(new FileWriter(out)));
        while (it.hasNext()) {
            Instruction ins = it.next();
            pw.println(String.format("%08x  %-24s  %s", ins.getAddress().getOffset(),
                bytesHex(ins), ins.toString()));
            decoded++;
        }
        pw.close();
        println("STATS linear_instructions=" + decoded);
    }
    String bytesHex(Instruction ins) throws Exception {
        byte[] b = ins.getBytes(); StringBuilder s = new StringBuilder();
        for (byte x : b) s.append(String.format("%02x", x & 0xff));
        return s.toString();
    }
}
