class apiKey {
  final String apikey;

  apiKey({required this.apikey});

  factory apiKey.fromJson(Map<String, dynamic> json) =>
      apiKey(apikey: json["api_key"]);
}
