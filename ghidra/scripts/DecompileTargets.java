import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileResults;
import ghidra.app.script.GhidraScript;
import ghidra.app.cmd.disassemble.DisassembleCommand;
import ghidra.app.cmd.function.CreateFunctionCmd;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Function;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.PrintWriter;

public class DecompileTargets extends GhidraScript {
    public void run() throws Exception {
        String targetsPath = System.getenv("TARGETS");
        String outputPath = System.getenv("DECOMP_OUT");
        if (targetsPath == null || outputPath == null) {
            throw new IllegalArgumentException("TARGETS and DECOMP_OUT are required");
        }

        DecompInterface decompiler = new DecompInterface();
        decompiler.openProgram(currentProgram);
        int ok = 0;
        int failed = 0;

        try (BufferedReader reader = new BufferedReader(new FileReader(targetsPath));
             PrintWriter output = new PrintWriter(new FileWriter(outputPath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) {
                    continue;
                }
                String[] fields = line.split("\\s+", 2);
                long value = Long.decode(fields[0]);
                String requestedName = fields.length == 2 ? fields[1] : null;
                Address address = toAddr(value);

                Function function = getFunctionAt(address);
                if (function == null) {
                    new DisassembleCommand(address, null, true).applyTo(currentProgram, monitor);
                    new CreateFunctionCmd(address).applyTo(currentProgram, monitor);
                    function = getFunctionAt(address);
                }
                if (function == null) {
                    output.println("/* failed to create function at " + address + " */");
                    failed++;
                    continue;
                }
                if (requestedName != null && !requestedName.isEmpty()) {
                    function.setName(requestedName, ghidra.program.model.symbol.SourceType.USER_DEFINED);
                }

                DecompileResults result = decompiler.decompileFunction(function, 60, monitor);
                if (result != null && result.decompileCompleted()
                        && result.getDecompiledFunction() != null) {
                    output.printf("/* address: %s */%n", address);
                    output.println(result.getDecompiledFunction().getC());
                    ok++;
                } else {
                    output.println("/* decompilation failed at " + address + " */");
                    failed++;
                }
            }
        }

        println("STATS decompiled_ok=" + ok + " decompiled_fail=" + failed);
    }
}
