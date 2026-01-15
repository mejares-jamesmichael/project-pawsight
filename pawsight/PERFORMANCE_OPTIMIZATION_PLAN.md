# PawSight Performance Optimization Plan

**Created:** 2026-01-15  
**Branch:** kaelDev  
**Current PR:** #15 (behavior library update + UI/UX polish)

---

## 📊 Current State Analysis

### App Architecture
- **Framework:** Flutter ^3.9.2
- **State Management:** Provider
- **Database:** SQLite (sqflite) - 44 behaviors, 7 vet contacts, chat history
- **Architecture:** MVVM pattern
- **Assets:** Multiple image categories (tail, ear, eye, posture, vocal, whisker)
- **API:** n8n webhook with JWT auth for AI chat

### Recent UI/UX Improvements (PR #15)
1. ✅ Splash screen implementation
2. ✅ Enhanced library widgets with better spacing
3. ✅ Improved behavior detail screen
4. ✅ Hotline screen refactor (561 lines - modal bottom sheets)
5. ✅ Dependency updates (connectivity_plus, share_plus, image_picker, url_launcher)

### Identified Performance Concerns
Based on code analysis and PR feedback:

1. **Large widget files:** Hotline screen (561 lines)
2. **Image loading:** Multiple behavior images per category
3. **List rendering:** 44 behaviors with search/filter
4. **Database queries:** No pagination, loads all behaviors at once
5. **State management:** Potential over-notifying in providers
6. **No caching strategy:** Images and API responses

---

## 🎯 Performance Optimization Strategy

### Priority Matrix

| Priority | Category | Impact | Effort | ROI |
|----------|----------|--------|--------|-----|
| **P0 - Critical** | Database Optimization | High | Low | ⭐⭐⭐⭐⭐ |
| **P0 - Critical** | Image Loading & Caching | High | Medium | ⭐⭐⭐⭐⭐ |
| **P1 - High** | Widget Performance | High | Low | ⭐⭐⭐⭐ |
| **P1 - High** | Lazy Loading Lists | Medium | Medium | ⭐⭐⭐⭐ |
| **P2 - Medium** | Provider Optimization | Medium | Low | ⭐⭐⭐ |
| **P2 - Medium** | Code Splitting | Low | High | ⭐⭐ |
| **P3 - Low** | Monitoring & Profiling | Medium | Medium | ⭐⭐⭐ |

---

## 🚀 Optimization Tasks

### **P0 - Critical: Database Optimization**

#### 1. Add Database Indexing
**File:** `lib/services/database_helper.dart`

**Current Issue:**
- No indexes on frequently queried columns
- Search queries use `LIKE` without indexes
- Chat message queries by `user_id` have index but could be compound

**Solution:**
```dart
// Add in _createDB and _upgradeDB
await db.execute('CREATE INDEX idx_behaviors_category ON behaviors(category)');
await db.execute('CREATE INDEX idx_behaviors_mood ON behaviors(mood)');
await db.execute('CREATE INDEX idx_behaviors_name ON behaviors(name)');
await db.execute('CREATE INDEX idx_chat_messages_user_timestamp ON chat_messages(user_id, timestamp DESC)');
```

**Expected Impact:** 30-50% faster search and filter queries

---

#### 2. Implement Pagination for Behavior List
**File:** `lib/services/database_helper.dart`, `lib/providers/library_provider.dart`

**Current Issue:**
- Loads all 44 behaviors at once (will grow over time)
- No virtual scrolling or pagination

**Solution:**
```dart
// Add to database_helper.dart
Future<List<Behavior>> getBehaviorsPaginated({
  int limit = 20,
  int offset = 0,
  String? searchQuery,
  Set<String>? moods,
  Set<String>? categories,
  String sortBy = 'name',
}) async {
  final db = await instance.database;
  
  // Build WHERE clause dynamically
  List<String> whereConditions = [];
  List<dynamic> whereArgs = [];
  
  if (searchQuery != null && searchQuery.isNotEmpty) {
    whereConditions.add('(LOWER(name) LIKE ? OR LOWER(description) LIKE ?)');
    whereArgs.addAll(['%${searchQuery.toLowerCase()}%', '%${searchQuery.toLowerCase()}%']);
  }
  
  if (moods != null && moods.isNotEmpty) {
    whereConditions.add('mood IN (${List.filled(moods.length, '?').join(',')})');
    whereArgs.addAll(moods);
  }
  
  if (categories != null && categories.isNotEmpty) {
    whereConditions.add('category IN (${List.filled(categories.length, '?').join(',')})');
    whereArgs.addAll(categories);
  }
  
  final where = whereConditions.isEmpty ? null : whereConditions.join(' AND ');
  
  final result = await db.query(
    'behaviors',
    where: where,
    whereArgs: whereArgs.isEmpty ? null : whereArgs,
    orderBy: _buildOrderBy(sortBy),
    limit: limit,
    offset: offset,
  );
  
  return result.map((json) => Behavior.fromMap(json)).toList();
}

String _buildOrderBy(String sortBy) {
  switch (sortBy) {
    case 'category': return 'category ASC, name ASC';
    case 'mood': return 'mood ASC, name ASC';
    default: return 'name ASC';
  }
}
```

**Expected Impact:** 40-60% faster initial load, scalable to 1000+ behaviors

---

#### 3. Implement Database Connection Pooling
**File:** `lib/services/database_helper.dart`

**Current Issue:**
- Singleton pattern but no explicit connection management
- Potential database lock contention

**Solution:**
```dart
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  // Add connection pool for concurrent operations
  static const int _maxConcurrentOperations = 3;
  final _operationSemaphore = Semaphore(_maxConcurrentOperations);
  
  Future<T> _withDatabase<T>(Future<T> Function(Database db) operation) async {
    await _operationSemaphore.acquire();
    try {
      final db = await database;
      return await operation(db);
    } finally {
      _operationSemaphore.release();
    }
  }
  
  // Update all query methods to use _withDatabase
  Future<List<Behavior>> getBehaviors() async {
    return _withDatabase((db) async {
      final result = await db.query('behaviors');
      return result.map((json) => Behavior.fromMap(json)).toList();
    });
  }
}

// Add Semaphore class
class Semaphore {
  int _count;
  final _waitQueue = <Completer>[];
  
  Semaphore(this._count);
  
  Future<void> acquire() async {
    if (_count > 0) {
      _count--;
      return;
    }
    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }
  
  void release() {
    if (_waitQueue.isNotEmpty) {
      _waitQueue.removeAt(0).complete();
    } else {
      _count++;
    }
  }
}
```

**Expected Impact:** Better concurrency, reduced database locks

---

### **P0 - Critical: Image Loading & Caching**

#### 4. Implement Image Caching Strategy
**File:** Add `pubspec.yaml` dependency, create `lib/services/image_cache_service.dart`

**Current Issue:**
- No explicit image caching
- Multiple images per behavior (comma-separated paths)
- Assets loaded on demand without optimization

**Solution:**

**Step 1: Add cached_network_image package**
```yaml
# pubspec.yaml
dependencies:
  cached_network_image: ^3.4.1  # For remote images
  flutter_cache_manager: ^3.4.1  # Advanced caching control
```

**Step 2: Create ImageCacheService**
```dart
// lib/services/image_cache_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();
  
  final Map<String, ImageProvider> _cache = {};
  
  // Preload critical images (behavior categories)
  Future<void> preloadCriticalAssets(BuildContext context) async {
    final criticalPaths = [
      'assets/images/tail/tail-high.jpeg',
      'assets/images/ear/ear-forward.jpg',
      'assets/images/eye/eye-slowblink.jpg',
      'assets/images/posture/posture-belly.jpg',
      'assets/images/vocal/vocal-purr.jpg',
      'assets/images/whisker/whisker-relax.png',
    ];
    
    await Future.wait(
      criticalPaths.map((path) => precacheImage(AssetImage(path), context)),
    );
  }
  
  // Get cached image provider
  ImageProvider getCachedImage(String path) {
    if (!_cache.containsKey(path)) {
      _cache[path] = AssetImage(path);
    }
    return _cache[path]!;
  }
  
  // Clear cache to free memory
  void clearCache() {
    _cache.clear();
    imageCache.clear();
    imageCache.clearLiveImages();
  }
  
  // Get cache stats
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedImages': _cache.length,
      'imageCacheSize': imageCache.currentSize,
      'imageCacheMaxSize': imageCache.maximumSize,
    };
  }
}
```

**Step 3: Initialize in main.dart**
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... existing initialization ...
  
  // Increase image cache size (default is 1000 images, 100MB)
  PaintingBinding.instance.imageCache.maximumSize = 200; // More images
  PaintingBinding.instance.imageCache.maximumSizeBytes = 150 * 1024 * 1024; // 150MB
  
  runApp(
    MultiProvider(
      providers: [
        // ... existing providers ...
      ],
      child: const PawSightApp(),
    ),
  );
}

class PawSightApp extends StatelessWidget {
  const PawSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... existing config ...
      home: Builder(
        builder: (context) {
          // Preload critical images after first frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ImageCacheService().preloadCriticalAssets(context);
          });
          return const HomeScreen();
        },
      ),
    );
  }
}
```

**Expected Impact:** 50-70% faster image loading, smoother scrolling

---

#### 5. Optimize Behavior Card Image Loading
**File:** `lib/widgets/library_widgets.dart`, `lib/screens/behavior_detail_screen.dart`

**Current Issue:**
- BehaviorCard doesn't show thumbnails (only loads on detail screen)
- Multiple images per behavior slow down detail screen

**Solution:**

**For BehaviorCard (add thumbnail preview):**
```dart
// In BehaviorCard widget
class BehaviorCard extends StatelessWidget {
  final Behavior behavior;
  
  String get _firstImagePath {
    return behavior.imagePath.split(',').first.trim();
  }
  
  @override
  Widget build(BuildContext context) {
    return FCard(
      child: Row(
        children: [
          // Add thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              _firstImagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              cacheWidth: 120, // Optimize for 2x display
              cacheHeight: 120,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: theme.colors.muted,
                child: Icon(FIcons.image, color: theme.colors.mutedForeground),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Existing title, tags, description
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**For BehaviorDetailScreen (lazy load carousel images):**
```dart
// Create optimized image carousel
class BehaviorImageCarousel extends StatefulWidget {
  final List<String> imagePaths;
  
  const BehaviorImageCarousel({super.key, required this.imagePaths});
  
  @override
  State<BehaviorImageCarousel> createState() => _BehaviorImageCarouselState();
}

class _BehaviorImageCarouselState extends State<BehaviorImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Preload adjacent images
    _preloadAdjacentImages();
  }
  
  void _preloadAdjacentImages() {
    if (widget.imagePaths.length <= 1) return;
    
    final nextIndex = (_currentPage + 1) % widget.imagePaths.length;
    precacheImage(
      AssetImage(widget.imagePaths[nextIndex]),
      context,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
          _preloadAdjacentImages();
        },
        itemCount: widget.imagePaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.imagePaths[index],
                fit: BoxFit.cover,
                cacheWidth: 800, // Optimize for display
                cacheHeight: 500,
                errorBuilder: (_, __, ___) => Container(
                  color: theme.colors.muted,
                  child: Icon(FIcons.image, size: 48),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

**Expected Impact:** Smoother carousel, 40% faster detail screen load

---

### **P1 - High: Widget Performance**

#### 6. Use const Constructors Everywhere
**Files:** All widget files

**Current Issue:**
- Many widgets aren't marked const where they could be
- Causes unnecessary rebuilds

**Solution:**
Run automated tool and manual review:
```bash
# Analyze and auto-fix const opportunities
dart fix --apply
```

**Manual fixes needed:**
```dart
// Before
Text('Search behaviors...') 

// After
const Text('Search behaviors...')

// Before
SizedBox(height: 16)

// After
const SizedBox(height: 16)

// Before
Icon(FIcons.x, size: 16)

// After
const Icon(FIcons.x, size: 16)
```

**Expected Impact:** 10-20% reduction in widget rebuilds

---

#### 7. Extract Large Widgets into Separate Files
**File:** `lib/screens/hotline_screen.dart` (561 lines)

**Current Issue:**
- Single file with multiple widget classes
- Harder to maintain and optimize

**Solution:**
```
lib/screens/hotline_screen.dart (main screen - 100 lines)
lib/widgets/hotline/
  ├── vet_contact_card.dart
  ├── contact_option_tile.dart
  ├── section_header.dart
  ├── info_row.dart
  └── empty_state.dart
```

**Expected Impact:** Better code splitting, easier optimization

---

#### 8. Implement RepaintBoundary for Complex Widgets
**Files:** `lib/widgets/library_widgets.dart`, `lib/widgets/chat_widgets.dart`

**Current Issue:**
- No repaint boundaries on list items
- Entire list repaints on single item change

**Solution:**
```dart
// Wrap BehaviorCard
class BehaviorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          // ... existing card ...
        ),
      ),
    );
  }
}

// Wrap MessageBubble in chat
class MessageBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        // ... existing bubble ...
      ),
    );
  }
}
```

**Expected Impact:** 30-40% less repainting during scrolling

---

### **P1 - High: Lazy Loading & Virtualization**

#### 9. Implement Virtual Scrolling for Behavior List
**File:** `lib/screens/library_screen.dart`

**Current Issue:**
- All 44 behaviors rendered at once in Column
- Doesn't use ListView.builder's virtualization

**Solution:**
```dart
// Current (BAD)
Column(
  children: provider.behaviors
      .map((behavior) => BehaviorCard(behavior: behavior))
      .toList(),
)

// Optimized (GOOD)
ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: provider.behaviors.length,
  itemBuilder: (context, index) {
    return BehaviorCard(behavior: provider.behaviors[index]);
  },
)
```

**Expected Impact:** 50-60% better scroll performance, lower memory

---

#### 10. Lazy Load Chat History
**File:** `lib/providers/chat_provider.dart`, `lib/screens/chat_screen.dart`

**Current Issue:**
- Loads entire chat history on initialization
- No pagination for long conversations

**Solution:**
```dart
// Add to ChatProvider
static const int _messagesPerPage = 50;
bool _hasMoreMessages = true;
bool _isLoadingMore = false;

Future<void> loadMoreMessages() async {
  if (_isLoadingMore || !_hasMoreMessages) return;
  
  _isLoadingMore = true;
  notifyListeners();
  
  try {
    final userId = _userSession.userId;
    final oldestTimestamp = _messages.isEmpty 
        ? DateTime.now().toIso8601String()
        : _messages.first.timestamp;
    
    final olderMessages = await _database.getChatMessagesBefore(
      userId,
      timestamp: oldestTimestamp,
      limit: _messagesPerPage,
    );
    
    if (olderMessages.length < _messagesPerPage) {
      _hasMoreMessages = false;
    }
    
    _messages.insertAll(0, olderMessages);
  } finally {
    _isLoadingMore = false;
    notifyListeners();
  }
}

// Add to DatabaseHelper
Future<List<ChatMessage>> getChatMessagesBefore({
  required String odId,
  required String timestamp,
  int limit = 50,
}) async {
  final db = await instance.database;
  final result = await db.query(
    'chat_messages',
    where: 'user_id = ? AND timestamp < ?',
    whereArgs: [odId, timestamp],
    orderBy: 'timestamp DESC',
    limit: limit,
  );
  return result.map((json) => ChatMessage.fromMap(json)).toList().reversed.toList();
}
```

**In chat_screen.dart:**
```dart
// Add pull-up-to-load-more
NotificationListener<ScrollNotification>(
  onNotification: (scrollInfo) {
    if (scrollInfo.metrics.pixels == scrollInfo.metrics.minScrollExtent) {
      if (provider.hasMoreMessages && !provider.isLoadingMore) {
        provider.loadMoreMessages();
      }
    }
    return false;
  },
  child: ListView.builder(
    controller: _scrollController,
    reverse: true, // Show latest at bottom
    // ... existing config ...
  ),
)
```

**Expected Impact:** 70% faster chat initialization for long histories

---

### **P2 - Medium: Provider Optimization**

#### 11. Use Selector for Fine-Grained Rebuilds
**Files:** All screens consuming providers

**Current Issue:**
- `context.watch<Provider>()` rebuilds entire widget tree
- Only need specific fields

**Solution:**
```dart
// Before (rebuilds entire screen on ANY provider change)
final provider = context.watch<LibraryProvider>();
return Text('${provider.behaviors.length} behaviors');

// After (only rebuilds when behaviors.length changes)
final behaviorCount = context.select<LibraryProvider, int>(
  (provider) => provider.behaviors.length,
);
return Text('$behaviorCount behaviors');

// For multiple fields
class _LibraryScreenState extends State<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    return Selector<LibraryProvider, _LibraryState>(
      selector: (_, provider) => _LibraryState(
        behaviors: provider.behaviors,
        isLoading: provider.isLoading,
        error: provider.error,
      ),
      builder: (_, state, __) {
        // Widget tree only rebuilds when _LibraryState changes
        if (state.isLoading) return const LibrarySkeletonLoader();
        if (state.error != null) return ErrorWidget(state.error!);
        return BehaviorList(behaviors: state.behaviors);
      },
    );
  }
}

class _LibraryState {
  final List<Behavior> behaviors;
  final bool isLoading;
  final String? error;
  
  _LibraryState({
    required this.behaviors,
    required this.isLoading,
    required this.error,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LibraryState &&
          behaviors.length == other.behaviors.length &&
          isLoading == other.isLoading &&
          error == other.error;
  
  @override
  int get hashCode => Object.hash(behaviors.length, isLoading, error);
}
```

**Expected Impact:** 40-50% fewer unnecessary rebuilds

---

#### 12. Debounce Expensive Operations
**File:** `lib/providers/library_provider.dart`

**Current Issue:**
- Search debounce is 300ms (good!)
- But filter toggles trigger immediate full re-filter
- No debouncing on multiple rapid filter changes

**Solution:**
```dart
class LibraryProvider with ChangeNotifier {
  Timer? _filterDebounceTimer;
  static const _filterDebounceDelay = Duration(milliseconds: 150);
  
  void toggleMoodFilter(String mood) {
    if (_selectedMoods.contains(mood)) {
      _selectedMoods.remove(mood);
    } else {
      _selectedMoods.add(mood);
    }
    _debouncedApplyFilters();
  }
  
  void toggleCategoryFilter(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    _debouncedApplyFilters();
  }
  
  void _debouncedApplyFilters() {
    _filterDebounceTimer?.cancel();
    _filterDebounceTimer = Timer(_filterDebounceDelay, _applyFilters);
    // Immediately update UI to show selected state
    notifyListeners();
  }
  
  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _filterDebounceTimer?.cancel();
    super.dispose();
  }
}
```

**Expected Impact:** Smoother filter interactions, 30% less CPU

---

#### 13. Use Computed Properties Instead of Getters
**File:** `lib/providers/chat_provider.dart`

**Current Issue:**
- `remainingRequests` getter calls `_cleanupOldTimestamps()` every time
- Called multiple times per build

**Solution:**
```dart
class ChatProvider extends ChangeNotifier {
  int _cachedRemainingRequests = 5;
  DateTime? _lastRateLimitCheck;
  
  int get remainingRequests {
    final now = DateTime.now();
    // Only recalculate every 10 seconds
    if (_lastRateLimitCheck == null || 
        now.difference(_lastRateLimitCheck!) > const Duration(seconds: 10)) {
      _cleanupOldTimestamps();
      _cachedRemainingRequests = (_maxRequestsPerMinute - _requestTimestamps.length)
          .clamp(0, _maxRequestsPerMinute);
      _lastRateLimitCheck = now;
    }
    return _cachedRemainingRequests;
  }
  
  void _recordRequest() {
    _requestTimestamps.add(DateTime.now());
    _cachedRemainingRequests = (_maxRequestsPerMinute - _requestTimestamps.length)
        .clamp(0, _maxRequestsPerMinute);
    _lastRateLimitCheck = DateTime.now();
    _startRateLimitTimer();
    notifyListeners();
  }
}
```

**Expected Impact:** Eliminate redundant calculations

---

### **P2 - Medium: Code Splitting & Build Optimization**

#### 14. Implement Deferred Loading for Non-Critical Screens
**File:** `lib/main.dart`, routes configuration

**Current Issue:**
- All screens loaded upfront
- Increases initial bundle size

**Solution:**
```dart
// Create separate entry points for heavy features
// lib/screens/behavior_detail_screen.dart → lib/features/behavior_detail/screen.dart

// In routes
import 'package:flutter/material.dart';

// Deferred imports
import 'screens/home_screen.dart';
import 'screens/library_screen.dart' deferred as library;
import 'screens/chat_screen.dart' deferred as chat;
import 'screens/hotline_screen.dart' deferred as hotline;

// Route handler
class AppRoutes {
  static Future<void> navigateToLibrary(BuildContext context) async {
    await library.loadLibrary();
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => library.LibraryScreen()),
      );
    }
  }
}
```

**Expected Impact:** 20-30% smaller initial bundle

---

#### 15. Enable Release Mode Optimizations
**File:** `android/app/build.gradle`, `ios/Flutter/Release.xcconfig`

**Current Issue:**
- Default release settings may not be optimal

**Solution:**

**Android (build.gradle):**
```gradle
android {
    buildTypes {
        release {
            // Enable R8 (full mode)
            minifyEnabled true
            shrinkResources true
            
            // Enable code obfuscation
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            
            // Split APKs by ABI
            ndk {
                abiFilters 'armeabi-v7a', 'arm64-v8a'
            }
        }
    }
    
    // Enable multidex
    defaultConfig {
        multiDexEnabled true
    }
}
```

**Build optimizations:**
```bash
# Build with tree shaking and split APKs
flutter build apk --release --tree-shake-icons --split-per-abi

# Build with obfuscation
flutter build apk --obfuscate --split-debug-info=./debug-symbols
```

**Expected Impact:** 25-35% smaller APK size

---

### **P3 - Low: Monitoring & Profiling**

#### 16. Add Performance Monitoring Wrapper
**File:** Create `lib/utils/performance_monitor.dart`

**Solution:**
```dart
import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static final Map<String, DateTime> _operationStarts = {};
  
  static void start(String operation) {
    if (kDebugMode) {
      _operationStarts[operation] = DateTime.now();
    }
  }
  
  static void end(String operation) {
    if (kDebugMode && _operationStarts.containsKey(operation)) {
      final duration = DateTime.now().difference(_operationStarts[operation]!);
      debugPrint('⏱️ $operation took ${duration.inMilliseconds}ms');
      _operationStarts.remove(operation);
    }
  }
  
  static Future<T> measure<T>(String operation, Future<T> Function() action) async {
    start(operation);
    try {
      return await action();
    } finally {
      end(operation);
    }
  }
}

// Usage
Future<void> loadBehaviors() async {
  await PerformanceMonitor.measure('LibraryProvider.loadBehaviors', () async {
    _allBehaviors = await DatabaseHelper.instance.getBehaviors();
    _applyFilters();
  });
}
```

**Expected Impact:** Better insights for optimization

---

#### 17. Add Timeline Events for Profiling
**File:** Critical paths in providers and services

**Solution:**
```dart
import 'dart:developer' as developer;

Future<void> loadBehaviors() async {
  final timeline = developer.Timeline.startSync('loadBehaviors');
  try {
    _allBehaviors = await DatabaseHelper.instance.getBehaviors();
    _applyFilters();
  } finally {
    timeline.finish();
  }
}

// View in DevTools Performance tab
```

**Expected Impact:** Easier profiling in Flutter DevTools

---

## 📈 Implementation Roadmap

### Phase 1: Quick Wins (Week 1)
**Target: 40-50% performance improvement**

1. ✅ Add database indexes (Task #2.1)
2. ✅ Implement const constructors (Task #6)
3. ✅ Add RepaintBoundary (Task #8)
4. ✅ Fix ListView.builder usage (Task #9)
5. ✅ Use Selector for providers (Task #11)

**Deliverable:** Performance improvement PR

---

### Phase 2: Image & Memory (Week 2)
**Target: 30-40% better memory usage**

1. ✅ Implement image caching (Task #4)
2. ✅ Optimize image loading (Task #5)
3. ✅ Add image preloading (Task #4.2)
4. ✅ Optimize behavior card thumbnails (Task #5.1)

**Deliverable:** Image optimization PR

---

### Phase 3: Scalability (Week 3)
**Target: Support 1000+ behaviors, 10K+ messages**

1. ✅ Implement pagination (Task #2.2)
2. ✅ Lazy load chat history (Task #10)
3. ✅ Database connection pooling (Task #2.3)
4. ✅ Debounce optimizations (Task #12)

**Deliverable:** Scalability PR

---

### Phase 4: Polish & Monitoring (Week 4)
**Target: Production-ready, measurable metrics**

1. ✅ Code splitting (Task #7)
2. ✅ Deferred loading (Task #14)
3. ✅ Release optimizations (Task #15)
4. ✅ Performance monitoring (Task #16-17)

**Deliverable:** Final optimization PR + metrics dashboard

---

## 🧪 Testing Strategy

### Performance Benchmarks

**Baseline (Current):**
- [ ] App cold start time: ___ms
- [ ] Library screen load: ___ms
- [ ] Chat screen load: ___ms
- [ ] Behavior detail load: ___ms
- [ ] Search query (44 behaviors): ___ms
- [ ] APK size: ___MB
- [ ] Memory usage (idle): ___MB
- [ ] Memory usage (heavy use): ___MB

**Target (After Optimization):**
- [ ] App cold start: <2000ms (-30%)
- [ ] Library screen: <500ms (-50%)
- [ ] Chat screen: <800ms (-40%)
- [ ] Behavior detail: <300ms (-40%)
- [ ] Search query: <100ms (-60%)
- [ ] APK size: <30MB (-25%)
- [ ] Memory (idle): <150MB (-20%)
- [ ] Memory (heavy): <300MB (-30%)

---

### Testing Devices

1. **Low-end Android** (Android 10, 2GB RAM, Snapdragon 450)
2. **Mid-range Android** (Android 13, 4GB RAM, Snapdragon 778G)
3. **High-end Android** (Android 14, 8GB RAM, Snapdragon 8 Gen 2)
4. **iOS** (iPhone 12, iOS 17)

---

### Test Scenarios

1. **Cold Start Test**
   - Force stop app
   - Clear cache
   - Launch and measure time to first frame

2. **Heavy Load Test**
   - Load library (44 behaviors)
   - Scroll rapidly
   - Apply filters
   - Search with 5-character query
   - Measure FPS and frame drops

3. **Memory Stress Test**
   - Navigate between all screens 10 times
   - Scroll chat history (100+ messages)
   - Load 20+ behavior details
   - Monitor memory growth and GC

4. **Image Load Test**
   - Open 10 behaviors with multiple images
   - Measure image load time
   - Check for memory leaks

---

## 📊 Success Metrics

### Key Performance Indicators (KPIs)

| Metric | Current | Target | Critical |
|--------|---------|--------|----------|
| **App Launch Time** | TBD | <2s | <3s |
| **Library Load** | TBD | <500ms | <1s |
| **Search Response** | TBD | <100ms | <300ms |
| **Scroll FPS** | TBD | 60fps | 50fps |
| **Memory Usage** | TBD | <300MB | <500MB |
| **APK Size** | TBD | <30MB | <50MB |
| **Database Query** | TBD | <50ms | <200ms |

---

## 🛠️ Tools & Resources

### Development Tools
- **Flutter DevTools** - Performance tab, Memory tab, Network tab
- **Android Profiler** - CPU, Memory, Network monitoring
- **Xcode Instruments** - Time Profiler, Allocations
- **flutter analyze** - Static analysis
- **dart fix** - Auto-fix const and other issues

### Profiling Commands
```bash
# Performance profiling
flutter run --profile
flutter run --release --dart-define=dart.vm.profile=true

# Memory profiling
flutter drive --profile --trace-startup --target=lib/main.dart

# Build size analysis
flutter build apk --analyze-size
flutter build appbundle --analyze-size

# Check for large dependencies
flutter pub deps --json | dart analyze-deps.dart
```

### Useful Packages
- `flutter_performance_plugin` - Performance metrics
- `performance_benchmark` - Automated benchmarks
- `flutter_memory_profiler` - Memory leak detection

---

## 📝 Notes & Considerations

### Trade-offs

1. **Pagination vs. User Experience**
   - Pro: Better performance, scalability
   - Con: May feel less smooth, need good UX for "load more"
   - **Decision:** Implement with smooth infinite scroll

2. **Image Caching vs. Storage**
   - Pro: Much faster image loads
   - Con: Uses device storage
   - **Decision:** Implement with cache size limits (150MB max)

3. **Code Splitting vs. Complexity**
   - Pro: Smaller initial bundle
   - Con: More complex routing, loading states
   - **Decision:** Only split heavy, infrequently-used features

---

### Potential Risks

1. **Over-optimization:** Premature optimization can complicate code
   - **Mitigation:** Profile first, optimize bottlenecks only

2. **Breaking Changes:** Database schema changes need migration
   - **Mitigation:** Test migrations thoroughly, provide rollback

3. **Memory Leaks:** Caching can introduce leaks if not managed
   - **Mitigation:** Profile memory, implement cache eviction

---

## 🔄 Continuous Optimization

### Monitoring Plan

1. **Weekly Performance Review**
   - Check DevTools metrics
   - Review user feedback
   - Analyze crash reports

2. **Monthly Optimization Cycle**
   - Identify new bottlenecks
   - Test on new devices
   - Update optimization plan

3. **Release Checklist**
   - ✅ Run performance benchmarks
   - ✅ Check APK size delta
   - ✅ Profile on low-end device
   - ✅ Memory leak test
   - ✅ Scroll performance test

---

## 🎯 Next Steps

### Immediate Actions (This Week)

1. [ ] Run baseline performance tests on test devices
2. [ ] Create feature branch: `feat/performance-optimization-phase1`
3. [ ] Implement Phase 1 tasks (Quick Wins)
4. [ ] Run flutter analyze and dart fix
5. [ ] Test on physical devices
6. [ ] Create PR for Phase 1

### Questions to Resolve

1. What's the target minimum Android version? (affects optimization strategies)
2. Do we expect the behavior library to grow beyond 100 items?
3. Should we implement offline image bundling or lazy asset loading?
4. What's the acceptable APK size limit?

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-15  
**Maintained By:** Development Team  
**Review Schedule:** Weekly during optimization phases
