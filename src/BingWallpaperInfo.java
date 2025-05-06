import com.google.gson.annotations.SerializedName;

public class BingWallpaperInfo {
    @SerializedName("startdate")
    public String startDate;
    @SerializedName("fullstartdate")
    public String fullStartDate;
    @SerializedName("enddate")
    public String endDate;
    public String url;
    @SerializedName("urlbase")
    public String urlBase;
    public String copyright;
    @SerializedName("copyrightlink")
    public String copyrightLink;
    public String title;
    public String quiz;
    public BingWallpaperInfo() {}
    public void print() {
        System.out.println(title);
        System.out.println(copyright);
        System.out.println(copyrightLink);
    }
}
