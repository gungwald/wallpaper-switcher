package com.alteredmechanism.microsoft.windows;

import com.alteredmechanism.microsoft.windows.win32.BOOL;
import com.sun.jna.platform.win32.Advapi32Util;
import com.sun.jna.platform.win32.Kernel32;
import com.sun.jna.platform.win32.Win32Exception;
import com.sun.jna.platform.win32.WinDef.UINT;
import com.sun.jna.platform.win32.WinReg;

import java.io.File;
import java.util.logging.Level;
import java.util.logging.Logger;

import static com.alteredmechanism.microsoft.windows.win32.User32.*;

/**
 * Encapsulates the mess required to set the wallpaper on Windows.
 */
public class Wallpaper {

    private static final Logger logger = Logger.getLogger(Wallpaper.class.getName());

    public Wallpaper() {
    }

    /**
     * Sets the damn wallpaper.
     *
     * @param wallpaper File containing the image for the wallpaper
     */
    public void set(File wallpaper) {
        logger.entering(Wallpaper.class.getName(), "set", wallpaper);
        System.out.println("Hanging as desktop wallpaper...");
        System.out.flush();
        // Set it in the registry
        Advapi32Util.registrySetStringValue(WinReg.HKEY_CURRENT_USER, "Control Panel\\Desktop", "Wallpaper", wallpaper.getAbsolutePath());
        // And also call the normal function. It is necessary to do both for some reason.
        BOOL success =
                INSTANCE.SystemParametersInfo(
                        new UINT(SPI_SETDESKWALLPAPER),
                        new UINT(0),
                        wallpaper.getAbsolutePath(),
                        new UINT(SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE)
                );
        logger.log(Level.FINE, "Result: " + success);
        if (!success.booleanValue()) {
            logger.log(Level.SEVERE, "Last error: " + Kernel32.INSTANCE.GetLastError());
            Win32Exception e = new Win32Exception(Kernel32.INSTANCE.GetLastError());
            logger.throwing(Wallpaper.class.getName(), "set", e);
            throw e;
        }
        logger.exiting(Wallpaper.class.getName(), "set");
    }
}