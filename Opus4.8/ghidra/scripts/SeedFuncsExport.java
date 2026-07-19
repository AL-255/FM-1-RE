import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.*;
import ghidra.program.model.listing.*;
import ghidra.app.cmd.disassemble.DisassembleCommand;
import ghidra.app.cmd.function.CreateFunctionCmd;
import java.io.*;
import java.util.*;

public class SeedFuncsExport extends GhidraScript {
    public void run() throws Exception {
        String tf = System.getenv("TARGETS");
        List<Long> targets = new ArrayList<>();
        BufferedReader br = new BufferedReader(new FileReader(tf));
        String s;
        while ((s=br.readLine())!=null){ s=s.trim(); if(!s.isEmpty()) targets.add(Long.parseLong(s,16)); }
        br.close();
        // Force-disassemble at each target (corrects alignment), then create function
        for (long t : targets) {
            Address a = toAddr(t);
            DisassembleCommand dc = new DisassembleCommand(a, null, true);
            dc.applyTo(currentProgram, monitor);
        }
        int created=0;
        for (long t : targets) {
            Address a = toAddr(t);
            if (getFunctionAt(a)!=null){ created++; continue; }
            CreateFunctionCmd cf = new CreateFunctionCmd(a);
            if (cf.applyTo(currentProgram, monitor)) created++;
        }
        FunctionManager fm = currentProgram.getFunctionManager();
        // Export function table
        String fo = System.getenv("FUNC_CSV");
        PrintWriter pw = new PrintWriter(new FileWriter(fo));
        pw.println("address,name,body_bytes,instr_count");
        FunctionIterator fit = fm.getFunctions(true);
        int nfun=0;
        while (fit.hasNext()){
            Function f = fit.next();
            long body = f.getBody().getNumAddresses();
            long ic=0;
            InstructionIterator ii = currentProgram.getListing().getInstructions(f.getBody(), true);
            while (ii.hasNext()){ ii.next(); ic++; }
            pw.println(String.format("0x%08x,%s,%d,%d", f.getEntryPoint().getOffset(), f.getName(), body, ic));
            nfun++;
        }
        pw.close();
        println("STATS functions_created="+created+" total_functions="+nfun);
    }
}
