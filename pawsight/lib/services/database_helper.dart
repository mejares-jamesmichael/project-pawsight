import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/behavior.dart';
import '../models/vet_contact.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pawsight.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Incremented version for vet_contacts table
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE behaviors (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      mood TEXT NOT NULL,
      description TEXT NOT NULL,
      image_path TEXT NOT NULL,
      source TEXT,
      source_url TEXT,
      verified_by TEXT,
      last_updated TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE vet_contacts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      clinic_name TEXT NOT NULL,
      phone_number TEXT NOT NULL,
      address TEXT NOT NULL,
      is_emergency INTEGER NOT NULL,
      notes TEXT
    )
    ''');

    await _seedDatabase(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add source attribution columns
      await db.execute('ALTER TABLE behaviors ADD COLUMN source TEXT');
      await db.execute('ALTER TABLE behaviors ADD COLUMN source_url TEXT');
      await db.execute('ALTER TABLE behaviors ADD COLUMN verified_by TEXT');
      await db.execute('ALTER TABLE behaviors ADD COLUMN last_updated TEXT');
    }
    
    if (oldVersion < 3) {
      // Add vet_contacts table
      await db.execute('''
      CREATE TABLE vet_contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clinic_name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        address TEXT NOT NULL,
        is_emergency INTEGER NOT NULL,
        notes TEXT
      )
      ''');
      
      // Seed vet contacts for existing databases
      await _seedVetContacts(db);
    }
  }

  Future _seedDatabase(Database db) async {
    // Seed behaviors
    await _seedBehaviors(db);
    
    // Seed vet contacts
    await _seedVetContacts(db);
  }

  Future _seedBehaviors(Database db) async {
    // NOTE: Replace these placeholder behaviors with your researched data
    final behaviors = [
      Behavior(
        id: 1,
        name: 'Vertical Tail',
        category: 'Tail',
        mood: 'Happy',
        description:
            'Tail pointing straight up signifies confidence, happiness, and a readiness for friendly interaction.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 2,
        name: 'Puffed Tail',
        category: 'Tail',
        mood: 'Fearful',
        description:
            'Also known as bottle brush tail. Indicates severe agitation, fear, or aggression.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 3,
        name: 'Tucked Tail',
        category: 'Tail',
        mood: 'Fearful',
        description:
            'Tail wrapped around or under the body indicates fear, submission, or anxiety.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 4,
        name: 'Slow Tail Wag',
        category: 'Tail',
        mood: 'Mixed',
        description:
            'Slow, focused tail movement indicates concentration or mild irritation.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 5,
        name: 'Fast Tail Thrashing',
        category: 'Tail',
        mood: 'Aggressive',
        description:
            'Rapid tail thrashing indicates frustration, annoyance, or impending aggression.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 6,
        name: 'Forward Ears',
        category: 'Ears',
        mood: 'Happy',
        description:
            'Ears pointing forward indicate curiosity, alertness, and positive engagement.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 7,
        name: 'Flattened Ears',
        category: 'Ears',
        mood: 'Fearful',
        description:
            'Ears pinned back flat against the head signal fear or defensive aggression.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 8,
        name: 'Swiveling Ears',
        category: 'Ears',
        mood: 'Relaxed',
        description:
            'Ears rotating independently show the cat is monitoring their environment.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 9,
        name: 'Slow Blink',
        category: 'Eyes',
        mood: 'Relaxed',
        description:
            'Slow blinking is a sign of trust, affection, and contentment.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 10,
        name: 'Dilated Pupils',
        category: 'Eyes',
        mood: 'Mixed',
        description:
            'Wide pupils can indicate excitement, fear, or aggression depending on context.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 11,
        name: 'Direct Stare',
        category: 'Eyes',
        mood: 'Aggressive',
        description:
            'Unblinking, intense stare can be a challenge or threat signal.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 12,
        name: 'Loaf Position',
        category: 'Posture',
        mood: 'Relaxed',
        description:
            'Sitting with paws tucked under the body indicates comfort and relaxation.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 13,
        name: 'Arched Back',
        category: 'Posture',
        mood: 'Fearful',
        description:
            'Classic Halloween cat pose with arched back and raised fur indicates fear.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 14,
        name: 'Belly Exposure',
        category: 'Posture',
        mood: 'Relaxed',
        description:
            'Rolling over to show belly is a sign of trust and comfort, though not always an invitation to touch.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 15,
        name: 'Purring',
        category: 'Vocal',
        mood: 'Happy',
        description:
            'Rhythmic vibration usually indicates contentment, though cats may also purr when stressed or in pain.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Placeholder - To be replaced',
        sourceUrl: null,
        verifiedBy: 'Pending research',
        lastUpdated: DateTime.now(),
      ),
    ];

    final batch = db.batch();
    for (var behavior in behaviors) {
      batch.insert('behaviors', behavior.toMap());
    }
    await batch.commit();
  }

  Future _seedVetContacts(Database db) async {
    // NOTE: Replace these placeholder contacts with your actual vet clinics
    final vetContacts = [
      VetContact(
        id: 1,
        clinicName: 'City Veterinary Hospital (24/7)',
        phoneNumber: '+1-555-0100',
        address: '123 Main Street, Downtown',
        isEmergency: true,
        notes: 'Open 24/7. Emergency services available. Specializes in critical care.',
      ),
      VetContact(
        id: 2,
        clinicName: 'Paws & Claws Animal Clinic',
        phoneNumber: '+1-555-0200',
        address: '456 Oak Avenue, West Side',
        isEmergency: false,
        notes: 'Mon-Fri: 8AM-6PM, Sat: 9AM-3PM. General practice and surgery.',
      ),
      VetContact(
        id: 3,
        clinicName: 'Emergency Pet Care Center',
        phoneNumber: '+1-555-0300',
        address: '789 Elm Road, East District',
        isEmergency: true,
        notes: 'After-hours emergency clinic. Open nights, weekends, and holidays.',
      ),
      VetContact(
        id: 4,
        clinicName: 'Sunny Valley Veterinary Practice',
        phoneNumber: '+1-555-0400',
        address: '321 Pine Street, Suburban Area',
        isEmergency: false,
        notes: 'Mon-Sat: 9AM-5PM. Wellness exams, vaccinations, dental care.',
      ),
    ];

    final batch = db.batch();
    for (var contact in vetContacts) {
      batch.insert('vet_contacts', contact.toMap());
    }
    await batch.commit();
  }

  Future<List<Behavior>> getBehaviors() async {
    final db = await instance.database;
    final result = await db.query('behaviors');
    return result.map((json) => Behavior.fromMap(json)).toList();
  }

  Future<List<VetContact>> getVetContacts() async {
    final db = await instance.database;
    final result = await db.query('vet_contacts', orderBy: 'is_emergency DESC, clinic_name ASC');
    return result.map((json) => VetContact.fromMap(json)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
