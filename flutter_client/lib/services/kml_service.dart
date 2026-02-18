class KMLService {
  String generateLookAt(double lat, double lon, double alt, double tilt, double heading) {
    return '''
<LookAt>
  <longitude>$lon</longitude>
  <latitude>$lat</latitude>
  <altitude>$alt</altitude>
  <heading>$heading</heading>
  <tilt>$tilt</tilt>
  <range>$alt</range>
  <altitudeMode>relativeToGround</altitudeMode>
  <gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>
</LookAt>''';
  }

  String generateOrbit(double lat, double lon, double alt) {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <gx:Tour>
    <name>Orbit</name>
    <gx:Playlist>
      <gx:FlyTo>
        <gx:duration>1.2</gx:duration>
        <gx:flyToMode>smooth</gx:flyToMode>
        <LookAt>
          <longitude>$lon</longitude>
          <latitude>$lat</latitude>
          <altitude>$alt</altitude>
          <heading>0</heading>
          <tilt>60</tilt>
          <range>$alt</range>
          <gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>
        </LookAt>
      </gx:FlyTo>
      <gx:FlyTo>
        <gx:duration>1.2</gx:duration>
        <gx:flyToMode>smooth</gx:flyToMode>
        <LookAt>
          <longitude>$lon</longitude>
          <latitude>$lat</latitude>
          <altitude>$alt</altitude>
          <heading>90</heading>
          <tilt>60</tilt>
          <range>$alt</range>
          <gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>
        </LookAt>
      </gx:FlyTo>
       <gx:FlyTo>
        <gx:duration>1.2</gx:duration>
        <gx:flyToMode>smooth</gx:flyToMode>
        <LookAt>
          <longitude>$lon</longitude>
          <latitude>$lat</latitude>
          <altitude>$alt</altitude>
          <heading>180</heading>
          <tilt>60</tilt>
          <range>$alt</range>
          <gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>
        </LookAt>
      </gx:FlyTo>
       <gx:FlyTo>
        <gx:duration>1.2</gx:duration>
        <gx:flyToMode>smooth</gx:flyToMode>
        <LookAt>
          <longitude>$lon</longitude>
          <latitude>$lat</latitude>
          <altitude>$alt</altitude>
          <heading>270</heading>
          <tilt>60</tilt>
          <range>$alt</range>
          <gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>
        </LookAt>
      </gx:FlyTo>
      <gx:FlyTo>
        <gx:duration>1.2</gx:duration>
        <gx:flyToMode>smooth</gx:flyToMode>
        <LookAt>
          <longitude>$lon</longitude>
          <latitude>$lat</latitude>
          <altitude>$alt</altitude>
          <heading>0</heading>
          <tilt>60</tilt>
          <range>$alt</range>
          <gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>
        </LookAt>
      </gx:FlyTo>
    </gx:Playlist>
  </gx:Tour>
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
    double halfSize = size / 2;
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
  <name>Pyramid</name>
  <Placemark>
    <name>Pyramid</name>
    <Style>
      <PolyStyle>
        <color>7f00ff00</color>
        <outline>1</outline>
      </PolyStyle>
    </Style>
    <Polygon>
      <extrude>1</extrude>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs>
        <LinearRing>
          <coordinates>
            ${lon - halfSize},${lat - halfSize},${alt + size}
            ${lon + halfSize},${lat - halfSize},${alt + size}
            ${lon + halfSize},${lat + halfSize},${alt + size}
            ${lon - halfSize},${lat + halfSize},${alt + size}
            ${lon - halfSize},${lat - halfSize},${alt + size}
          </coordinates>
        </LinearRing>
      </outerBoundaryIs>
    </Polygon>
  </Placemark>
</Document>
</kml>
''';
  }
}
