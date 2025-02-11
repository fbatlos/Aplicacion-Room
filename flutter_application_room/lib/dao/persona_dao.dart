// dao/person_dao.dart
import 'package:floor/floor.dart';
import 'package:agenda_contactos/entity/person.dart';

@dao
abstract class PersonDao {
  @Query('SELECT * FROM Person')
  Future<List<Person>> findAllPeople();

  @Query('SELECT name FROM Person')
  Stream<List<String>> findAllPeopleName();

  @delete
  Future<void> deletePerson(Person person);

  @update
  Future<void> updatePerson(Person person);

  @insert
  Future<void> insertPerson(Person person);
}
