class PersonaData {
  String? demographic;
  String? region;
  bool sharingEnabled;

  PersonaData({
    this.demographic,
    this.region,
    this.sharingEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'age_group': demographic,
      'location': region,
      'allows_data_sharing': sharingEnabled,
    };
  }

  factory PersonaData.fromMap(Map<String, dynamic> data) {
    return PersonaData(
      demographic: data['age_group'] as String?,
      region: data['location'] as String?,
      sharingEnabled: data['allows_data_sharing'] as bool? ?? true,
    );
  }
}
