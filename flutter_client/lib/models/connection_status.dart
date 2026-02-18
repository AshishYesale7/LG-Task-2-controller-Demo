/// Re-exports [ConnectionStatus] from the transport layer.
///
/// The canonical definition lives in [SSHService] to respect the
/// 5-layer architecture (transport layer owns its own types).
/// This file exists for backward compatibility.
export 'package:flutter_client/services/ssh_service.dart' show ConnectionStatus;
