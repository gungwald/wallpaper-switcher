import java.io.IOException;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.List;


public class PictureVisitor extends SimpleFileVisitor<Path> {

    private ArrayList<Path> pictures = new ArrayList<Path>();
    
    @Override
    public FileVisitResult visitFile(Path path, BasicFileAttributes attr) throws IOException {
        if (isPicture(path)) {
            if (Files.size(path) > 80000) {
                pictures.add(path);
            }
        }
        return FileVisitResult.CONTINUE;
    }

    public boolean isPicture(Path path) {
        boolean isPicture = false;
        try {
            String name = path.toString();
            String ext = name.substring(name.lastIndexOf('.')).toLowerCase();
            if (ext.equals(".jpg") || ext.equals(".gif")) {
                isPicture = true;
            }
            else if (ext.equals(".png")) {
                System.out.println("Skipping .png: " + path.getFileName());
            }
        }
        catch (IndexOutOfBoundsException e) {
            // It's OK.
        }
        return isPicture;
    }

    public List<Path> getPictures() {
        return pictures;
    }
    
    public void clear() {
        pictures.clear();
    }
}
