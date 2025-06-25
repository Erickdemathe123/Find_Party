import 'package:flutter/material.dart';
import 'event_model.dart';

class PurchaseScreen extends StatelessWidget {
  final Event event;

  PurchaseScreen({required this.event});

  final Color primaryColor = Color(0xFF8B0000);
  final Color backgroundColor = Colors.black;

  void _completePurchase(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text('Compra Realizada', style: TextStyle(color: Colors.greenAccent)),
        content: Text(
          'Sua compra foi realizada com sucesso!',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Finalizar Compra'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evento: ${event.title}', style: TextStyle(fontSize: 18, color: Colors.white)),
            Text('Data: ${event.date}', style: TextStyle(fontSize: 18, color: Colors.white)),
            Text('Local: ${event.location}', style: TextStyle(fontSize: 18, color: Colors.white)),
            SizedBox(height: 20),
            Text('Descrição: ${event.description}', style: TextStyle(fontSize: 16, color: Colors.white70)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _completePurchase(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirmar Compra'),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white24),
                foregroundColor: primaryColor,
              ),
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
