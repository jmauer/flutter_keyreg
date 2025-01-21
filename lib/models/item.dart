class Item {
  final String id;
  final String houseNumber;
  final String street;
  final String city;
  final String keychainName;
  final String loanDate;
  final String name;
  final String keyNumber;
  final String? timestamp; // Kann null sein
  final String loanPeriod;
  final String? misc; // Kann null sein
  final String number;
  String? keyName;
  final String? batch;
  String? kID;
  String? kLoanPeriod;
  String? kName;
  String? kTimestamp;
  String? kMisc;

  Item(
      {required this.id,
      required this.houseNumber,
      required this.street,
      required this.city,
      required this.keychainName,
      required this.loanDate,
      required this.name,
      required this.keyNumber,
      this.timestamp,
      required this.loanPeriod,
      this.misc,
      required this.number,
      required this.keyName,
      this.batch,
      this.kID,
      this.kLoanPeriod,
      this.kName,
      this.kTimestamp,
      this.kMisc});

  factory Item.fromJson(Map<String, dynamic> json) => Item(
      id: json["ID"] ?? "",
      houseNumber: json["HouseNumber"].toString(),
      street: json["Street"] ?? "",
      city: json["City"] ?? "",
      keychainName: json["Keychain_Name"] ?? "",
      loanDate: json["LoanDate"] ?? "",
      name: json["Name"] ?? "",
      keyNumber: json["Number"].toString(),
      timestamp: json["Timestamp"], // Kann null sein
      loanPeriod: json["LoanPeriod"].toString(),
      misc: json["Misc"], // Kann null sein
      number: json["Number"] ?? "",
      keyName: json["KeyName"],
      batch: json["Batch"] ?? "",
      kID: json["k.ID"] ?? "",
      kLoanPeriod: json["k.LoanPeriod"].toString() ?? "",
      kName: json["k.Name"] ?? "",
      kTimestamp: json["k.Timestamp"] ?? "",
      kMisc: json["k.Misc"] ?? "");
}
