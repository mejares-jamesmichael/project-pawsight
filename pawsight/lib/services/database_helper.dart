import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/behavior.dart';

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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE behaviors (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      mood TEXT NOT NULL,
      description TEXT NOT NULL,
      image_path TEXT NOT NULL
    )
    ''');

    await _seedDatabase(db);
  }

  Future _seedDatabase(Database db) async {
    final behaviors = [
      Behavior(id: 1, name: 'Vertical Tail', category: 'Tail', mood: 'Happy', description: 'Tail pointing straight up signifies confidence, happiness, and a readiness for friendly interaction.', imagePath: 'assets/images/placeholder.png'),
      Behavior(id: 2, name: 'Puffed Tail', category: 'Tail', mood: 'Fearful', description: 'Also known as "bottle brush". Indicates severe agitation, fear, or aggression. The cat is trying to look bigger to ward off threats.', imagePath: 'assets/images/placeholder.png'),
      Behavior(id: 3, name: 'Ears Forward', category: 'Ears', mood: 'Relaxed', description: 'Ears facing forward usually mean the cat is interested, curious, or happy.', imagePath: 'assets/images/placeholder.png'),
      Behavior(id: 4, name: 'Flat Ears', category: 'Ears', mood: 'Aggressive', description: 'Ears flattened against the head ("airplane ears") indicate fear or aggression. This protects the ears during a potential fight.', imagePath: 'assets/images/placeholder.png'),
      Behavior(id: 5, name: 'Slow Blink', category: 'Eyes', mood: 'Happy', description: 'A slow blink is a sign of trust and affection. It is essentially a "kitty kiss".', imagePath: 'assets/images/placeholder.png'),
      Behavior(id: 6, name: 'Dilated Pupils', category: 'Eyes', mood: 'Mixed', description: 'Large pupils can mean excitement (play), fear, or low light. Check other body language cues.', imagePath: 'assets/images/placeholder.png'),
      Behavior(id: 7, name: 'Kneading', category: 'Posture', mood: 'Happy', description: 'Pushing paws in and out ("making biscuits") is a comfort behavior left over from kittenhood.', imagePath: 'assets/images/placeholder.png'),
      Behavior(id: 8, name: 'Exposed Belly', category: 'Posture', mood: 'Relaxed', description: 'Showing the belly signals trust, but it is NOT always an invitation for a belly rub! It might be a trap.', imagePath: 'assets/images/placeholder.png'),
      Behavior(id: 9, name: 'Hissing', category: 'Vocal', mood: 'Aggressive', description: 'A clear warning sign. The cat is feeling threatened and wants you to back off.', imagePath: 'assets/images/placeholder.png'),
      Behavior(id: 10, name: 'Purring', category: 'Vocal', mood: 'Happy', description: 'Usually means contentment, but cats also purr when stressed or in pain to soothe themselves.', imagePath: 'assets/images/placeholder.png'),
      Behavior(id: 11, name: 'Question Mark Tail', category: 'Tail', mood: 'Happy', description: 'Tail upright with a curl at the tip. Indicates a playful and friendly mood.', imagePath: 'assets/images/placeholder.png'),
      Behavior(id: 12, name: 'Tucked Tail', category: 'Tail', mood: 'Fearful', description: 'Tail tucked between the legs signals submission, anxiety, or fear.', imagePath: 'assets/images/placeholder.png'),
      Behavior(id: 13, name: 'Arched Back', category: 'Posture', mood: 'Aggressive', description: 'The "Halloween Cat" pose. Indicates the cat is feeling threatened and is prepared to defend itself.', imagePath: 'assets/images/placeholder.png'),
      Behavior(id: 14, name: 'Rubbing', category: 'Posture', mood: 'Happy', description: 'Rubbing against you marks you with their scent. It is a sign of ownership and affection.', imagePath: 'assets/images/placeholder.png'),
      Behavior(id: 15, name: 'Chirping', category: 'Vocal', mood: 'Happy', description: 'A bird-like sound often made when watching prey (birds/bugs) or greeting an owner.', imagePath: 'assets/images/placeholder.png'),
    ];

    final batch = db.batch();
    for (var behavior in behaviors) {
      batch.insert('behaviors', behavior.toMap());
    }
    await batch.commit();
  }

  Future<List<Behavior>> getBehaviors() async {
    final db = await instance.database;
    final result = await db.query('behaviors');
    return result.map((json) => Behavior.fromMap(json)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
