package com.alteredmechanism.wallpaperswitcher;

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
        println("Getting URL of today's wallpaper...");

        // Read the JSON metadata from Bing
        logger.fine("Reading Bing wallpaper metadata from: " + info.toString());
        String jsonText = readAllChars(info);
        logger.fine("Read info: " + jsonText);

        // Parse the JSON
        JsonObject json = new Gson().fromJson(jsonText, JsonObject.class);
        logger.fine("JSON object: " + jsonText);

        // Get the first image from the array of images
        JsonObject firstImage = json.get("images").getAsJsonArray().get(0).getAsJsonObject();

        // Extract & print information about the image
        String title = firstImage.get("title").getAsString();
        println("Title: " + title);
        String copyright = firstImage.get("copyright").getAsString();
        println("Copyright: " + copyright);
        String copyrightLink = firstImage.get("copyrightlink").getAsString();
        println("Link: " + copyrightLink);

        // Get the URL of the image
        String path = firstImage.get("url").getAsString();
        String wallpaperUrlText = "http://bing.com" + path;
        logger.fine("images[0].url: " + jsonText);
        URL wallpaperUrl = new URL(wallpaperUrlText);

        // Get the text of the local file name from the query string
        String localFileName = splitQuery(wallpaperUrl).get("id").get(0);
        printf("Downloading %s...%n", localFileName);

        // Download the raw bytes of the image into a byte array called wallpaper.
        logger.fine("Reading wallpaper from " + wallpaperUrl.toString());
        byte[] wallpaper = readAllBytes(wallpaperUrl);

        // Save the wallpaper to the target directory
        mkdir(wallpaperDir);
        File localFile = new File(wallpaperDir, localFileName);
        logger.fine("Saving to " + localFile.getCanonicalPath());
        logger.fine("Writing wallpaper to " + localFile.getCanonicalPath());
        printf("Saving in directory %s...%n", wallpaperDir.getCanonicalPath());
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

    public void printf(String message, Object... params) {
        System.out.printf(message, params);
        System.out.flush();
    }

    public void println(String message) {
        System.out.println(message);
        System.out.flush();
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
