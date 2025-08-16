
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;

public class JGet {

    public static final int EXIT_SUCCESS = 0;
    public static final int EXIT_FAILURE = 1;

    /**
     * Executions
     *
     * @param args
     *            Command line arguments
     */
    public static void main(String[] args) {
        JGet jget = new JGet();
        if (args.length > 0) {
            for (String arg : args) {
                try {
                    jget.get(arg);
                } catch (Exception e) {
                    e.printStackTrace();
                    System.exit(EXIT_FAILURE);
                }
            }
        }
        else {
            System.err.println("No URL provided");
            System.exit(EXIT_FAILURE);
        }
    }

    protected void get(String sourceUrl) throws IOException {
        get(sourceUrl, System.getProperty("user.dir"));
    }
    private void get(String sourceUrl, String targetDir) throws IOException {
        get(new URL(sourceUrl), new File(targetDir));
    }
    
    private File buildDownloadFile(URL url) {
        String s = url.toString();
        if (s.endsWith("/")) {
            s = s.substring(0, s.length()-1);
        }
        return new File(s.substring(s.lastIndexOf('/')+1));
    }

    protected File buildDownloadFile(URL source, File targetDir) {
        return new File(targetDir, buildDownloadFile(source).getName());
    }

    private void get(URL source, File targetDir) throws IOException {
        BufferedOutputStream targetStream = null;
        BufferedInputStream sourceStream = null;
        try {
            File target = buildDownloadFile(source, targetDir);
            System.out.println("Source: " + source.toString());
            System.out.println("Target: " + target.getAbsolutePath());
            System.out.print("Bytes downloaded: ");
            targetStream = new BufferedOutputStream(new FileOutputStream(target));
            sourceStream = new BufferedInputStream(source.openStream());
            byte[] buffer = new byte[2048]; // OS buffer is usually 2048.
            long total = 0;
            int count;
            while ((count = sourceStream.read(buffer)) != -1) {
                targetStream.write(buffer, 0, count);
                total += count;
                overwrite(total);
            }
            System.out.println();
        }
        finally {
            close(sourceStream);
            close(targetStream);
        }

    }

    public String get(URL source) throws IOException {
        return (String) source.getContent();
    }

    private String overwriteString = null;
    private void overwrite(long total) {
        String formattedTotal = formatLong(total);
        // Backup the number of characters in the overwriteString.
        if (overwriteString != null) {
            backup(overwriteString.length());
        }
        System.out.print(formattedTotal);
        overwriteString = formattedTotal;
    }

    protected String formatLong(long n) {
        String nAsString = String.valueOf(n);
        StringBuffer formatted = new StringBuffer();
        for (int i = 0; i < nAsString.length(); i++) {
            if (i > 0 && nAsString.length() - i % 3 == 0) {
                formatted.append(',');
            }
            formatted.append(nAsString.charAt(i));
        }
        return formatted.toString();
    }
    
    protected void backup(int count) {
        StringBuffer backup = new StringBuffer();
        for (int i = 0; i < count; i++) {
            backup.append('\b');
        }
        System.out.print(backup);
    }
    
    public void close(InputStream c) {
        if (c != null) {
            try {
                c.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    public void close(OutputStream c) {
        if (c != null) {
            try {
                c.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
