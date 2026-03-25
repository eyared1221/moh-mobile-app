class Clinic {
  final String id, name, address, description, distance, imageUrl, openingHours, closingHours, phone;
  final List<String> services;

  Clinic({
    required this.id, required this.name, required this.address, required this.description,
    required this.services, required this.distance, required this.imageUrl,
    required this.openingHours, required this.closingHours, required this.phone,
  });
}