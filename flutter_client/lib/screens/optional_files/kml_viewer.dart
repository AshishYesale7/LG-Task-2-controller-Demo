import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_client/services/lg_service.dart';

/// KML viewer / editor screen.
///
/// Lets students write or paste raw KML, choose from built-in
/// templates, and send it directly to the Liquid Galaxy rig.
/// Great for experimenting with KML syntax.
class KmlViewerScreen extends StatefulWidget {
  const KmlViewerScreen({super.key});

  @override
  State<KmlViewerScreen> createState() => _KmlViewerScreenState();
}

class _KmlViewerScreenState extends State<KmlViewerScreen> {
  final _kmlController = TextEditingController();

  bool _isSending = false;
  String? _statusMessage;

  /// Currently selected template name (or null for blank).
  String? _selectedTemplate;

  // ─── KML templates ─────────────────────────────────────────────────

  static const Map<String, String> _templates = {
    'Placemark': '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>My Placemark</name>
    <Placemark>
      <name>Sample Location</name>
      <description>A simple placemark example</description>
      <Point>
        <coordinates>0.6200,41.6176,0</coordinates>
      </Point>
    </Placemark>
  </Document>
</kml>''',
    'LineString': '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>My Path</name>
    <Style>
      <LineStyle>
        <color>ff0000ff</color>
        <width>4</width>
      </LineStyle>
    </Style>
    <Placemark>
      <name>Sample Path</name>
      <LineString>
        <tessellate>1</tessellate>
        <coordinates>
          0.6200,41.6176,0
          2.1734,41.3851,0
          -3.7038,40.4168,0
        </coordinates>
      </LineString>
    </Placemark>
  </Document>
</kml>''',
    'Screen Overlay': '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>My Overlay</name>
    <ScreenOverlay>
      <name>Logo</name>
      <Icon>
        <href>https://liquidgalaxy.eu/wp-content/uploads/2024/01/LG-logo.png</href>
      </Icon>
      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
      <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
      <size x="0" y="0.1" xunits="fraction" yunits="fraction"/>
    </ScreenOverlay>
  </Document>
</kml>''',
  };

  @override
  void dispose() {
    _kmlController.dispose();
    super.dispose();
  }

  // ─── Actions ───────────────────────────────────────────────────────

  /// Uploads the KML text to the LG rig via SSH.
  Future<void> _sendKml() async {
    final kml = _kmlController.text.trim();
    if (kml.isEmpty) {
      setState(() => _statusMessage = 'KML is empty – nothing to send.');
      return;
    }

    final lgService = context.read<LGService>();

    setState(() {
      _isSending = true;
      _statusMessage = null;
    });

    try {
      // Write KML to the rig's web root and register it
      final escaped = kml.replaceAll("'", "\\'");
      await lgService.executeRaw(
        "echo '$escaped' > /var/www/html/custom.kml",
      );
      await lgService.executeRaw(
        'echo "http://localhost/custom.kml" > /var/www/html/kmls.txt',
      );

      setState(() => _statusMessage = 'KML sent successfully ✓');
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  /// Loads a template into the editor.
  void _applyTemplate(String? name) {
    if (name == null) return;
    setState(() {
      _selectedTemplate = name;
      _kmlController.text = _templates[name] ?? '';
    });
  }

  // ─── UI ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KML Viewer / Editor'),
        actions: [
          IconButton(
            tooltip: 'Clear editor',
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              _kmlController.clear();
              setState(() {
                _selectedTemplate = null;
                _statusMessage = null;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Template dropdown ───────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.snippet_folder_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Template',
                          border: InputBorder.none,
                        ),
                        // ignore: deprecated_member_use
                        value: _selectedTemplate,
                        items: _templates.keys
                            .map(
                              (name) => DropdownMenuItem(
                                value: name,
                                child: Text(name),
                              ),
                            )
                            .toList(),
                        onChanged: _applyTemplate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── KML editor ─────────────────────────────────────────
            TextFormField(
              controller: _kmlController,
              decoration: const InputDecoration(
                labelText: 'KML Content',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                hintText: 'Paste or type KML here…',
              ),
              maxLines: 16,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),

            // ── Send button ────────────────────────────────────────
            FilledButton.icon(
              onPressed: _isSending ? null : _sendKml,
              icon: const Icon(Icons.upload),
              label: const Text('Send KML to LG'),
            ),

            // ── Status ─────────────────────────────────────────────
            if (_isSending) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Card(
                color: _statusMessage!.startsWith('Error')
                    ? theme.colorScheme.errorContainer
                    : theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _statusMessage!,
                    style: TextStyle(
                      color: _statusMessage!.startsWith('Error')
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
