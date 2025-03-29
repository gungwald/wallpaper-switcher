import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Random;

public class WallpaperSwitcher {
    
    public static void main(String[] args) {
        try {
            int sleepMinutes = 5;
            User user = new User();
            Path myPicturesFolder = user.getMyPicturesFolder();
            Random rand = new Random();
            PictureVisitor walker = new PictureVisitor();
            while (true) {
                walker.clear();
                System.out.println("Gathering pictures from " + myPicturesFolder + ".");
                Files.walkFileTree(myPicturesFolder, walker);
                List<Path> pictures = walker.getPictures();
                for (int i = 0; i < 6; i++) {
                    Path pic = pictures.get(rand.nextInt(pictures.size()));
                    System.out.println("Setting wallpaper: " + pic.getFileName());
                    user.setWallpaper(pic);
                    System.out.println("Sleeping for " + sleepMinutes + " minutes.");
                    sleep(sleepMinutes);
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public static void sleep(int minutes) {
        try {
            Thread.sleep(minutes * 60 * 1000);
        }
        catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
    
}
