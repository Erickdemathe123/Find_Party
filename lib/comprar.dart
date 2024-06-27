import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CompraPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red, // Cor primária
        hintColor: Colors.redAccent, // Cor de destaque
        fontFamily: 'Roboto', // Fonte padrão
      ),
    );
  }
}

class CompraPage extends StatefulWidget {
  @override
  _CompraPageState createState() => _CompraPageState();
}

class _CompraPageState extends State<CompraPage> {
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _cardNameController = TextEditingController();
  TextEditingController _cardMonthController = TextEditingController();
  TextEditingController _cardYearController = TextEditingController();
  TextEditingController _cardCvvController = TextEditingController();

  String _selectedPaymentMethod = 'Cartão de Crédito';
  String _pixKey = '';

  @override
  void initState() {
    super.initState();
    _generatePixKey();
  }

  void _generatePixKey() {
    // Geração de chave PIX aleatória
    Random random = Random();
    String key = '';
    for (int i = 0; i < 20; i++) {
      key += random.nextInt(10).toString();
    }
    setState(() {
      _pixKey = key;
    });
  }

  String? _validateCardNumber(String? value) {
    if (value?.length != 16) {
      return 'Número do cartão inválido';
    }
    return null;
  }

  String? _validateMonth(String? value) {
    if (value?.isEmpty ?? true || int.tryParse(value!) == null || int.parse(value) < 1 || int.parse(value) > 12) {
      return 'Mês inválido';
    }
    return null;
  }

  String? _validateYear(String? value) {
    if (value?.isEmpty ?? true || int.tryParse(value!) == null || int.parse(value) < 21) {
      return 'Ano inválido';
    }
    return null;
  }

  String? _validateCVV(String? value) {
    if (value?.length != 3) {
      return 'CVV inválido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finalizar Compra'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3.0,
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Método de Pagamento',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedPaymentMethod,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedPaymentMethod = newValue!;
                          if (_selectedPaymentMethod == 'PIX') {
                            _generatePixKey(); // Regenerate PIX key if PIX is selected
                          }
                        });
                      },
                      items: <String>['Cartão de Crédito', 'PIX']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20.0),
                    if (_selectedPaymentMethod == 'Cartão de Crédito')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Número do Cartão',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextFormField(
                            controller: _cardNumberController,
                            decoration: InputDecoration(
                              hintText: '0000 0000 0000 0000',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(16),
                            ],
                            validator: _validateCardNumber,
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Nome Completo',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextFormField(
                            controller: _cardNameController,
                            decoration: InputDecoration(
                              hintText: 'Nome Sobrenome',
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Nome inválido';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Validade',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _cardMonthController,
                                            decoration: InputDecoration(
                                              hintText: 'MM',
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(2),
                                            ],
                                            validator: _validateMonth,
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _cardYearController,
                                            decoration: InputDecoration(
                                              hintText: 'AA',
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(4),
                                            ],
                                            validator: _validateYear,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CVC',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _cardCvvController,
                                      decoration: InputDecoration(
                                        hintText: 'CVC',
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(3),
                                      ],
                                      validator: _validateCVV,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    if (_selectedPaymentMethod == 'PIX')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chave PIX',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextFormField(
                            initialValue: _pixKey,
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: 'Chave PIX gerada',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                if (_selectedPaymentMethod == 'Cartão de Crédito') {
                  if (_cardNumberController.text.length == 16 &&
                      _cardNameController.text.isNotEmpty &&
                      _cardMonthController.text.isNotEmpty &&
                      _cardYearController.text.isNotEmpty &&
                      _cardCvvController.text.length == 3) {
                    _showConfirmationDialog();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Por favor, preencha todos os campos corretamente')),
                    );
                  }
                } else {
                  _showConfirmationDialog();
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).hintColor),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(15.0)),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: Text(
                'Finalizar Compra',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => UserEventListScreen()),
                  ModalRoute.withName('/'),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(15.0)),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmação de Compra'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Método de Pagamento: $_selectedPaymentMethod'),
              if (_selectedPaymentMethod == 'Cartão de Crédito')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Número do Cartão: ${_cardNumberController.text}'),
                    Text('Nome Completo: ${_cardNameController.text}'),
                    Text('Validade: ${_cardMonthController.text}/${_cardYearController.text}'),
                    Text('CVC: ${_cardCvvController.text}'),
                  ],
                ),
              if (_selectedPaymentMethod == 'PIX')
                Text('Chave PIX: $_pixKey'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
