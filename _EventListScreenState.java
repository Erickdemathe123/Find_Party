class _EventListScreenState extends State<EventListScreen> {
  final CollectionReference eventsRef = FirebaseFirestore.instance.collection('events');
  final ScrollController _scrollController = ScrollController();
  List<Event> _events = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _limit = 10;

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
            icon: Icon(Icons.exit_to_app),
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
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _events.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _events.length) {
                  return Center(child: CircularProgressIndicator());
                }

                final event = _events[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(event.title),
                    subtitle: Text(event.date),
                    onTap: () => _navigateToEventDetailScreen(context, event),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _navigateToEventFormScreen(context, event),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
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

  void _navigateToEventFormScreen(BuildContext context, Event? event) async {
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
      _fetchEvents(); // Recarrega a primeira página após edição/criação
    }
  }

  void _navigateToEventDetailScreen(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
    );
  }

  void _deleteEvent(Event event) async {
    await eventsRef.doc(event.id).delete();
    setState(() {
      _events.removeWhere((e) => e.id == event.id);
    });
  }
}
