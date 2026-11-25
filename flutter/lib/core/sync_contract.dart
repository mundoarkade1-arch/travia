import 'travia_model.dart';

class SyncEnvelope {
  SyncEnvelope(
      {required this.deviceId,
      required this.updatedAt,
      required this.payload,
      this.schemaVersion = 4,
      this.baseRevision = 0});
  final int schemaVersion;
  final String deviceId;
  final String updatedAt;
  final int baseRevision;
  final TraviaState payload;

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'deviceId': deviceId,
        'updatedAt': updatedAt,
        'baseRevision': baseRevision,
        'payload': payload.toJson()
      };
}
