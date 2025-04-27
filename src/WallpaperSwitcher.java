import com.microsoft.windows.Wallpaper;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Random;
import java.util.logging.Level;
import java.util.logging.Logger;

public class WallpaperSwitcher {

    private static final Logger logger = Logger.getLogger(WallpaperSwitcher.class.getName());

    public static void main(String[] args) {
        try {
            WallpaperSwitcher ws = new WallpaperSwitcher();
            ws.engage();
        }
        catch (Exception e) {
            logger.log(Level.SEVERE, "Caught exception in main", e);
        }
    }

    private void engage() throws IOException {
        BingWallpaperAcquirer bing = new BingWallpaperAcquirer();
        while (true) {
            File f = bing.next();
            Wallpaper.set(f);
            sleep(1);
        }
    }

    public static void sleep(int minutes) {
        logger.info("Sleeping for " + minutes + " minute(s)");
        try {
            Thread.sleep(minutes * 60 * 1000);
        }
        catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
    
}
