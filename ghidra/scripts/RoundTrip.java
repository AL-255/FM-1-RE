import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.*;
import ghidra.program.model.listing.*;
import ghidra.app.plugin.assembler.*;
import ghidra.program.model.mem.*;
import java.io.*;

public class RoundTrip extends GhidraScript {
    public void run() throws Exception {
        Address entry = toAddr(0x020000A0L);
        // Linear sweep first so we have instructions to test
        ghidra.app.cmd.disassemble.DisassembleCommand dc;
        Memory mem = currentProgram.getMemory();
        MemoryBlock blk = mem.getBlocks()[0];
        Address a = blk.getStart(), end = blk.getEnd();
        Listing l = currentProgram.getListing();
        while (a.compareTo(end) < 0) {
            if (l.getInstructionAt(a)==null && l.getDefinedDataAt(a)==null) {
                dc = new ghidra.app.cmd.disassemble.DisassembleCommand(a, null, false);
                dc.applyTo(currentProgram, monitor);
            }
            a = a.add(2);
        }
        Assembler asm = Assemblers.getAssembler(currentProgram);
        long total=0, match=0, mismatch=0, err=0;
        PrintWriter mm = new PrintWriter(new FileWriter(System.getenv("MISMATCH_OUT")));
        InstructionIterator it = l.getInstructions(true);
        while (it.hasNext()) {
            Instruction ins = it.next();
            total++;
            byte[] orig = ins.getBytes();
            String text = ins.toString();
            try {
                byte[] asmb = asm.assembleLine(ins.getAddress(), text);
                if (asmb!=null && java.util.Arrays.equals(asmb, orig)) match++;
                else {
                    mismatch++;
                    if (mismatch<=400) mm.println(String.format("MISMATCH %08x  text='%s'  orig=%s asm=%s",
                        ins.getAddress().getOffset(), text, hex(orig), hex(asmb)));
                }
            } catch (Throwable e) {
                err++;
                if (err<=400) mm.println(String.format("ERR      %08x  text='%s'  orig=%s  (%s)",
                    ins.getAddress().getOffset(), text, hex(orig), e.getClass().getSimpleName()));
            }
            if ((total % 20000)==0) println("progress "+total);
        }
        mm.close();
        println(String.format("ROUNDTRIP total=%d match=%d mismatch=%d err=%d  match_pct=%.2f",
            total, match, mismatch, err, 100.0*match/total));
    }
    String hex(byte[] b){ if(b==null) return "null"; StringBuilder s=new StringBuilder(); for(byte x:b) s.append(String.format("%02x",x&0xff)); return s.toString(); }
}
