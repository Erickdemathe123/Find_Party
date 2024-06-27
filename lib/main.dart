import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'comprar.dart';

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
      primarySwatch: Colors.red, // Cor primária para o tema
      scaffoldBackgroundColor: Colors.white, // Cor de fundo padrão para o scaffold
      fontFamily: 'Roboto', // Fonte padrão para o aplicativo
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black), // Estilo de cabeçalho 1
        displayMedium: TextStyle(fontSize: 18.0, color: Colors.black), // Estilo de cabeçalho 2
        bodyLarge: TextStyle(fontSize: 16.0, color: Colors.grey[600]), // Estilo de texto do corpo
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red), // Cor de fundo do botão elevado
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Cor do texto do botão elevado
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 12, horizontal: 24)), // Preenchimento do botão elevado
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // Borda do botão elevado
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red), // Cor da borda do campo de entrada
          borderRadius: BorderRadius.circular(4), // Borda do campo de entrada
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red), // Cor da borda focada do campo de entrada
          borderRadius: BorderRadius.circular(4), // Borda focada do campo de entrada
        ),
        labelStyle: TextStyle(color: Colors.red), // Estilo do rótulo do campo de entrada
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
        String userId = userCredential.user!.uid;

        // Busca o documento do usuário no Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

        if (userDoc.exists) {
          bool isAdmin = userDoc['isAdmin'] ?? false;

          if (isAdmin) {
            // Se o usuário é administrador, redireciona para EventListScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EventListScreen()),
            );
          } else {
            // Se o usuário não é administrador, redireciona para UserEventListScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserEventListScreen()),
            );
          }
        } else {
          // Tratar o caso em que o documento do usuário não existe
          print('User document does not exist');
        }
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
        title: Text(''),
      ),
      body: Container(
        decoration: BoxDecoration(
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 50),
              Text(
                'Bem vindo ao Find Party',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 18.0,
                  color: Color.fromARGB(255, 73, 27, 27),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Faça o seu login ou registre-se caso ainda não tenha uma conta',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Color.fromARGB(255, 73, 27, 27),
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  fillColor: Colors.white,
                  filled: true,
                ),
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
          // Captura o ID único do usuário gerado pelo Firebase Authentication
          String userId = userCredential.user!.uid;

          // Cria um documento na coleção 'users' com o ID do usuário
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'isAdmin': false, // Define se o usuário é administrador ou não
            // Outros campos do usuário, se necessário
          });

          // Fecha a tela de registro e retorna à tela anterior
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
          IconButton(
            icon: Icon(Icons.exit_to_app), // Ícone de sair da conta
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Faz logout do usuário
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false, // Remove todas as rotas da pilha
              );
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyApp(), // Abre a tela definida em comprar.dart
                  ),
                );
              },
              child: Text('Comprar'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserEventListScreen extends StatelessWidget {
  final CollectionReference eventsRef = FirebaseFirestore.instance.collection('events');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app), // Ícone de sair da conta
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Faz logout do usuário
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false, // Remove todas as rotas da pilha
              );
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(event: events[index]),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PurchaseScreen extends StatelessWidget {
  final Event event;

  PurchaseScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finalizar Compra'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evento: ${event.title}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Data: ${event.date}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Local: ${event.location}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Descrição: ${event.description}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica para finalizar a compra do ingresso
                _completePurchase(context);
              },
              child: Text('Confirmar Compra'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Voltar para a tela anterior
              },
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  void _completePurchase(BuildContext context) {
    // Implemente a lógica de finalização da compra aqui

    // Exemplo de confirmação de compra com um diálogo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Compra Realizada'),
        content: Text('Sua compra foi realizada com sucesso!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Fecha a tela de compra
            },
            child: Text('OK'),
          ),
        ],
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
  final double price; // Novo campo para armazenar o preço

  Event({
    this.id = '',
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.price, // Inclua o preço como parâmetro requerido no construtor
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'],
      date: data['date'],
      location: data['location'],
      description: data['description'],
      price: data['price'] ?? 0.0, // Ler o preço do Firestore
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': date,
      'location': location,
      'description': description,
      'price': price, // Incluir o preço ao salvar no Firestore
    };
  }
}
