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
      version: 4, // Updated for 44 researched behaviors integration
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
    // Researched cat behavior data (44 behaviors) from credible sources
    // Sources: International Cat Care, ASPCA, PetMD, Cornell Feline Health Center, Hill's Pet
    final behaviors = [
      // TAIL BEHAVIORS (8 total)
      Behavior(
        id: 1,
        name: 'Tail Held High (Vertical)',
        category: 'Tail',
        mood: 'Happy',
        description:
            'When a cat holds their tail straight up like a flagpole, often with a slight curve at the tip, they are expressing confidence, contentment, and friendliness. This is a greeting behavior cats use with trusted companions and indicates they feel safe and want to interact positively.',
        imagePath: 'assets/images/placeholder.png',
        source: 'International Cat Care',
        sourceUrl: 'https://icatcare.org/articles/cat-communication',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 2,
        name: 'Question Mark Tail',
        category: 'Tail',
        mood: 'Happy',
        description:
            'The tail stands upright but curves at the tip like a question mark or shepherd\'s crook. This position signals a playful, friendly mood and often serves as an invitation for interaction or play. It indicates curiosity combined with positive emotions.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Hill\'s Pet Nutrition',
        sourceUrl: 'https://www.hillspet.com/cat-care/behavior-appearance/cat-tail-language',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 3,
        name: 'Tail Tucked Low or Between Legs',
        category: 'Tail',
        mood: 'Fearful',
        description:
            'A tail held low to the ground or tucked tightly between the back legs indicates fear, insecurity, anxiety, or submission. The cat feels threatened or uncomfortable in their current situation and may be preparing to flee.',
        imagePath: 'assets/images/placeholder.png',
        source: 'International Cat Care',
        sourceUrl: 'https://icatcare.org/articles/cat-communication',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 4,
        name: 'Puffed Tail (Bottle Brush)',
        category: 'Tail',
        mood: 'Fearful',
        description:
            'When the tail fur stands on end, creating a "bottle brush" or "Halloween cat" appearance, the cat is experiencing intense fear or feeling threatened. This is piloerection—an involuntary response designed to make the cat appear larger and more intimidating to potential threats.',
        imagePath: 'assets/images/placeholder.png',
        source: 'International Cat Care',
        sourceUrl: 'https://icatcare.org/articles/cat-communication',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 5,
        name: 'Tail Lashing/Thrashing',
        category: 'Tail',
        mood: 'Aggressive',
        description:
            'Rapid, forceful back-and-forth tail movement, often thumping against the floor, indicates agitation, annoyance, or anger. The faster and more intense the thrashing, the more upset the cat is. This is a clear warning to back off.',
        imagePath: 'assets/images/placeholder.png',
        source: 'PetMD',
        sourceUrl: 'https://www.petmd.com/cat/behavior/cat-body-language',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 6,
        name: 'Tail Twitching (Tip Only)',
        category: 'Tail',
        mood: 'Mixed',
        description:
            'Small, quick flicks or twitches at the tip of the tail can indicate focused concentration (especially during hunting or play) or mild irritation. Context is important—during play it signals engagement; during petting it may signal overstimulation.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Ontario SPCA',
        sourceUrl: 'https://ontariospca.ca/blog/cat-body-language-what-is-your-cat-saying/',
        verifiedBy: 'Expert-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 7,
        name: 'Tail Quivering/Vibrating',
        category: 'Tail',
        mood: 'Happy',
        description:
            'A rapid, small vibration or quiver of the tail, usually held upright, typically indicates high excitement—most commonly seen when anticipating food or during greeting behavior.',
        imagePath: 'assets/images/placeholder.png',
        source: 'International Cat Care',
        sourceUrl: 'https://icatcare.org/articles/cat-communication',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 8,
        name: 'Tail Wrapping',
        category: 'Tail',
        mood: 'Mixed',
        description:
            'When a cat wraps their tail around you, another cat, or themselves, the meaning depends on context. Around people or other cats: affection and social bonding. Around their own body while sitting: may indicate feeling cold, uncertain, or defensive.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Cats Protection',
        sourceUrl: 'https://www.cats.org.uk/cats-blog/why-do-cats-have-tails',
        verifiedBy: 'Expert-reviewed',
        lastUpdated: DateTime.now(),
      ),

      // EAR BEHAVIORS (6 total)
      Behavior(
        id: 9,
        name: 'Ears Forward (Neutral)',
        category: 'Ears',
        mood: 'Relaxed',
        description:
            'Ears facing forward in their natural position indicate a content, comfortable cat feeling safe in their environment. This is the baseline "neutral" position for a relaxed feline.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Hill\'s Pet Nutrition',
        sourceUrl: 'https://www.hillspet.com/cat-care/behavior-appearance/cat-ear-language',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 10,
        name: 'Ears Straight Up and Forward',
        category: 'Ears',
        mood: 'Happy',
        description:
            'Ears pointed straight up and facing forward show heightened alertness and curiosity. The cat is paying close attention to something interesting in their environment. Often seen during hunting behavior or when investigating novel stimuli.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Hill\'s Pet Nutrition',
        sourceUrl: 'https://www.hillspet.com/cat-care/behavior-appearance/cat-ear-language',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 11,
        name: 'Ears Flattened Back',
        category: 'Ears',
        mood: 'Fearful',
        description:
            'Ears pinned flat against the head indicate extreme fear, defensiveness, or aggressive intent. The flatter the ears, the more terrified or aggressive the cat. This is often accompanied by hissing, dilated pupils, and a defensive posture.',
        imagePath: 'assets/images/placeholder.png',
        source: 'ASPCA',
        sourceUrl: 'https://www.aspca.org/pet-care/cat-care/common-cat-behavior-issues/aggression-cats',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 12,
        name: 'Airplane Ears (Sideways)',
        category: 'Ears',
        mood: 'Mixed',
        description:
            'Ears rotated to the sides, parallel to the ground (resembling airplane wings), signal nervousness, irritation, uncertainty, or mild stress. The cat is uncomfortable but not yet in full defensive mode.',
        imagePath: 'assets/images/placeholder.png',
        source: 'PetMD',
        sourceUrl: 'https://www.petmd.com/cat/behavior/cat-body-language',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 13,
        name: 'Ears Twitching/Swiveling',
        category: 'Ears',
        mood: 'Relaxed',
        description:
            'Rapid ear movements in different directions show the cat is actively listening and gathering auditory information from their environment. Cats can rotate their ears nearly 180 degrees to pinpoint sounds.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Hill\'s Pet Nutrition',
        sourceUrl: 'https://www.hillspet.com/cat-care/behavior-appearance/cat-ear-language',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 14,
        name: 'Ears Rotated Backward',
        category: 'Ears',
        mood: 'Aggressive',
        description:
            'Ears angled backward (but not completely flattened) indicate irritation, annoyance, or mild defensiveness. This is an intermediate position between neutral and fully defensive.',
        imagePath: 'assets/images/placeholder.png',
        source: 'International Cat Care',
        sourceUrl: 'https://icatcare.org/articles/cat-communication',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),

      // EYE BEHAVIORS (6 total)
      Behavior(
        id: 15,
        name: 'Slow Blink',
        category: 'Eyes',
        mood: 'Relaxed',
        description:
            'A slow, deliberate closing and opening of the eyes is often called the "cat kiss" and represents trust, affection, and contentment. By closing their eyes in your presence, cats demonstrate they feel safe and comfortable.',
        imagePath: 'assets/images/placeholder.png',
        source: 'International Cat Care',
        sourceUrl: 'https://icatcare.org/articles/handling-and-interactions',
        verifiedBy: 'Research-backed, Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 16,
        name: 'Dilated Pupils (Large)',
        category: 'Eyes',
        mood: 'Mixed',
        description:
            'Pupils that expand to large black circles indicate high emotional arousal. In playful contexts with relaxed body language, this signals excitement. Combined with tense posture or defensive body language, it indicates fear or the fight-or-flight response.',
        imagePath: 'assets/images/placeholder.png',
        source: 'ASPCA',
        sourceUrl: 'https://www.aspca.org/pet-care/cat-care/common-cat-behavior-issues/aggression-cats',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 17,
        name: 'Constricted Pupils (Narrow)',
        category: 'Eyes',
        mood: 'Mixed',
        description:
            'Narrow, vertical slit pupils typically indicate contentment and relaxation in normal lighting. However, in confrontational contexts, constricted pupils can signal offensive aggression—the cat is focused intently on a target with aggressive intent.',
        imagePath: 'assets/images/placeholder.png',
        source: 'ASPCA',
        sourceUrl: 'https://www.aspca.org/pet-care/cat-care/common-cat-behavior-issues/aggression-cats',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 18,
        name: 'Wide Staring Eyes',
        category: 'Eyes',
        mood: 'Aggressive',
        description:
            'Direct, unblinking stares with wide eyes are aggressive signals used to intimidate or challenge. In cat-to-cat interactions, prolonged staring is confrontational. Between cats and humans, intense staring can indicate anxiety or warning.',
        imagePath: 'assets/images/placeholder.png',
        source: 'PetMD',
        sourceUrl: 'https://www.petmd.com/cat/behavior/cat-body-language',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 19,
        name: 'Half-Closed Eyes (Squinting)',
        category: 'Eyes',
        mood: 'Relaxed',
        description:
            'Partially closed, relaxed eyes typically indicate a comfortable, content cat. However, if accompanied by lethargy, hiding, or changes in behavior, squinting can indicate pain, illness, or discomfort requiring veterinary attention.',
        imagePath: 'assets/images/placeholder.png',
        source: 'PetMD',
        sourceUrl: 'https://www.petmd.com/cat/behavior/cat-body-language',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 20,
        name: 'Third Eyelid Visible',
        category: 'Eyes',
        mood: 'Mixed',
        description:
            'When the pink tissue in the corner of the eye (nictitating membrane/third eyelid) is visible, it often indicates illness, pain, or medical distress. This warrants immediate veterinary evaluation.',
        imagePath: 'assets/images/placeholder.png',
        source: 'PetMD',
        sourceUrl: 'https://www.petmd.com/cat/behavior/cat-body-language',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),

      // POSTURE BEHAVIORS (9 total)
      Behavior(
        id: 21,
        name: 'Belly Exposure',
        category: 'Posture',
        mood: 'Relaxed',
        description:
            'When a cat rolls onto their back exposing their vulnerable belly, it\'s a significant display of trust and relaxation. However, this is NOT necessarily an invitation for belly rubs—many cats will react defensively if you touch their stomach.',
        imagePath: 'assets/images/placeholder.png',
        source: 'International Cat Care',
        sourceUrl: 'https://icatcare.org/articles/handling-and-interactions',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 22,
        name: 'Arched Back with Puffed Fur',
        category: 'Posture',
        mood: 'Fearful',
        description:
            'The classic "Halloween cat" pose—arched back, fur standing on end, often with a puffed tail and sideways stance—is a defensive posture indicating fear or feeling threatened. The cat is attempting to appear larger to ward off perceived threats.',
        imagePath: 'assets/images/placeholder.png',
        source: 'International Cat Care',
        sourceUrl: 'https://icatcare.org/articles/cat-communication',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 23,
        name: 'Arched Back During Petting',
        category: 'Posture',
        mood: 'Happy',
        description:
            'When a cat arches their back upward to meet your hand during petting (without raised fur or other defensive signals), they are expressing enjoyment and asking for continued physical contact.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Napo Pet',
        sourceUrl: 'https://www.napo.pet/blog/dr-sarah-ellis-on-why-do-cats-arch-their-backs',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 24,
        name: 'Loaf Position (Cat Loaf)',
        category: 'Posture',
        mood: 'Relaxed',
        description:
            'When a cat tucks all four paws beneath their body, resembling a loaf of bread, they typically feel safe, comfortable, and relaxed. This position conserves warmth and protects vulnerable paws while allowing the cat to remain semi-alert.',
        imagePath: 'assets/images/placeholder.png',
        source: 'PetMD',
        sourceUrl: 'https://www.petmd.com/cat/behavior/why-do-cats-loaf',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 25,
        name: 'Kneading (Making Biscuits)',
        category: 'Posture',
        mood: 'Happy',
        description:
            'Rhythmic pushing and pulling with the front paws (often alternating) is a behavior from kittenhood when kittens knead their mother to stimulate milk flow. Adult cats continue kneading when feeling content, relaxed, and affectionate.',
        imagePath: 'assets/images/placeholder.png',
        source: 'PetMD',
        sourceUrl: 'https://www.petmd.com/cat/behavior/why-do-cats-knead',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 26,
        name: 'Crouching Low to Ground',
        category: 'Posture',
        mood: 'Mixed',
        description:
            'A low crouch with body close to the ground can indicate fear and readiness to flee, or alternatively, stalking/hunting behavior preparing to pounce. Body tension and other signals differentiate fear from play.',
        imagePath: 'assets/images/placeholder.png',
        source: 'PetMD',
        sourceUrl: 'https://www.petmd.com/cat/behavior/cat-body-language',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 27,
        name: 'Stretching',
        category: 'Posture',
        mood: 'Relaxed',
        description:
            'Full-body stretches, especially after waking, are normal comfort behaviors indicating the cat feels relaxed and secure in their environment.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Cats Protection',
        sourceUrl: 'https://www.cats.org.uk/cats-blog/why-do-cats-arch-their-back',
        verifiedBy: 'Expert-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 28,
        name: 'Head Bunting/Head Butting',
        category: 'Posture',
        mood: 'Happy',
        description:
            'When a cat bumps their head or rubs their cheeks against you, they are depositing pheromones from scent glands to mark you as part of their social group. This is a sign of trust, affection, and bonding.',
        imagePath: 'assets/images/placeholder.png',
        source: 'PetMD',
        sourceUrl: 'https://www.petmd.com/cat/behavior/why-does-my-cat-headbutt-me',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 29,
        name: 'Body Rubbing (Allorubbing)',
        category: 'Posture',
        mood: 'Happy',
        description:
            'Rubbing the body, flanks, and tail against people, other cats, or objects is scent-marking behavior that also serves social bonding functions. Part of normal feline social interaction.',
        imagePath: 'assets/images/placeholder.png',
        source: 'International Cat Care',
        sourceUrl: 'https://icatcare.org/articles/cat-communication',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),

      // VOCAL BEHAVIORS (11 total)
      Behavior(
        id: 30,
        name: 'Purring',
        category: 'Vocal',
        mood: 'Mixed',
        description:
            'While purring most commonly indicates contentment, happiness, and relaxation, cats also purr when stressed, anxious, in pain, or ill as a self-soothing mechanism. Context and body language are essential to interpret meaning.',
        imagePath: 'assets/images/placeholder.png',
        source: 'PetMD',
        sourceUrl: 'https://www.petmd.com/cat/behavior/why-do-cats-purr',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 31,
        name: 'Meowing',
        category: 'Vocal',
        mood: 'Mixed',
        description:
            'Adult cats primarily meow to communicate with humans (not with other cats). Meowing serves to request attention, food, access to spaces, or express needs. The intensity and tone convey urgency.',
        imagePath: 'assets/images/placeholder.png',
        source: 'ASPCA',
        sourceUrl: 'https://www.aspca.org/pet-care/cat-care/common-cat-behavior-issues/meowing-and-yowling',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 32,
        name: 'Hissing',
        category: 'Vocal',
        mood: 'Fearful',
        description:
            'Hissing is a defensive warning vocalization, not aggression. It\'s an involuntary reflex indicating the cat feels threatened, scared, or needs space. Often accompanied by flattened ears, arched back, and defensive posturing.',
        imagePath: 'assets/images/placeholder.png',
        source: 'PetMD',
        sourceUrl: 'https://www.petmd.com/cat/behavior/cat-hissing-what-you-need-know',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 33,
        name: 'Growling',
        category: 'Vocal',
        mood: 'Aggressive',
        description:
            'A low, rumbling sound used as a warning to back off. Growling indicates the cat feels angry, threatened, territorial, or is in pain. This is a serious warning that should be respected.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Sheba UK',
        sourceUrl: 'https://www.uk.sheba.com/blog/health/cat-growling',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 34,
        name: 'Chirping/Trilling',
        category: 'Vocal',
        mood: 'Happy',
        description:
            'A high-pitched, rolling "brrrp" or chirrup sound made with the mouth closed. Mother cats use trills to communicate with kittens, and adult cats use this friendly vocalization to greet humans, seek attention, or express happiness.',
        imagePath: 'assets/images/placeholder.png',
        source: 'PetsCare',
        sourceUrl: 'https://www.petscare.com/news/post/understanding-cat-trilling-guide',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 35,
        name: 'Chattering (at prey)',
        category: 'Vocal',
        mood: 'Happy',
        description:
            'Rapid teeth-chattering sounds, usually made while watching birds or prey through a window. Theories suggest this represents hunting excitement, frustration at unreachable prey, or practicing the "kill bite" motion.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Cats Protection',
        sourceUrl: 'https://www.cats.org.uk/cats-blog/why-do-cats-chatter-and-chirp-at-birds',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 36,
        name: 'Yowling/Howling',
        category: 'Vocal',
        mood: 'Mixed',
        description:
            'A loud, drawn-out vocalization indicating distress, pain, illness, or mating behavior (especially in unspayed/unneutered cats). Can also signal territorial concerns or separation anxiety.',
        imagePath: 'assets/images/placeholder.png',
        source: 'ASPCA',
        sourceUrl: 'https://www.aspca.org/pet-care/cat-care/common-cat-behavior-issues/meowing-and-yowling',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 37,
        name: 'Spitting',
        category: 'Vocal',
        mood: 'Fearful',
        description:
            'A sudden, explosive burst of sound accompanied by a lunge or swat. This is an involuntary defensive reaction indicating extreme fear or imminent self-defense. Represents escalation beyond hissing.',
        imagePath: 'assets/images/placeholder.png',
        source: 'PetMD',
        sourceUrl: 'https://www.petmd.com/cat/behavior/cat-body-language',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 38,
        name: 'Caterwauling',
        category: 'Vocal',
        mood: 'Mixed',
        description:
            'A loud vocalization that sounds like a cross between a yowl, howl, and whine. Most commonly produced by unspayed females in heat to attract mates, but can also indicate distress.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Zoetis Petcare',
        sourceUrl: 'https://www.zoetispetcare.com/blog/article/cat-sounds-explained',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 39,
        name: 'Mewing (Kittens)',
        category: 'Vocal',
        mood: 'Mixed',
        description:
            'Soft, high-pitched vocalizations used by kittens to communicate with their mother, signaling hunger, cold, or need for attention.',
        imagePath: 'assets/images/placeholder.png',
        source: 'Cats Around The Globe',
        sourceUrl: 'https://catsaroundtheglobe.com/10-key-cat-vocalizations-and-their-meanings/',
        verifiedBy: 'Expert-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 40,
        name: 'Screaming',
        category: 'Vocal',
        mood: 'Aggressive',
        description:
            'Loud, alarming vocalizations during cat fights, mating, or extreme pain. Indicates serious distress.',
        imagePath: 'assets/images/placeholder.png',
        source: 'International Cat Care',
        sourceUrl: 'https://icatcare.org/articles/cat-communication',
        verifiedBy: 'Expert-reviewed',
        lastUpdated: DateTime.now(),
      ),

      // WHISKER BEHAVIORS (4 total) - NEW CATEGORY
      Behavior(
        id: 41,
        name: 'Whiskers Relaxed/Fanned Out',
        category: 'Whiskers',
        mood: 'Relaxed',
        description:
            'Whiskers in their natural position, slightly curved and spread to the sides, indicate a relaxed, comfortable cat feeling safe in their environment.',
        imagePath: 'assets/images/placeholder.png',
        source: 'International Cat Care',
        sourceUrl: 'https://icatcare.org/articles/cat-communication',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 42,
        name: 'Whiskers Forward-Pointing',
        category: 'Whiskers',
        mood: 'Happy',
        description:
            'Whiskers pushed forward indicate curiosity, excitement, focused attention, or hunting behavior. Helps cats gather more sensory information about objects of interest.',
        imagePath: 'assets/images/placeholder.png',
        source: 'ASPCA',
        sourceUrl: 'https://www.aspca.org/pet-care/cat-care/common-cat-behavior-issues/aggression-cats',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 43,
        name: 'Whiskers Pulled Back/Flattened',
        category: 'Whiskers',
        mood: 'Fearful',
        description:
            'Whiskers pulled tightly back against the face signal fear, stress, defensive aggression, or discomfort. The cat feels threatened and may need space.',
        imagePath: 'assets/images/placeholder.png',
        source: 'ASPCA',
        sourceUrl: 'https://www.aspca.org/pet-care/cat-care/common-cat-behavior-issues/aggression-cats',
        verifiedBy: 'Veterinarian-reviewed',
        lastUpdated: DateTime.now(),
      ),
      Behavior(
        id: 44,
        name: 'Whiskers Twitching/Vibrating',
        category: 'Whiskers',
        mood: 'Happy',
        description:
            'Rapid whisker movements indicate heightened excitement or intense focus, often seen during play or when tracking potential prey.',
        imagePath: 'assets/images/placeholder.png',
        source: 'PetsCare',
        sourceUrl: 'https://www.petscare.com/news/post/cat-whiskers-position-meaning',
        verifiedBy: 'Expert-reviewed',
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

