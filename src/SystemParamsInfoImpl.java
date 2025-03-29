import java.util.HashMap;

import com.sun.jna.Native;
import com.sun.jna.platform.win32.WinDef.UINT_PTR;
import com.sun.jna.win32.W32APIFunctionMapper;
import com.sun.jna.win32.W32APITypeMapper;


public class SystemParamsInfoImpl implements SystemParamsInfo {

    private SystemParamsInfo iface = null;

    public SystemParamsInfoImpl() {
        HashMap<Object,Object> options = new HashMap<Object,Object>();
        options.put(OPTION_TYPE_MAPPER, W32APITypeMapper.UNICODE);
        options.put(OPTION_FUNCTION_MAPPER, W32APIFunctionMapper.UNICODE);
        iface = (SystemParamsInfo) Native.loadLibrary("user32", SystemParamsInfo.class, options);
    }

    public boolean SystemParamsInfo(long uiAction, long uiParam, String pvParam, long fWinIni) {
        UINT_PTR uiActionPtr = new UINT_PTR(uiAction);
        UINT_PTR uiParamPtr = new UINT_PTR(uiParam);
        UINT_PTR fWinIniPtr = new UINT_PTR(fWinIni);
        return SystemParametersInfo(uiActionPtr, uiParamPtr, pvParam, fWinIniPtr);
    }

    @Override
    public boolean SystemParametersInfo(UINT_PTR uiAction, UINT_PTR uiParam, String pvParam, UINT_PTR fWinIni) {
        return iface.SystemParametersInfo(uiAction, uiParam, pvParam, fWinIni);
    }

}
