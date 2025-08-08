import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.io.*;
import java.net.URL;
import java.net.URLDecoder;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class BingWallpaperAcquirer implements PictureAcquirer {

    private static final Logger logger = Logger.getLogger(BingWallpaperAcquirer.class.getName());
    public static final String WALLPAPER_INFO_SRC_LOC = "http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US";
    public static final String WALLPAPER_TARGET_DIR_SHORT_NAME = "Wallpaper Switcher";
    protected final File wallpaperDir;

    public BingWallpaperAcquirer() {
        User user = new User();
        File myPictures = user.getMyPicturesFolder();
        wallpaperDir = new File(myPictures, WALLPAPER_TARGET_DIR_SHORT_NAME);
    }

    public File next() throws IOException {
        URL info = new URL(WALLPAPER_INFO_SRC_LOC);
	System.out.println("Getting today's wallpaper URL...");
	System.out.flush();
        logger.fine("Reading Bing wallpaper metadata from: " + info.toString());
        String jsonText = readAllChars(info);
        logger.fine("Read info: " + jsonText);
        JsonObject json = new Gson().fromJson(jsonText, JsonObject.class);
        logger.fine("JSON object: " + jsonText);
        JsonObject firstImage = json.get("images").getAsJsonArray().get(0).getAsJsonObject();
        String path = firstImage.get("url").getAsString();
        String wallpaperUrlText = "http://bing.com" + path;
        logger.fine("images[0].url: " + jsonText);
        URL wallpaperUrl = new URL(wallpaperUrlText);
        String localFileName = splitQuery(wallpaperUrl).get("id").get(0);
	System.out.printf("Downloading %s%n...", localFileName);
	System.out.flush();
        logger.fine("Reading wallpaper from " + wallpaperUrl.toString());
        byte[] wallpaper = readAllBytes(wallpaperUrl);
        mkdir(wallpaperDir);
        File localFile = new File(wallpaperDir, localFileName);
        logger.fine("Saving to " + localFile.getCanonicalPath());
        logger.fine("Writing wallpaper to " + localFile.getCanonicalPath());
	System.out.printf("Saving %s%n...", localFileName);
	System.out.flush();
        writeAll(localFile, wallpaper);
        return localFile;
    }

    public Map<String, List<String>> splitQuery(URL url) throws UnsupportedEncodingException {
        final Map<String, List<String>> query_pairs = new LinkedHashMap<String, List<String>>();
        final String[] pairs = url.getQuery().split("&");
        for (String pair : pairs) {
            final int idx = pair.indexOf("=");
            final String key = idx > 0 ? URLDecoder.decode(pair.substring(0, idx), "UTF-8") : pair;
            if (!query_pairs.containsKey(key)) {
                query_pairs.put(key, new LinkedList<String>());
            }
            final String value = idx > 0 && pair.length() > idx + 1 ? URLDecoder.decode(pair.substring(idx + 1), "UTF-8") : null;
            query_pairs.get(key).add(value);
        }
        return query_pairs;
    }

    protected void mkdir(File wallpaperDir) throws IOException {
        if (! wallpaperDir.exists() && ! wallpaperDir.mkdir()) {
            throw new IOException("Could not create directory. Do all the parent directories exist and do you have permission to create this directory? " + wallpaperDir.getAbsolutePath());
        }
    }

    protected String readAllChars(URL remote) throws IOException {
        return readAllChars(new InputStreamReader((InputStream) remote.getContent()));
    }

    protected String readAllChars(InputStreamReader reader) throws IOException {
        char[] buffer = new char[2048];
        StringBuilder text = new StringBuilder();
        int count;
        while ((count = reader.read(buffer)) != -1) {
            text.append(buffer, 0, count);
        }
        return text.toString();
    }

    protected byte[] readAllBytes(URL remote) throws IOException {
        return readAllBytes(remote.openStream());
    }

    protected byte[] readAllBytes(InputStream in) throws IOException {
        byte[] buffer = new byte[2048];
        ByteArrayOutputStream byteContent = new ByteArrayOutputStream();
        int count;
        while ((count = in.read(buffer)) != -1) {
            byteContent.write(buffer, 0, count);
        }
        return byteContent.toByteArray();
    }

    protected void writeAll(File f, byte[] wallpaper) throws IOException {
        FileOutputStream out = new FileOutputStream(f); // Most efficient way
        try {
            out.write(wallpaper);
        } finally {
            close(out, f);
        }
    }

    protected void close(FileOutputStream out, File f) {
        if (out != null) {
            try {
                out.close();
            } catch (IOException e) {
                logger.log(Level.WARNING, "Failed to close file: " + f.getAbsolutePath() , e);
            }
        }
    }
}
