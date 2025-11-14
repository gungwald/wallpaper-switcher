package com.alteredmechanism.wallpaperswitcher;

import com.alteredmechanism.microsoft.windows.Wallpaper;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.LogManager;
import java.util.logging.Logger;

public class WallpaperSwitcher {

    private static final Level LOGGING_LEVEL = Level.INFO;
    private static final String CLASS_NAME = WallpaperSwitcher.class.getName();
    private static final Logger LOGGER = Logger.getLogger(CLASS_NAME);

    static {
        // Set the logging level, first the root logger and then each handler
        Logger rootLogger = LogManager.getLogManager().getLogger("");
        rootLogger.setLevel(LOGGING_LEVEL);
        for (Handler h : rootLogger.getHandlers()) {
            h.setLevel(LOGGING_LEVEL);
        }
    }

    public static void main(String[] args) {
        unbufferedPrintln("WallpaperSwitcher started.");
        LOGGER.entering(CLASS_NAME, "main");
        try {
            WallpaperSwitcher ws = new WallpaperSwitcher();
            ws.execute();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Caught exception in main", e);
        }
        pauseAtEnd();
        LOGGER.exiting(CLASS_NAME, "main");
    }

    public static void pauseAtEnd() {
        if (System.getProperty("pause.at.end") != null) {
            try {
                BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
                String line = in.readLine();
            } catch (IOException e) {
                LOGGER.log(Level.SEVERE, "Caught exception waiting for input", e);
            }
        }
    }

    protected void execute() throws IOException {
        LOGGER.entering(CLASS_NAME, "execute");
        Wallpaper wallpaper = new Wallpaper();
        BingWallpaperAcquirer bing = new BingWallpaperAcquirer();
        wallpaper.set(bing.next());
        LOGGER.exiting(CLASS_NAME, "execute");
    }

    protected static void sleep(int minutes) {
        LOGGER.info("Sleeping for " + minutes + " minute(s)");
        try {
            Thread.sleep(minutes * 60 * 1000);
        } catch (InterruptedException e) {
            LOGGER.log(Level.WARNING, "Caught exception in sleep", e);
        }
    }

    public static void unbufferedPrintln(String s) {
        System.out.println(s);
        System.out.flush();
    }
}
