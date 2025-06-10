import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;

class IequusDatabase {
  Database? _database;

  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'iequus_database.db'),
      onCreate: (db, version) async {
        // Load the SQL script from the asset file
        String script = await rootBundle.loadString('lib/data/model.sql');

        // Split the script into individual statements
        List<String> statements = script.split(';');

        for (String statement in statements) {
          if (statement.trim().isNotEmpty) {
            await db.execute(statement);
          }
        }
      },
      version: 1,
    );
  }
}
