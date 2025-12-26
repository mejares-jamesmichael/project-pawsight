class VetContact {
  final int id;
  final String clinicName;
  final String phoneNumber;
  final String address;
  final bool isEmergency; // 24/7 emergency service
  final String? notes; // Additional info (hours, specialties, etc.)

  VetContact({
    required this.id,
    required this.clinicName,
    required this.phoneNumber,
    required this.address,
    required this.isEmergency,
    this.notes,
  });

  // Convert a VetContact into a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clinic_name': clinicName,
      'phone_number': phoneNumber,
      'address': address,
      'is_emergency': isEmergency ? 1 : 0,
      'notes': notes,
    };
  }

  // Convert a Map from database into a VetContact
  factory VetContact.fromMap(Map<String, dynamic> map) {
    return VetContact(
      id: map['id'],
      clinicName: map['clinic_name'],
      phoneNumber: map['phone_number'],
      address: map['address'],
      isEmergency: map['is_emergency'] == 1,
      notes: map['notes'],
    );
  }
}
