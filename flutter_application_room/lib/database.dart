// required package imports
import 'dart:async';

import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:floor/floor.dart';
import 'dao/persona_dao.dart';
import 'entity/person.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Person])
abstract class AppDatabase extends FloorDatabase {
  PersonDao get personDao;
}
