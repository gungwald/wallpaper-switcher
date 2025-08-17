package com.alteredmechanism.wallpaperswitcher;

import java.io.File;
import java.io.IOException;

public interface PictureAcquirer {
    /**
     * Gets the next picture
     * @return The local file name of the next picture
     */
    public File next() throws IOException;
}
