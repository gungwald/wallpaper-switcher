package com.alteredmechanism.microsoft.windows.win32;

import com.sun.jna.FromNativeContext;
import com.sun.jna.NativeMapped;
import com.sun.jna.platform.win32.WinDef;

public class BOOL implements NativeMapped
{
    public static final BOOL TRUE = new BOOL(1);
    public static final BOOL FALSE = new BOOL(0);

    /** 0 is false, anything else is true */
    protected int intValue;

    public BOOL() {
        this(0);
    }
    public BOOL(int intValue) {
        this.intValue = intValue;
    }

    public BOOL(boolean b) {
        intValue = b ? TRUE.intValue : FALSE.intValue;
    }

    public final boolean booleanValue() {
        return intValue != 0;
    }

    @Override
    public String toString() {
        return booleanValue() ? "TRUE" : "FALSE";
    }

    /**
     * Converts from a native type to this type (BOOL). The code makes
     * assumptions about what type of thing the nativeValue is, but
     * that's OK because it if fails, the caller used this type incorrectly.
     *
     * @param nativeValue It better be something of class Number
     * @param ctx Apparently worthless here
     * @return Something of type BOOL
     */
    @Override
    public Object fromNative(Object nativeValue, FromNativeContext ctx) {
        // BOOL is based on an int.
        int primitiveValue = nativeValue==null ? FALSE.intValue : (Integer) nativeValue;
        return new BOOL(primitiveValue);
    }

    @Override
    public Object toNative() {
        return intValue;
    }

    @Override
    public Class nativeType() {
        return ((Object) intValue).getClass();
    }

    @Override
    public boolean equals(Object other) {
        if (other instanceof BOOL) {
            BOOL that = (BOOL) other;
            return this.booleanValue() == that.booleanValue();
        } else if (other instanceof WinDef.BOOL) {
            WinDef.BOOL that = (WinDef.BOOL) other;
            return this.booleanValue() == booleanValue(that);
        } else if (other instanceof Integer) {
            Integer that = (Integer) other;
            return this.booleanValue() == booleanValue(that);
        } else if (other instanceof String) {
            String that = (String) other;
            return this.booleanValue() == booleanValue(that);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return this.booleanValue() ? 1 : 0;
    }

    /**
     * Decides if a WinDef.BOOL represents true or false based on the
     * algorithm that this class uses, which is 0 for false and 1
     * for any other value. WinDef.BOOL uses the same algorithm.
     */
    public static boolean booleanValue(WinDef.BOOL b) {
        return booleanValue(b.intValue());
    }

    /**
     * Decides if an integer represents true or false based on the
     * algorithm that this class uses, which is 0 for false and 1
     * for any other value.
     * @param i The integer to examine for truth or falseness
     * @return True if i!=0, false if i==0
     */
    public static boolean booleanValue(int i) {
        return i != 0;
    }

    public static boolean booleanValue(String s) {
        return s != null && !s.isEmpty();
    }
}
