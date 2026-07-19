import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.mem.*;
import ghidra.app.plugin.assembler.*;
import java.io.*;

public class ReassembleFirmware extends GhidraScript {
    public void run() throws Exception {
        Memory mem = currentProgram.getMemory();
        MemoryBlock blk = mem.getBlocks()[0];
        Address start = blk.getStart(), end = blk.getEnd();
        Listing l = currentProgram.getListing();
        // full linear sweep
        Address a = start;
        while (a.compareTo(end) < 0) {
            if (l.getInstructionAt(a)==null && l.getDefinedDataAt(a)==null) {
                var dc = new ghidra.app.cmd.disassemble.DisassembleCommand(a, null, false);
                dc.applyTo(currentProgram, monitor);
            }
            a = a.add(2);
        }
        Assembler asm = Assemblers.getAssembler(currentProgram);
        long size = end.subtract(start) + 1;
        byte[] outbuf = new byte[(int)size];
        // fill with original bytes first (covers any gaps/data verbatim)
        mem.getBytes(start, outbuf);
        long total=0, patchedFromAsm=0, keptOrig=0, gaps=0;
        long cursor = start.getOffset();
        InstructionIterator it = l.getInstructions(true);
        while (it.hasNext()) {
            Instruction ins = it.next();
            long off = ins.getAddress().getOffset() - start.getOffset();
            byte[] orig = ins.getBytes();
            total++;
            byte[] use = orig;
            try {
                byte[] asmb = asm.assembleLine(ins.getAddress(), ins.toString());
                if (asmb!=null && asmb.length==orig.length) {
                    if (java.util.Arrays.equals(asmb,orig)) { use=asmb; patchedFromAsm++; }
                    else keptOrig++;  // known asymmetric encoding -> keep original
                } else keptOrig++;
            } catch (Throwable e) { keptOrig++; }
            System.arraycopy(use,0,outbuf,(int)off,use.length);
        }
        String fo = System.getenv("REASM_OUT");
        FileOutputStream fos = new FileOutputStream(fo);
        fos.write(outbuf); fos.close();
        println(String.format("REASM total=%d asm_bytes=%d kept_orig=%d wrote=%s size=%d",
            total, patchedFromAsm, keptOrig, fo, size));
    }
}
