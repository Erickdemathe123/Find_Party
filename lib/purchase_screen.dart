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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🎉 ${event.title}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 10),
                    Text('📅 ${event.date}', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    Text('📍 ${event.location}', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    SizedBox(height: 10),
                    Text('📝 Descrição:', style: TextStyle(fontSize: 16, color: Colors.white)),
                    SizedBox(height: 4),
                    Text(event.description, style: TextStyle(fontSize: 14, color: Colors.white70)),
                    SizedBox(height: 10),
                    Text('💰 Preço: R\$ ${event.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, color: Colors.greenAccent)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _completePurchase(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: Icon(Icons.check_circle_outline),
              label: Text('Confirmar Compra'),
            ),
            SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white24),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
