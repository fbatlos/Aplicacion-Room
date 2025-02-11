import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:agenda_contactos/entity/person.dart';
import 'database.dart';
import 'dao/persona_dao.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  runApp(MyApp(database));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  const MyApp(this.database, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(database),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final AppDatabase database;

  const HomeScreen(this.database, {super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PersonDao personDao;

  var personInsert = false;

  String name = "";

  final TextEditingController _controller = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    personDao = widget.database.personDao;
  }

  Future<void> addPerson(Person person) async {
    await personDao.insertPerson(person);
    setState(() {});
  }

  Future<List<Person>> fetchPersons() async {
    return await personDao.findAllPeople();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listado', textAlign: TextAlign.center),
        backgroundColor: Color.fromARGB(98, 110, 213, 215),
      ),
      body: FutureBuilder<List<Person>>(
        future: fetchPersons(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final persons = snapshot.data!;
          return ListView.builder(
            itemCount: persons.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(persons[index].name),
                subtitle: Text('ID: ${persons[index].id}'),
                hoverColor: Color.fromARGB(0, 69, 223, 154),
                onLongPress: () async {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        _controller.text = persons[index].name;
                        return AlertDialog(
                          title: const Text('Elige una opción.'),
                          content: Column(
                            children: [
                              TextButton(
                                onPressed: () {
                                  personDao.deletePerson(persons[index]);
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                    msg: "Fue eliminado con éxito.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                  setState(() {});
                                },
                                child: const Text("Eliminar."),
                              ),
                              TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  labelText: 'Actualizar nombre',
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  String updatedName = _controller.text.trim();
                                  if (updatedName.isNotEmpty) {
                                    setState(() {
                                      persons[index] = Person(
                                          persons[index].id, updatedName);
                                    });

                                    personDao.updatePerson(persons[index]);

                                    Fluttertoast.showToast(
                                      msg: "$updatedName actualizado.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "El nombre no puede estar vacío.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                    );
                                  }

                                  Navigator.pop(context);
                                },
                                child: const Text("Actualizar"),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      });
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(98, 110, 213, 215),
        foregroundColor: Color.fromARGB(97, 17, 84, 85),
        onPressed: () async {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Ingresa un usuario!'),
                  content: TextField(
                    onChanged: (value) {
                      name = value;
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        if (name == "") {
                          Navigator.pop(context);
                          setState(() {});
                        } else {
                          personDao.insertPerson(Person(null, name));
                          Navigator.pop(context);
                          setState(() {});
                        }

                        print(name);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
