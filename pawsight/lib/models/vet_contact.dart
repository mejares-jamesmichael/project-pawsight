class VetContact {
  final int id;
  final String clinicName;
  final String phoneNumber;
  final String address;
  final bool isEmergency; // 24/7 emergency service
  final String? email; // Email address for inquiries
  final String? facebookUrl; // Facebook page URL
  final String? instagramUrl; // Instagram profile URL
  final String? notes; // Additional info (hours, specialties, etc.)

  VetContact({
    required this.id,
    required this.clinicName,
    required this.phoneNumber,
    required this.address,
    required this.isEmergency,
    this.email,
    this.facebookUrl,
    this.instagramUrl,
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
      'email': email,
      'facebook_url': facebookUrl,
      'instagram_url': instagramUrl,
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
      email: map['email'],
      facebookUrl: map['facebook_url'],
      instagramUrl: map['instagram_url'],
      notes: map['notes'],
    );
  }
}
