import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileResults;
import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.data.StringDataInstance;
import ghidra.program.model.listing.Data;
import ghidra.program.model.listing.DataIterator;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.FunctionManager;
import ghidra.program.model.symbol.Reference;
import ghidra.program.model.symbol.ReferenceIterator;

import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.LinkedHashMap;
import java.util.Map;

public class DecompileOtaWorker extends GhidraScript {
    private static final String[] NEEDLES = {
        "OtaUpgradeWorker::startUpgrade() called",
        "Request received - FlashType",
        "Sent verification success response",
        "Upgrade completed signal received",
        "Data sent successfully",
        "success"
    };

    private static final long[] FUNCTIONS = {
        0x140011b50L, // open/probe + handshake
        0x140016c90L, // receive and parse a device read request
        0x140017a30L, // build and send a data/success response
        0x140017b20L, // construct decoded response body and checksum
        0x140017cb0L, // verify decoded request checksum
        0x140018060L, // receive and unpack 7-bit SysEx
        0x140018140L, // pack and send 7-bit SysEx
        0x140018250L, // close MIDI transport
        0x140018360L  // send raw SysEx (upgrade command)
    };

    @Override
    public void run() throws Exception {
        analyzeAll(currentProgram);

        FunctionManager functions = currentProgram.getFunctionManager();
        Map<Address, Function> selected = new LinkedHashMap<>();
        DataIterator data = currentProgram.getListing().getDefinedData(true);
        while (data.hasNext()) {
            Data item = data.next();
            StringDataInstance string = StringDataInstance.getStringDataInstance(item);
            if (string == null) {
                continue;
            }
            String value = string.getStringValue();
            if (value == null || !matches(value)) {
                continue;
            }
            ReferenceIterator references = currentProgram.getReferenceManager()
                .getReferencesTo(item.getAddress());
            while (references.hasNext()) {
                Reference reference = references.next();
                Function function = functions.getFunctionContaining(reference.getFromAddress());
                if (function != null) {
                    selected.put(function.getEntryPoint(), function);
                }
            }
        }
        for (long address : FUNCTIONS) {
            Function function = functions.getFunctionAt(toAddr(address));
            if (function != null) {
                selected.put(function.getEntryPoint(), function);
            }
        }

        String output = System.getenv("DECOMP_OUT");
        if (output == null || output.isEmpty()) {
            output = "/tmp/fm1-updater-ota.c";
        }
        DecompInterface decompiler = new DecompInterface();
        decompiler.openProgram(currentProgram);
        try (PrintWriter writer = new PrintWriter(new FileWriter(output))) {
            for (Function function : selected.values()) {
                writer.printf("/* %s @ %s */%n", function.getName(), function.getEntryPoint());
                DecompileResults result = decompiler.decompileFunction(function, 120, monitor);
                if (result.decompileCompleted() && result.getDecompiledFunction() != null) {
                    writer.println(result.getDecompiledFunction().getC());
                } else {
                    writer.println("/* decompilation failed */");
                }
            }
        }
        println("Exported " + selected.size() + " OTA functions to " + output);
    }

    private boolean matches(String value) {
        for (String needle : NEEDLES) {
            if (value.contains(needle)) {
                return true;
            }
        }
        return false;
    }
}
