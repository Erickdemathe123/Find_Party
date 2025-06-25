import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_model.dart';
import 'purchase_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  EventDetailScreen({required this.event});

  final Color primaryColor = Color(0xFF8B0000);
  final Color backgroundColor = Colors.black;

  void _handlePurchase(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: backgroundColor,
          title: Text('Login necessário', style: TextStyle(color: Colors.red)),
          content: Text(
            'Você precisa estar logado para comprar ingressos.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(color: primaryColor)),
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📅 Data: ${event.date}', style: TextStyle(fontSize: 18, color: Colors.white)),
                  SizedBox(height: 8),
                  Text('📍 Local: ${event.location}', style: TextStyle(fontSize: 18, color: Colors.white)),
                  SizedBox(height: 8),
                  Text('📝 Descrição:', style: TextStyle(fontSize: 16, color: Colors.white)),
                  Text(event.description, style: TextStyle(fontSize: 14, color: Colors.white70)),
                  SizedBox(height: 8),
                  Text('💰 Preço: R\$ ${event.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, color: Colors.greenAccent)),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _handlePurchase(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Comprar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
