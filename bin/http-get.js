if (typeof WScript === 'undefined' && typeof arguments !== 'undefined') {
    print("This is a Window Script Host script. It won't work with Java.");
    quit();
}

var ADO_TYPE_BINARY = 1; // adTypeBinary
var ADO_SAVE_CREATE_OVERWRITE = 2; // adSaveCreateOverWrite

var source = WScript.Arguments.Item(0);
var target = WScript.Arguments.Item(1);
var http = WScript.CreateObject('MSXML2.ServerXMLHTTP'); 
WScript.Echo("");
WScript.Echo("Source URL = " + source);
WScript.Echo("Target File = " + target);
WScript.Echo("");
WScript.Echo("Downloading...this may take a while...");
http.open('GET', source, false);
http.send(); 
if (http.status == 200) {
    var stream = WScript.CreateObject('ADODB.Stream');
    if (stream != null) {
        stream.Open();
        stream.Type = ADO_TYPE_BINARY;
        stream.Write(http.responseBody);
        stream.Position = 0;
        var targetFileCheck = WScript.CreateObject('Scripting.FileSystemObject');
        if (targetFileCheck.FileExists(target)) {
            targetFileCheck.DeleteFile(target);
        }
        stream.SaveToFile(target, ADO_SAVE_CREATE_OVERWRITE);
        stream.Close();
    } else {
        WScript.Echo("Could not create object: ADODB.Stream");
    }
} 
else { 
   WScript.Echo("Download failed with HTTP code: " + http.status); 
} 
