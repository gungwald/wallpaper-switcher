import java.util.Iterator;

public class MyPicturesCollection implements PictureCollection {
    @Override
    public Iterator<String> iterator() {
        return new MyPicturesIterator();
    }
}
