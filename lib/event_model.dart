import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de dados para representar um Evento
class Event {
  final String id;
  final String title;
  final String date;
  final String location;
  final String description;
  final double price;

  Event({
    this.id = '',
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.price,
  });

  /// Construtor de fábrica que cria um [Event] a partir de um documento do Firestore
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      date: data['date'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] ?? 0).toDouble(),
    );
  }

  /// Método para converter um [Event] em um Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': date,
      'location': location,
      'description': description,
      'price': price,
    };
  }
}
