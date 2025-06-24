import 'package:flutter/material.dart';
import 'event_model.dart';

class PurchaseScreen extends StatelessWidget {
  final Event event;

  PurchaseScreen({required this.event});

  void _completePurchase(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Compra Realizada', style: TextStyle(color: Colors.red)),
        content: Text('Sua compra foi realizada com sucesso!', style: TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Finalizar Compra')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evento: ${event.title}', style: TextStyle(fontSize: 18)),
            Text('Data: ${event.date}', style: TextStyle(fontSize: 18)),
            Text('Local: ${event.location}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Descrição: ${event.description}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _completePurchase(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirmar Compra'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.red,
              ),
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
