import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.io.*;
import java.net.URL;
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
        logger.info("Reading Bing wallpaper metadata from: " + info.toString());
        String jsonText = readAllChars(info);
        logger.info("Read info: " + jsonText);
        JsonObject json = new Gson().fromJson(jsonText, JsonObject.class);
        logger.info("JSON object: " + jsonText);
        JsonObject firstImage = json.get("images").getAsJsonArray().get(0).getAsJsonObject();
        String path = firstImage.get("url").getAsString();
        String wallpaperUrlText = "http://bing.com" + path;
        logger.info("images[0].url: " + jsonText);
        URL wallpaperUrl = new URL(wallpaperUrlText);
        logger.info("Reading wallpaper from " + wallpaperUrl.toString());
        byte[] wallpaper = readAllBytes(wallpaperUrl);
        String localFileName = firstImage.get("fullstartdate").getAsString() + "-" + firstImage.get("title").getAsString().replace(" ", "_");
        mkdir(wallpaperDir);
        File localFile = new File(wallpaperDir, localFileName);
        logger.info("Writing wallpaper to " + localFile.getName());
        writeAll(localFile, wallpaper);
        return localFile;
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
