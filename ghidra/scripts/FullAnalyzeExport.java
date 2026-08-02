import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.*;
import ghidra.app.decompiler.*;
import java.io.*;

public class FullAnalyzeExport extends GhidraScript {
    public void run() throws Exception {
        Address entry = toAddr(0x020000A0L);
        createFunction(entry, "entry");
        analyzeAll(currentProgram);
        FunctionManager fm = currentProgram.getFunctionManager();
        long funcs = fm.getFunctionCount();
        Listing l = currentProgram.getListing();
        long insn = 0; InstructionIterator it = l.getInstructions(true);
        while (it.hasNext()) { it.next(); insn++; }
        long errs = 0; var bm = currentProgram.getBookmarkManager();
        var bit = bm.getBookmarksIterator("Error");
        while (bit.hasNext()) { bit.next(); errs++; }
        println("STATS instructions=" + insn);
        println("STATS functions=" + funcs);
        println("STATS errors=" + errs);
        // Export decompiled C for all functions
        String out = System.getenv("DECOMP_OUT");
        if (out == null) out = "/tmp/decomp.c";
        DecompInterface di = new DecompInterface();
        di.openProgram(currentProgram);
        PrintWriter pw = new PrintWriter(new FileWriter(out));
        int ok = 0, fail = 0;
        FunctionIterator fit = fm.getFunctions(true);
        while (fit.hasNext()) {
            Function f = fit.next();
            try {
                DecompileResults r = di.decompileFunction(f, 60, monitor);
                if (r != null && r.decompileCompleted() && r.getDecompiledFunction()!=null) {
                    pw.println(r.getDecompiledFunction().getC());
                    ok++;
                } else { fail++; }
            } catch (Exception e) { fail++; }
        }
        pw.close();
        println("STATS decompiled_ok=" + ok + " decompiled_fail=" + fail);
    }
}
