import com.microsoft.windows.Wallpaper;
import com.sun.jna.Native;
import com.sun.jna.Pointer;
import com.sun.jna.platform.win32.Shell32;
import com.sun.jna.platform.win32.ShlObj;
import com.sun.jna.platform.win32.Win32Exception;
import com.sun.jna.platform.win32.WinDef;
import com.sun.jna.platform.win32.WinError;
import com.sun.jna.platform.win32.WinNT;

import java.io.File;

public class User {

    private static final WinNT.HANDLE NULL_HANDLE = new WinNT.HANDLE(Pointer.NULL);
    private static final WinDef.HWND NULL_HWND = new WinDef.HWND(Pointer.NULL);
        
    public User() { }

    public File getMyPicturesFolder() {
        char[] myPicturesFolder = new char[WinDef.MAX_PATH];
        WinNT.HRESULT result = Shell32.INSTANCE.SHGetFolderPath(NULL_HWND, ShlObj.CSIDL_MYPICTURES, NULL_HANDLE, ShlObj.SHGFP_TYPE_CURRENT, myPicturesFolder);
        if (! result.equals(WinError.S_OK)) {
            throw new Win32Exception(result);
        }
        return new File(Native.toString(myPicturesFolder));
    }
    
    public void setWallpaper(File f) {
        new Wallpaper().set(f);
    }
    
}
