import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
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
        logger.info("Reading Bing wallpaper metadata from " + info.toString());
        String jsonText = (String) info.getContent();
        JsonObject json = new Gson().fromJson(jsonText, JsonObject.class);
        String wallpaperUrlText = "http://bing.com" + json.get("images[0].url").getAsString();
        URL wallpaperUrl = new URL(wallpaperUrlText);
        logger.info("Reading wallpaper from " + wallpaperUrl.toString());
        byte[] wallpaper = (byte[]) wallpaperUrl.getContent();
        String localFileName = json.get("fullstartdate").getAsString() + "-" + json.get("title").getAsString().replace(" ", "_");
        File localFile = new File(wallpaperDir, localFileName);
        logger.info("Writing wallpaper to " + localFile.getName());
        writeAll(localFile, wallpaper);
        return localFile;
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
