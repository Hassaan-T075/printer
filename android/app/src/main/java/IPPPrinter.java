import javax.print.*;
import javax.print.attribute.*;
import javax.print.attribute.standard.*;
import java.io.*;

public class IPPPrinter {
    private String printerUrl; // Example: "http://192.168.1.100:631/ipp/print"

    public IPPPrinter(String printerUrl) {
        this.printerUrl = printerUrl;
    }

    public boolean printPDF(String filePath) {
        try {
            FileInputStream inputStream = new FileInputStream(new File(filePath));
            DocFlavor flavor = DocFlavor.INPUT_STREAM.PDF;
            PrintRequestAttributeSet attrs = new HashPrintRequestAttributeSet();
            attrs.add(new Copies(1)); // Set number of copies
            attrs.add(PrintQuality.HIGH);

            // Lookup IPP Print Service
            PrintService[] printServices = PrintServiceLookup.lookupPrintServices(flavor, null);
            if (printServices.length == 0) {
                System.out.println("No IPP printer found.");
                return false;
            }

            // Select the first available IPP printer
            DocPrintJob printJob = printServices[0].createPrintJob();
            Doc doc = new SimpleDoc(inputStream, flavor, null);
            printJob.print(doc, attrs);

            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
