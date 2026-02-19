class KMLService {
  String generateLookAt(double lat, double lon, double alt, double tilt, double heading) {
    return '<LookAt><longitude>$lon</longitude><latitude>$lat</latitude><altitude>$alt</altitude><heading>$heading</heading><tilt>$tilt</tilt><range>$alt</range><altitudeMode>relativeToGround</altitudeMode><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>';
  }

  String generateOrbit(double lat, double lon, double alt) {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <gx:Tour><name>Orbit</name><gx:Playlist>
      <gx:FlyTo><gx:duration>1.2</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$lon</longitude><latitude>$lat</latitude><altitude>$alt</altitude><heading>0</heading><tilt>60</tilt><range>$alt</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt></gx:FlyTo>
      <gx:FlyTo><gx:duration>1.2</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$lon</longitude><latitude>$lat</latitude><altitude>$alt</altitude><heading>90</heading><tilt>60</tilt><range>$alt</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt></gx:FlyTo>
      <gx:FlyTo><gx:duration>1.2</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$lon</longitude><latitude>$lat</latitude><altitude>$alt</altitude><heading>180</heading><tilt>60</tilt><range>$alt</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt></gx:FlyTo>
      <gx:FlyTo><gx:duration>1.2</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$lon</longitude><latitude>$lat</latitude><altitude>$alt</altitude><heading>270</heading><tilt>60</tilt><range>$alt</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt></gx:FlyTo>
      <gx:FlyTo><gx:duration>1.2</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$lon</longitude><latitude>$lat</latitude><altitude>$alt</altitude><heading>0</heading><tilt>60</tilt><range>$alt</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt></gx:FlyTo>
  </gx:Playlist></gx:Tour>
</kml>
''';
  }

  String screenOverlayImage(String imageUrl, double overlayX, double overlayY,
      double screenX, double screenY, double sizeX, double sizeY) {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
    <Document>
        <name>Logo</name>
        <Folder>
            <name>Logo</name>
            <ScreenOverlay>
                <name>Logo</name>
                <Icon>
                    <href>$imageUrl</href>
                </Icon>
                <overlayXY x="$overlayX" y="$overlayY" xunits="fraction" yunits="fraction"/>
                <screenXY x="$screenX" y="$screenY" xunits="fraction" yunits="fraction"/>
                <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
                <size x="$sizeX" y="$sizeY" xunits="fraction" yunits="fraction"/>
            </ScreenOverlay>
        </Folder>
    </Document>
</kml>
''';
  }

  String generatePyramid(double lat, double lon, double alt, double size) {
    final double distDegrees = size / 111000; 
    final double half = distDegrees / 2;
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
  <name>Pyramid</name>
  <Placemark>
    <name>Pyramid</name>
    <Style><PolyStyle><color>7f00ff00</color><outline>1</outline></PolyStyle></Style>
    <MultiGeometry>
      <!-- Base -->
      <Polygon>
        <altitudeMode>relativeToGround</altitudeMode>
        <outerBoundaryIs><LinearRing><coordinates>
          ${lon-half},${lat-half},${alt} ${lon+half},${lat-half},${alt} ${lon+half},${lat+half},${alt} ${lon-half},${lat+half},${alt} ${lon-half},${lat-half},${alt}
        </coordinates></LinearRing></outerBoundaryIs>
      </Polygon>
      <!-- Side 1 -->
      <Polygon>
        <altitudeMode>relativeToGround</altitudeMode>
        <outerBoundaryIs><LinearRing><coordinates>
          ${lon-half},${lat-half},${alt} ${lon+half},${lat-half},${alt} ${lon},${lat},${alt+size} ${lon-half},${lat-half},${alt}
        </coordinates></LinearRing></outerBoundaryIs>
      </Polygon>
      <!-- Side 2 -->
      <Polygon>
        <altitudeMode>relativeToGround</altitudeMode>
        <outerBoundaryIs><LinearRing><coordinates>
          ${lon+half},${lat-half},${alt} ${lon+half},${lat+half},${alt} ${lon},${lat},${alt+size} ${lon+half},${lat-half},${alt}
        </coordinates></LinearRing></outerBoundaryIs>
      </Polygon>
      <!-- Side 3 -->
      <Polygon>
        <altitudeMode>relativeToGround</altitudeMode>
        <outerBoundaryIs><LinearRing><coordinates>
          ${lon+half},${lat+half},${alt} ${lon-half},${lat+half},${alt} ${lon},${lat},${alt+size} ${lon+half},${lat+half},${alt}
        </coordinates></LinearRing></outerBoundaryIs>
      </Polygon>
      <!-- Side 4 -->
      <Polygon>
        <altitudeMode>relativeToGround</altitudeMode>
        <outerBoundaryIs><LinearRing><coordinates>
          ${lon-half},${lat+half},${alt} ${lon-half},${lat-half},${alt} ${lon},${lat},${alt+size} ${lon-half},${lat+half},${alt}
        </coordinates></LinearRing></outerBoundaryIs>
      </Polygon>
    </MultiGeometry>
  </Placemark>
</Document>
</kml>
''';
  }
  String generateWeatherPlacemark(double lat, double lon, String city, double temp, String description) {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>Weather</name>
    <Placemark>
      <name>$city Weather</name>
      <description>
        <![CDATA[
          <div style="font-size: 20px; font-weight: bold; color: white; background-color: black; padding: 10px; border-radius: 5px;">
            <h1>$city</h1>
            <h2>$temp°C</h2>
            <p>$description</p>
          </div>
        ]]>
      </description>
      <Point>
        <coordinates>$lon,$lat,500</coordinates>
      </Point>
    </Placemark>
  </Document>
</kml>
''';
  }

  String generatePlacemark(double lat, double lon, String name, String description) {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
  <name>$name</name>
  <Placemark>
    <name>$name</name>
    <description>$description</description>
    <Point>
      <coordinates>$lon,$lat,0</coordinates>
    </Point>
  </Placemark>
</Document>
</kml>
''';
  }
}
