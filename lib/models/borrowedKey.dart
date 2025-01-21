class BorrowedKey {
  final String ausleihDatum;
  final String? keychain; // Keychain könnte null sein
  final String keyId;

  BorrowedKey({
    required this.ausleihDatum,
    required this.keychain,
    required this.keyId,
  });

  factory BorrowedKey.fromJson(Map<String, dynamic> json) {
    return BorrowedKey(
      ausleihDatum: json["Ausleihdatum"],
      keychain: json["Schlüsselbund"], // Hier den korrekten Schlüssel verwenden
      keyId: json["Schlüsselnummer"],
    );
  }
}
