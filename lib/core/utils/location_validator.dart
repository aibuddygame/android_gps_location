class LocationValidator {
  const LocationValidator._();

  static String? validateLatitude(String value) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a number';
    if (parsed < -90 || parsed > 90) return 'Latitude must be -90 to 90';
    return null;
  }

  static String? validateLongitude(String value) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a number';
    if (parsed < -180 || parsed > 180) return 'Longitude must be -180 to 180';
    return null;
  }

  static String? validateNonNegative(String value, String label) {
    if (value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a number';
    if (parsed < 0) return '$label cannot be negative';
    return null;
  }

  static String? validateInterval(String value, int min, int max) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Enter milliseconds';
    if (parsed < min || parsed > max) return 'Use $min to $max ms';
    return null;
  }
}
