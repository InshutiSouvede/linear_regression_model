import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salary Prediction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Color(0xFFF3F3F3),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.deepPurple),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 16, horizontal: 32)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
        ),
      ),
      home: const SalaryPredictionScreen(),
    );
  }
}

class SalaryPredictionScreen extends StatefulWidget {
  const SalaryPredictionScreen({super.key});
  @override
  State<SalaryPredictionScreen> createState() => _SalaryPredictionScreenState();
}

class _SalaryPredictionScreenState extends State<SalaryPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    "Age": 30,
    "Job_Title": "Manager",
    "Education_Level": "Bachelor",
    "Performance_Score": 3,
    "Work_Hours_Per_Week": 40.0,
    "Projects_Handled": 5,
    "Overtime_Hours": 10.0,
    "Sick_Days": 2,
    "Team_Size": 5,
    "Promotions": 1,
  };

  bool _loading = false;
  String? _result;
  String? _error;

  final List<String> jobTitles = [
    'Specialist', 'Developer', 'Analyst', 'Manager', 'Technician', 'Engineer', 'Consultant'
  ];
  final List<String> educationLevels = [
    'High School', 'Bachelor', 'Master', 'PhD'
  ];

  Future<void> _predictSalary() async {
    setState(() {
      _loading = true;
      _result = null;
      _error = null;
    });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_formData),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _result =
              "Predicted Salary: ${data['salary'].toStringAsFixed(2)}\n"
              "${data['confidence_interval'] != null ? "Confidence Interval: ${data['confidence_interval'][0].toStringAsFixed(2)} - ${data['confidence_interval'][1].toStringAsFixed(2)}" : ""}";
        });
      } else {
        setState(() {
          _error = jsonDecode(response.body)['detail'] ?? "Unknown error";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to connect to API: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildDropdown(String label, String key, List<String> items) {
    return DropdownButtonFormField<String>(
      value: _formData[key],
      decoration: InputDecoration(labelText: label),
      items: items.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
      onChanged: (v) => setState(() => _formData[key] = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildIntField(String label, String key, int min, int max) {
    return TextFormField(
      initialValue: _formData[key].toString(),
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      onChanged: (v) => _formData[key] = int.tryParse(v) ?? min,
      validator: (v) {
        final val = int.tryParse(v ?? '');
        if (val == null || val < min || val > max) {
          return 'Enter a value between $min and $max';
        }
        return null;
      },
    );
  }

  Widget _buildDoubleField(String label, String key, double min, double max) {
    return TextFormField(
      initialValue: _formData[key].toString(),
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      onChanged: (v) => _formData[key] = double.tryParse(v) ?? min,
      validator: (v) {
        final val = double.tryParse(v ?? '');
        if (val == null || val < min || val > max) {
          return 'Enter a value between $min and $max';
        }
        return null;
      },
    );
  }

  List<Widget> _buildFormFields() {
    return [
      _buildIntField("Age", "Age", 18, 70),
      _buildDropdown("Job Title", "Job_Title", jobTitles),
      _buildDropdown("Education Level", "Education_Level", educationLevels),
      _buildIntField("Performance Score (1-5)", "Performance_Score", 1, 5),
      _buildDoubleField("Work Hours Per Week", "Work_Hours_Per_Week", 10, 80),
      _buildIntField("Projects Handled", "Projects_Handled", 0, 50),
      _buildDoubleField("Overtime Hours", "Overtime_Hours", 0, 200),
      _buildIntField("Sick Days", "Sick_Days", 0, 50),
      _buildIntField("Team Size", "Team_Size", 1, 50),
      _buildIntField("Promotions", "Promotions", 0, 20),
    ];
  }

  Widget _buildResponsiveFormFields() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 768;
    final formFields = _buildFormFields();

    if (!isWide) {
      // Single column layout for smaller screens
      return Column(
        children: formFields
            .map((field) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: field,
                ))
            .toList(),
      );
    }

    // Two-column layout for larger screens
    List<Widget> rows = [];
    for (int i = 0; i < formFields.length; i += 2) {
      Widget leftField = Expanded(child: formFields[i]);
      Widget rightField = i + 1 < formFields.length 
          ? Expanded(child: formFields[i + 1])
          : const Expanded(child: SizedBox());

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              leftField,
              const SizedBox(width: 16),
              rightField,
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxCardWidth = screenWidth > 1200 ? 900.0 : 
                       screenWidth > 768 ? screenWidth * 0.85 : 
                       screenWidth * 0.95;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Prediction'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxCardWidth),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth > 600 ? 24 : 16, 
            vertical: 24
          ),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: EdgeInsets.all(screenWidth > 600 ? 32.0 : 20.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Enter Employee Details",
                        style: TextStyle(
                          fontSize: screenWidth > 600 ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildResponsiveFormFields(),
                      const SizedBox(height: 32),
                      Center(
                        child: SizedBox(
                          width: screenWidth > 768 ? 300 : double.infinity,
                          child: ElevatedButton.icon(
                            icon: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.calculate),
                            label: const Text('Predict Salary', style: TextStyle(fontSize: 18)),
                            onPressed: _loading
                                ? null
                                : () {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      _predictSalary();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_result != null)
                        Card(
                          color: Colors.green[50],
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Text(
                              _result!,
                              style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      if (_error != null)
                        Card(
                          color: Colors.red[50],
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Text(
                              _error!,
                              style: const TextStyle(fontSize: 18, color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}