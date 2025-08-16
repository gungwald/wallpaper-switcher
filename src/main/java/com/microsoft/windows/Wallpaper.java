package com.microsoft.windows;

import com.sun.jna.Native;
import com.sun.jna.NativeLibrary;
import com.sun.jna.platform.win32.*;
import com.sun.jna.platform.win32.WinDef.BOOL;
import com.sun.jna.platform.win32.WinDef.UINT;
import com.sun.jna.win32.W32APIOptions;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Encapsulates the mess required to set the wallpaper on Windows.
 */
public class Wallpaper {

    private static final Logger logger = Logger.getLogger(Wallpaper.class.getName());

    /**
     * <code>uiAction</code> value for the SystemParametersInfo function that specifies that the wallpaper should be set
     */
    @SuppressWarnings("SpellCheckingInspection")
    protected static final long SPI_SETDESKWALLPAPER = 0x0014;
    /**
     * Writes the new system-wide parameter setting to the user profile
     */
    @SuppressWarnings("SpellCheckingInspection")
    protected static final long SPIF_UPDATEINIFILE = 0x01;
    /**
     * Broadcasts the WM_SETTINGCHANGE message after updating the user profile
     */
    @SuppressWarnings("SpellCheckingInspection")
    protected static final long SPIF_SENDWININICHANGE = 0x02;

    /**
     * Set system parameter "w32.ascii" to "true" to get ASCII functions instead of UNICODE.
     * See the code for W32APIOptions.DEFAULT_OPTIONS.
     */
    @SuppressWarnings("unchecked") // There is nothing more that can be done to fix this warning.
    protected static final Map<String, Object> WALLPAPER_OPTIONS = new HashMap<String, Object>(W32APIOptions.DEFAULT_OPTIONS) {
        {
            // An example of how to add more options because this is really hard to figure out. I suggest leaving
            // this here for that reason.
            put("additional.key", "additional.value");
        }
    };

    // Loads the user32.dll library so that the SystemParametersInfo function can be accessed.
    static {
        Native.register(NativeLibrary.getInstance("user32", WALLPAPER_OPTIONS));
    }

    /**
     * This is the Win32
     * <a href="https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfow">SystemParametersInfo</a>
     * function. It can be used to set the wallpaper, if you perform the appropriate softly spoken magic spells.
     * It is declared in WinUser.h and defined in user32.dll.
     *
     * @param uiAction Specifies what operation to perform. In this case, the value SPI_SETDESKWALLPAPER is passed,
     *                 which tells Windows to set the wallpaper.
     * @param uiParam  Apparently, useless for setting the wallpaper, as the value is 0
     * @param pvParam  The name of the file containing an image, if you're setting the wallpaper
     * @param fWinIni  A bitmask of SPIF_* values, specifying whether the user profile is to be updated, and if so,
     *                 whether the WM_SETTINGCHANGE message is to be broadcast to all top-level windows to notify them
     *                 of the change.
     * @return When setting the wallpaper, this will be false if it fails, true if it succeeds. To get extended error
     * information, call
     * <a href="https://learn.microsoft.com/en-us/windows/desktop/api/errhandlingapi/nf-errhandlingapi-getlasterror">GetLastError</a>.
     */
    @SuppressWarnings("SpellCheckingInspection")
    public static native BOOL SystemParametersInfo(UINT uiAction, UINT uiParam, String pvParam, UINT fWinIni);
    public static BOOL FALSE = new BOOL(0L); // Must be a long value or it fails.
    // BOOL TRUE = new BOOL(1) <-- Don't do this!
    // A Win32 function can return any non-zero value for TRUE so it is not
    // safe to check a return value against a TRUE value defined to be 1.
    // FALSE is the only dependable value. Check equals to FALSE or not
    // equals to FALSE only.

    public Wallpaper() {
    }

    /**
     * Sets the damn wallpaper.
     *
     * @param wallpaper File containing the image for the wallpaper
     */
    public void set(File wallpaper) {
        logger.entering(Wallpaper.class.getName(), "set", wallpaper);
        // Set it in the registry
        Advapi32Util.registrySetStringValue(WinReg.HKEY_CURRENT_USER, "Control Panel\\Desktop", "Wallpaper", wallpaper.getAbsolutePath());
        // And also call the normal function. It is necessary to do both for some reason.
        BOOL success =
                SystemParametersInfo(
                        new UINT(SPI_SETDESKWALLPAPER),
                        new UINT(0),
                        wallpaper.getAbsolutePath(),
                        new UINT(SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE)
                );
        logger.log(Level.INFO, "Result: " + String.valueOf(success));
        if (success.equals(FALSE)) {
            logger.log(Level.SEVERE, "Last error: " + String.valueOf(Kernel32.INSTANCE.GetLastError()));
            Win32Exception e = new Win32Exception(Kernel32.INSTANCE.GetLastError());
            logger.throwing(Wallpaper.class.getName(), "set", e);
            throw e;
        }
        logger.exiting(Wallpaper.class.getName(), "set");
    }
}