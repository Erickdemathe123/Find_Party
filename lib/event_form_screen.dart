import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_model.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event;

  EventFormScreen({this.event});

  @override
  _EventFormScreenState createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  final Color primaryColor = Color(0xFF8B0000);
  final Color backgroundColor = Colors.black;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _dateController.text = widget.event!.date;
      _locationController.text = widget.event!.location;
      _descriptionController.text = widget.event!.description;
      _priceController.text = widget.event!.price.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _saveEvent() async {
    final title = _titleController.text.trim();
    final date = _dateController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (title.isNotEmpty && date.isNotEmpty && location.isNotEmpty && description.isNotEmpty) {
      final eventRef = FirebaseFirestore.instance.collection('events');
      if (widget.event == null) {
        await eventRef.add({
          'title': title,
          'date': date,
          'location': location,
          'description': description,
          'price': price,
        });
      } else {
        await eventRef.doc(widget.event!.id).update({
          'title': title,
          'date': date,
          'location': location,
          'description': description,
          'price': price,
        });
      }
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: primaryColor),
      borderRadius: BorderRadius.circular(4),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.event == null ? 'Novo Evento' : 'Editar Evento'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: TextStyle(color: Colors.white),
                border: inputBorder,
                focusedBorder: inputBorder,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _dateController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Data',
                labelStyle: TextStyle(color: Colors.white),
                border: inputBorder,
                focusedBorder: inputBorder,
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: primaryColor),
                  onPressed: _selectDate,
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _locationController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Local',
                labelStyle: TextStyle(color: Colors.white),
                border: inputBorder,
                focusedBorder: inputBorder,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Descrição',
                labelStyle: TextStyle(color: Colors.white),
                border: inputBorder,
                focusedBorder: inputBorder,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _priceController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Preço',
                labelStyle: TextStyle(color: Colors.white),
                border: inputBorder,
                focusedBorder: inputBorder,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
