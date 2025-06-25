import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_model.dart';
import 'event_form_screen.dart';
import 'event_detail_screen.dart';
import 'login_screen.dart';

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final CollectionReference eventsRef = FirebaseFirestore.instance.collection('events');
  final ScrollController _scrollController = ScrollController();
  List<Event> _events = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _limit = 10;

  final Color primaryColor = Color(0xFF8B0000);
  final Color backgroundColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading && _hasMore) {
        _fetchEvents();
      }
    });
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    Query query = eventsRef.orderBy('date').limit(_limit);
    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }
    QuerySnapshot snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _lastDocument = snapshot.docs.last;
        _events.addAll(snapshot.docs.map((doc) => Event.fromFirestore(doc)));
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
    }
  }

  void _navigateToForm(Event? event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventFormScreen(event: event)),
    );
    if (result != null) {
      setState(() {
        _events.clear();
        _lastDocument = null;
        _hasMore = true;
      });
      _fetchEvents();
    }
  }

  void _deleteEvent(Event event) async {
    await eventsRef.doc(event.id).delete();
    setState(() {
      _events.removeWhere((e) => e.id == event.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Eventos'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () => _navigateToForm(null),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: _events.isEmpty && _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : ListView.builder(
        controller: _scrollController,
        itemCount: _events.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _events.length) return Center(child: CircularProgressIndicator(color: primaryColor));
          final event = _events[index];
          return Card(
            color: Colors.grey[900],
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(event.title, style: TextStyle(color: Colors.white)),
              subtitle: Text(event.date, style: TextStyle(color: Colors.grey[400])),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: primaryColor),
                    onPressed: () => _navigateToForm(event),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteEvent(event),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
