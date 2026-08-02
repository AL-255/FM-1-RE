import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.*;
import ghidra.program.model.symbol.SourceType;
import ghidra.app.cmd.disassemble.DisassembleCommand;

public class SeedAndStats extends GhidraScript {
    public void run() throws Exception {
        Address entry = toAddr(0x020000A0L);
        DisassembleCommand cmd = new DisassembleCommand(entry, null, true);
        cmd.applyTo(currentProgram, monitor);
        createFunction(entry, "entry");
        // Run auto analysis to follow flow
        analyzeAll(currentProgram);
        Listing l = currentProgram.getListing();
        long insn = 0;
        InstructionIterator it = l.getInstructions(true);
        while (it.hasNext()) { it.next(); insn++; }
        long funcs = currentProgram.getFunctionManager().getFunctionCount();
        // count bad instruction (error) bookmarks
        long errs = 0;
        var bm = currentProgram.getBookmarkManager();
        var bit = bm.getBookmarksIterator("Error");
        while (bit.hasNext()) { bit.next(); errs++; }
        println("STATS lang=" + currentProgram.getLanguageID());
        println("STATS instructions=" + insn);
        println("STATS functions=" + funcs);
        println("STATS errors=" + errs);
    }
}
