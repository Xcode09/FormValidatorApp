import 'dart:io';

import 'package:flutter/material.dart';
import 'package:formvalidatorapp/golbal_variables.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // List<String> _technicians = [];
  // String _smtpServer = "";
  // int _smtpPort = 0;
  // String _smtpUser = "";
  // String _smtpPassword = "";
  TextEditingController _technicianController = TextEditingController();
  TextEditingController _recController = TextEditingController();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((call) async {
      await _loadSettings();
      _saveSettings();
    });
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      technicians = prefs.getStringList('technicians') ?? [];
      recipients = prefs.getStringList('recipients') ?? [];
      smtpServerHost = prefs.getString('smtpServer') ?? "smtp.ionos.de";
      smtpServerPort = prefs.getInt('smtpPort') ?? 465;
      userName =
          prefs.getString('smtpUser') ?? "berichte-br@baumgartner-rath.de";
      password = prefs.getString('smtpPassword') ?? "hhfi67-sT#23CC";
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('technicians', technicians);
    await prefs.setStringList('recipients', recipients);
    await prefs.setString('smtpServer', smtpServerHost);
    await prefs.setInt('smtpPort', smtpServerPort);
    await prefs.setString('smtpUser', userName);
    await prefs.setString('smtpPassword', password);
  }

  void _addTechnician() {
    if (_technicianController.text.isNotEmpty &&
        !technicians.contains(_technicianController.text)) {
      setState(() {
        technicians.add(_technicianController.text);
        _saveSettings();
      });
      _technicianController.clear();
    }
  }

  void _addRecipient() {
    if (_recController.text.isNotEmpty &&
        !recipients.contains(_recController.text)) {
      setState(() {
        recipients.add(_recController.text);
        _saveSettings();
      });
      _recController.clear();
    }
  }

  void _deleteTechnician(String technician) {
    setState(() {
      technicians.remove(technician);
      _saveSettings();
    });
  }

  void _deleteReciptiant(String rec) {
    setState(() {
      recipients.remove(rec);
      _saveSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Settings'),
      //   backgroundColor: Colors.red,
      // ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'), // Path to your image
                fit: BoxFit.cover, // Ensures the image covers the entire screen
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 24,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 20.0),
                  // const Text(
                  //   'Techniker:',
                  //   style: TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.white,
                  //       fontSize: 18),
                  // ),
                  // ListView.builder(
                  //   shrinkWrap: true,
                  //   itemCount: technicians.length,
                  //   padding: EdgeInsets.zero,
                  //   itemBuilder: (context, index) {
                  //     return ListTile(
                  //       title: Text(
                  //         technicians[index],
                  //         style: TextStyle(color: Colors.white, fontSize: 18),
                  //       ),
                  //       trailing: IconButton(
                  //         icon: const Icon(
                  //           Icons.delete,
                  //           color: Colors.red,
                  //         ),
                  //         onPressed: () =>
                  //             _deleteTechnician(technicians[index]),
                  //       ),
                  //     );
                  //   },
                  // ),
                  // const SizedBox(height: 16.0),
                  // TextField(
                  //   controller: _technicianController,
                  //   decoration: InputDecoration(
                  //     hintText: 'Techniker hinzufügen:',
                  //     fillColor: Colors.white,
                  //     focusColor: Colors.white,
                  //     filled: true,
                  //     border: OutlineInputBorder(borderSide: BorderSide.none),
                  //   ),
                  // ),
                  // const SizedBox(height: 16.0),
                  // ElevatedButton(
                  //   onPressed: _addTechnician,
                  //   child: const Text('Hinzufügen',
                  //       style: TextStyle(fontSize: 18)),
                  // ),
                  // const SizedBox(height: 32.0),
                  const Text(
                    'Empfänger',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: recipients.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          recipients[index],
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _deleteReciptiant(recipients[index])),
                      );
                    },
                  ),
                  TextField(
                    controller: _recController,
                    decoration: InputDecoration(
                      hintText: 'Empfänger hinzufügen:',
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _addRecipient,
                    child: const Text('Hinzufügen',
                        style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 32.0),
                  const Text(
                    'SMTP Server:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18),
                  ),
                  const SizedBox(height: 16.0),
                  _buildTextFormField('Server', smtpServerHost),
                  const SizedBox(height: 16.0),
                  _buildTextFormField('Port', smtpServerPort.toString()),
                  const SizedBox(height: 16.0),
                  _buildTextFormField('Username', userName),
                  const SizedBox(height: 16.0),
                  _buildTextFormField('Password', password, obscureText: true),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _addTechnician,
                    child: const Text('SMTP speichern'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(String label, String initialValue,
      {bool obscureText = false}) {
    return TextFormField(
      initialValue: initialValue,
      obscureText: obscureText,
      decoration: InputDecoration(
        //labelText: label,
        hintText: label,
        fillColor: Colors.white,
        focusColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
      onChanged: (value) {
        setState(() {
          if (label == 'Server') {
            smtpServerHost = value;
          } else if (label == 'Port') {
            smtpServerPort = int.tryParse(value) ?? 0;
          } else if (label == 'Username') {
            userName = value;
          } else if (label == 'Password') {
            password = value;
          }
          _saveSettings(); // Save settings on every change
        });
      },
    );
  }
}
