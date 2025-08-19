package com.alteredmechanism.microsoft.windows.win32;

import com.sun.jna.Native;
import com.sun.jna.platform.win32.WinDef.UINT;
import com.sun.jna.win32.StdCallLibrary;
import com.sun.jna.win32.W32APIFunctionMapper;
import com.sun.jna.win32.W32APIOptions;
import com.sun.jna.win32.W32APITypeMapper;

import java.util.HashMap;
import java.util.Map;

@SuppressWarnings("SpellCheckingInspection")
public interface User32 extends StdCallLibrary {

    /**
     * Set system parameter "w32.ascii" to "true" to get ASCII functions instead of UNICODE.
     * See the code for W32APIOptions.DEFAULT_OPTIONS.
     */
    Map<Object,Object> opt = new HashMap<Object,Object>(W32APIOptions.DEFAULT_OPTIONS) {{
        // An example of how to add more options because this is really hard to figure out. I suggest leaving
        // this here for that reason.
        put("additional.key", "additional.value");
    }};

    /** Loads the user32.dll into this class. */
    User32 INSTANCE = (User32) Native.loadLibrary(
            "user32", User32.class, opt);

    // All variables are implicitly public, static and final in an interface.

    /**
     * <code>uiAction</code> value for the SystemParametersInfo function that specifies that the wallpaper should be set
     */
    long SPI_SETDESKWALLPAPER = 0x0014;

    /**
     * Writes the new system-wide parameter setting to the user profile
     */
    long SPIF_UPDATEINIFILE = 0x01;

    /**
     * Broadcasts the WM_SETTINGCHANGE message after updating the user profile
     */
    long SPIF_SENDWININICHANGE = 0x02;

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
     * @return When setting the wallpaper, this will be false if it fails or true if it succeeds. To get extended error
     *         information, call <a href="https://learn.microsoft.com/en-us/windows/desktop/api/errhandlingapi/nf-errhandlingapi-getlasterror">GetLastError</a>.
     */
    BOOL SystemParametersInfo(UINT uiAction, UINT uiParam, String pvParam, UINT fWinIni);
}
