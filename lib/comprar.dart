import 'dart:math';
import 'package:find_party/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Método de Pagamento',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 10.0),
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
                              fontSize: 16.0,
                            ),
                          ),
                        );
                      }).toList(),
                      isExpanded: true,
                    ),
                    SizedBox(height: 20.0),
                    if (_selectedPaymentMethod == 'Cartão de Crédito')
                      _buildCreditCardForm(),
                    if (_selectedPaymentMethod == 'PIX')
                      _buildPixKeyField(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _onFinalizePurchase,
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

  Widget _buildCreditCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Número do Cartão',
          controller: _cardNumberController,
          hint: '0000 0000 0000 0000',
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          validator: _validateCardNumber,
        ),
        SizedBox(height: 10.0),
        _buildTextField(
          label: 'Nome Completo',
          controller: _cardNameController,
          hint: 'Nome Sobrenome',
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
              child: _buildTextField(
                label: 'Validade (MM)',
                controller: _cardMonthController,
                hint: 'MM',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                validator: _validateMonth,
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: _buildTextField(
                label: 'Validade (AAAA)',
                controller: _cardYearController,
                hint: 'AAAA',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: _validateYear,
              ),
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: _buildTextField(
                label: 'CVC',
                controller: _cardCvvController,
                hint: 'CVC',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: _validateCVV,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPixKeyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chave PIX',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 10.0),
        TextFormField(
          initialValue: _pixKey,
          enabled: false,
          decoration: InputDecoration(
            hintText: 'Chave PIX gerada',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12.0),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 5.0),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12.0),
          ),
          inputFormatters: inputFormatters,
          validator: validator,
        ),
      ],
    );
  }

  void _onFinalizePurchase() {
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
