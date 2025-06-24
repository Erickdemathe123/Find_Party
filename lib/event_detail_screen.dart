import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_model.dart';
import 'purchase_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  EventDetailScreen({required this.event});

  void _handlePurchase(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Login necessário',
            style: TextStyle(color: Colors.red),
          ),
          content: Text(
            'Você precisa estar logado para comprar ingressos.',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PurchaseScreen(event: event)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Data: ${event.date}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('Local: ${event.location}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('Descrição: ${event.description}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('Preço: R\$ ${event.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _handlePurchase(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Comprar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
