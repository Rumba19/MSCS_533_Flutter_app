import 'package:flutter/material.dart';

void main() {
  runApp(const MeasuresConverterApp());
}

class MeasuresConverterApp extends StatelessWidget {
  const MeasuresConverterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Measures Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ConverterScreen(),
    );
  }
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({Key? key}) : super(key: key);

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _valueController = TextEditingController();
  String _fromUnit = 'meters';
  String _toUnit = 'feet';
  String _result = '';

  final Map<String, Map<String, double>> _conversionRates = {
    // Length conversions (base: meters)
    'meters': {'meters': 1, 'feet': 3.28084, 'kilometers': 0.001, 'miles': 0.000621371, 'inches': 39.3701, 'yards': 1.09361},
    'feet': {'meters': 0.3048, 'feet': 1, 'kilometers': 0.0003048, 'miles': 0.000189394, 'inches': 12, 'yards': 0.333333},
    'kilometers': {'meters': 1000, 'feet': 3280.84, 'kilometers': 1, 'miles': 0.621371, 'inches': 39370.1, 'yards': 1093.61},
    'miles': {'meters': 1609.34, 'feet': 5280, 'kilometers': 1.60934, 'miles': 1, 'inches': 63360, 'yards': 1760},
    'inches': {'meters': 0.0254, 'feet': 0.0833333, 'kilometers': 0.0000254, 'miles': 0.000015783, 'inches': 1, 'yards': 0.0277778},
    'yards': {'meters': 0.9144, 'feet': 3, 'kilometers': 0.0009144, 'miles': 0.000568182, 'inches': 36, 'yards': 1},
    
    // Weight conversions (base: kilograms)
    'kilograms': {'kilograms': 1, 'pounds': 2.20462, 'ounces': 35.274, 'grams': 1000},
    'pounds': {'kilograms': 0.453592, 'pounds': 1, 'ounces': 16, 'grams': 453.592},
    'ounces': {'kilograms': 0.0283495, 'pounds': 0.0625, 'ounces': 1, 'grams': 28.3495},
    'grams': {'kilograms': 0.001, 'pounds': 0.00220462, 'ounces': 0.035274, 'grams': 1},
    
    // Temperature (handled separately)
    'celsius': {'celsius': 1, 'fahrenheit': 0, 'kelvin': 0},
    'fahrenheit': {'celsius': 0, 'fahrenheit': 1, 'kelvin': 0},
    'kelvin': {'celsius': 0, 'fahrenheit': 0, 'kelvin': 1},
  };

  final List<String> _allUnits = [
    'meters', 'feet', 'kilometers', 'miles', 'inches', 'yards',
    'kilograms', 'pounds', 'ounces', 'grams',
    'celsius', 'fahrenheit', 'kelvin',
  ];

  void _convert() {
    final double? value = double.tryParse(_valueController.text);
    if (value == null) {
      setState(() {
        _result = 'Please enter a valid number';
      });
      return;
    }

    double converted;
    
    // Special handling for temperature
    if (_fromUnit == 'celsius' || _fromUnit == 'fahrenheit' || _fromUnit == 'kelvin') {
      converted = _convertTemperature(value, _fromUnit, _toUnit);
    } else {
      // Check if conversion is valid
      if (!_conversionRates.containsKey(_fromUnit) || 
          !_conversionRates[_fromUnit]!.containsKey(_toUnit)) {
        setState(() {
          _result = 'Cannot convert between these units';
        });
        return;
      }
      converted = value * _conversionRates[_fromUnit]![_toUnit]!;
    }

    setState(() {
      _result = '${value.toStringAsFixed(1)} $_fromUnit = ${converted.toStringAsFixed(3)} $_toUnit';
    });
  }

  double _convertTemperature(double value, String from, String to) {
    if (from == to) return value;
    
    // Convert to Celsius first
    double celsius;
    if (from == 'celsius') {
      celsius = value;
    } else if (from == 'fahrenheit') {
      celsius = (value - 32) * 5 / 9;
    } else {
      celsius = value - 273.15;
    }
    
    // Convert from Celsius to target
    if (to == 'celsius') {
      return celsius;
    } else if (to == 'fahrenheit') {
      return celsius * 9 / 5 + 32;
    } else {
      return celsius + 273.15;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measures Converter'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Value',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'From',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _fromUnit,
              isExpanded: true,
              items: _allUnits.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _fromUnit = newValue!;
                  _result = '';
                });
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'To',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _toUnit,
              isExpanded: true,
              items: _allUnits.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _toUnit = newValue!;
                  _result = '';
                });
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _convert,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Convert',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _result,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }
}