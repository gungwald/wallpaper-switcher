import java.nio.file.Path;
import java.nio.file.Paths;

import com.sun.jna.Native;
import com.sun.jna.Pointer;
import com.sun.jna.platform.win32.Shell32;
import com.sun.jna.platform.win32.ShlObj;
import com.sun.jna.platform.win32.Win32Exception;
import com.sun.jna.platform.win32.WinDef;
import com.sun.jna.platform.win32.WinError;
import com.sun.jna.platform.win32.WinNT;


public class User {

    private static SystemParamsInfoImpl impl = new SystemParamsInfoImpl();
    
    private static WinNT.HANDLE NULL_HANDLE = new WinNT.HANDLE(Pointer.NULL);
    private static WinDef.HWND NULL_HWND = new WinDef.HWND(Pointer.NULL);
        
    public User() { }

    public Path getMyPicturesFolder() {
        char[] myPicturesFolder = new char[WinDef.MAX_PATH];
        WinNT.HRESULT result = Shell32.INSTANCE.SHGetFolderPath(NULL_HWND, ShlObj.CSIDL_MYPICTURES, NULL_HANDLE, ShlObj.SHGFP_TYPE_CURRENT, myPicturesFolder);
        if (! result.equals(WinError.S_OK)) {
            throw new Win32Exception(result);
        }
        return Paths.get(Native.toString(myPicturesFolder));
    }
    
    public void setWallpaper(Path path) {
        impl.SystemParamsInfo(SystemParamsInfoIface.SPI_SETDESKWALLPAPER, 0, 
                path.toAbsolutePath().toString(), 
                SystemParamsInfoIface.SPIF_UPDATEINIFILE | SystemParamsInfoIface.SPIF_SENDWININICHANGE);
    }
    
}
