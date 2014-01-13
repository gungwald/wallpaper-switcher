import com.sun.jna.platform.win32.WinDef.UINT_PTR;
import com.sun.jna.win32.StdCallLibrary;

public interface SystemParamsInfoIface extends StdCallLibrary {

    // from MSDN article
    public long SPI_SETDESKWALLPAPER = 20;
    public long SPIF_UPDATEINIFILE = 0x01;
    public long SPIF_SENDWININICHANGE = 0x02;
    
    boolean SystemParametersInfo(UINT_PTR uiAction, UINT_PTR uiParam, String pvParam, UINT_PTR fWinIni);
}