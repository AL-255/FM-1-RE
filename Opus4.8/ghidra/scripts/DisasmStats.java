import ghidra.app.script.GhidraScript;
import ghidra.program.model.listing.*;
import ghidra.program.model.address.*;

public class DisasmStats extends GhidraScript {
    public void run() throws Exception {
        Listing l = currentProgram.getListing();
        long insn = 0, bad = 0;
        InstructionIterator it = l.getInstructions(true);
        while (it.hasNext()) { it.next(); insn++; }
        // count bad/undefined
        long funcs = currentProgram.getFunctionManager().getFunctionCount();
        println("STATS lang=" + currentProgram.getLanguageID());
        println("STATS instructions=" + insn);
        println("STATS functions=" + funcs);
    }
}
