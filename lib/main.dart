import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    title: 'Find Party',
    home: LoginScreen(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Colors.red,
      hintColor: Colors.black,
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        headline1: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black),
        headline2: TextStyle(fontSize: 18.0, color: Colors.black),
        bodyText1: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.red,
        textTheme: ButtonTextTheme.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        labelStyle: TextStyle(color: Colors.red),
      ),
    ),
  ));
}

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EventListScreen()),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login inválido'),
          content: Text('Email ou senha incorretos. Por favor, tente novamente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _login(context);
              },
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationScreen()),
                );
              },
              child: Text('Register', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String confirmPassword = _confirmPasswordController.text.trim();

      if (password == confirmPassword) {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          Navigator.pop(context);
        }
      } else {
        print('Passwords do not match');
      }
    } catch (e) {
      print('Error registering: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _register(context);
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final CollectionReference eventsRef = FirebaseFirestore.instance.collection('events');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _navigateToEventFormScreen(context, null);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: eventsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs.map((doc) => Event.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(events[index].title),
                  subtitle: Text(events[index].date),
                  onTap: () {
                    _navigateToEventDetailScreen(context, events[index]);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _navigateToEventFormScreen(context, events[index]);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteEvent(events[index]);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToEventFormScreen(BuildContext context, Event? event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventFormScreen(event: event)),
    );
    if (result != null) {
      setState(() {});
    }
  }

  void _navigateToEventDetailScreen(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(event: event),
      ),
    );
  }

  void _deleteEvent(Event event) async {
    await eventsRef.doc(event.id).delete();
    setState(() {});
  }
}

class EventFormScreen extends StatefulWidget {
  final Event? event;

  EventFormScreen({this.event});

  @override
  _EventFormScreenState createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _dateController.text = widget.event!.date;
      _locationController.text = widget.event!.location;
      _descriptionController.text = widget.event!.description;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _saveEvent(BuildContext context) async {
    try {
      final String title = _titleController.text.trim();
      final String date = _dateController.text.trim();
      final String location = _locationController.text.trim();
      final String description = _descriptionController.text.trim();

      if (title.isNotEmpty && date.isNotEmpty && location.isNotEmpty && description.isNotEmpty) {
        final eventRef = FirebaseFirestore.instance.collection('events');
        if (widget.event == null) {
          await eventRef.add({
            'title': title,
            'date': date,
            'location': location,
            'description': description,
          });
        } else {
          await eventRef.doc(widget.event!.id).update({
            'title': title,
            'date': date,
            'location': location,
            'description': description,
          });
        }
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error saving event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Novo Evento' : 'Editar Evento'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Data',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectDate(context);
                  },
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Local'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveEvent(context);
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

class EventDetailScreen extends StatelessWidget {
  final Event event;

  EventDetailScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data: ${event.date}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Local: ${event.location}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Descrição: ${event.description}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class Event {
  final String id;
  final String title;
  final String date;
  final String location;
  final String description;

  Event({
    this.id = '',
    required this.title,
    required this.date,
    required this.location,
    required this.description,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'],
      date: data['date'],
      location: data['location'],
      description: data['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': date,
      'location': location,
      'description': description,
    };
  }
}
