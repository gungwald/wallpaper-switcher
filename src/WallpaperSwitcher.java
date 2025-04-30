import com.microsoft.windows.Wallpaper;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class WallpaperSwitcher {

    private static final Logger logger = Logger.getLogger(WallpaperSwitcher.class.getName());

    public static void main(String[] args) {
        try {
            WallpaperSwitcher ws = new WallpaperSwitcher();
            ws.execute();
        }
        catch (Exception e) {
            logger.log(Level.SEVERE, "Caught exception in main", e);
        }
    }

    private void execute() throws IOException {
        Wallpaper wallpaper = new Wallpaper();
        BingWallpaperAcquirer bing = new BingWallpaperAcquirer();
        while (true) {
            wallpaper.set(bing.next());
            sleep(1);
        }
    }

    public static void sleep(int minutes) {
        logger.info("Sleeping for " + minutes + " minute(s)");
        try {
            Thread.sleep(minutes * 60 * 1000);
        }
        catch (InterruptedException e) {
            logger.log(Level.WARNING, "Caught exception in sleep", e);
        }
    }
    
}
