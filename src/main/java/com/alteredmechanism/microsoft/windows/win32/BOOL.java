package com.alteredmechanism.microsoft.windows.win32;

import com.sun.jna.FromNativeContext;
import com.sun.jna.NativeMapped;
import com.sun.jna.platform.win32.WinDef;

public class BOOL implements NativeMapped {
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

    public BOOL(boolean value) {
        intValue = value ? 1 : 0;
    }

    public boolean isTrue() {
        return intValue != 0;
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
        int primitiveValue = nativeValue==null ? 0 : (Integer) nativeValue;
        return new BOOL(primitiveValue);
    }

    @Override
    public Object toNative() {
        return intValue;
    }

    @Override
    public Class nativeType() {
        return Integer.class;
    }

    @Override
    public boolean equals(Object other) {
        if (other instanceof BOOL) {
            BOOL that = (BOOL) other;
            return this.isTrue() == that.isTrue();
        } else if (other instanceof WinDef.BOOL) {
            WinDef.BOOL that = (WinDef.BOOL) other;
            return this.isTrue() == isTrue(that);
        } else if (other instanceof Integer) {
            Integer that = (Integer) other;
            return this.isTrue() == isTrue(that);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return this.isTrue() ? 1 : 0;
    }

    public static boolean isTrue(WinDef.BOOL b) {
        return isTrue(b.intValue());
    }

    public static boolean isTrue(int i) {
        return i==1;
    }
}
