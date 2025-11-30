import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pawsight/services/database_helper.dart';

void main() {
  // Initialize FFI loader for desktop/test execution
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('Database seeding should populate behaviors', () async {
    final dbHelper = DatabaseHelper.instance;
    
    // Fetch behaviors
    final behaviors = await dbHelper.getBehaviors();
    
    // Verify we have data
    expect(behaviors.isNotEmpty, true);
    
    // Verify the count matches our seed data (15 items)
    expect(behaviors.length, 15);
    
    // Verify content of the first item
    expect(behaviors.first.name, 'Vertical Tail');
    expect(behaviors.first.category, 'Tail');
    
    await dbHelper.close();
  });
}
