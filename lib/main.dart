import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:formvalidatorapp/page_view_inputs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

//
// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: ReportFormPage(),
// //     );
// //   }
// // }
//
// class ReportFormPage extends StatefulWidget {
//   @override
//   _ReportFormPageState createState() => _ReportFormPageState();
// }
//
// class _ReportFormPageState extends State<ReportFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   final SignatureController _customerSignatureController =
//       SignatureController(penStrokeWidth: 2, penColor: Colors.black);
//   final SignatureController _technicianSignatureController =
//       SignatureController(penStrokeWidth: 2, penColor: Colors.black);
//
//   // Form fields
//   String? _date;
//   String? _time;
//   String? _technician;
//   String? _customer;
//   String? _location;
//   String? _material;
//   String? _ae1;
//   String? _ae2;
//   String? _description;
//   String? _remark;
//
//   bool get isCustomerSigned => !_customerSignatureController.isEmpty;
//
//   // Technician dropdown options
//   List<String> technicians = ["Technician A", "Technician B", "Technician C"];
//
//   // Email address to send the form
//   String targetEmail = "company@example.com";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Bericht: Arbeits- / Materialnachweis"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             padding: EdgeInsets.only(top: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               spacing: 30,
//               children: [
//                 _buildDatePickerField("Datum", (value) => _date = value),
//                 _buildTimePickerField("Tageszeit", (value) => _time = value),
//                 _buildDropdown(
//                     "Techniker", technicians, (value) => _technician = value),
//                 _buildTextField("Kunde", (value) => _customer = value),
//                 _buildTextField("Standort", (value) => _location = value),
//                 _buildTextField("Material", (value) => _material = value),
//                 _buildTextField("AE 1", (value) => _ae1 = value),
//                 _buildTextField("AE 2", (value) => _ae2 = value),
//                 _buildTextField("Beschreibung", (value) => _description = value,
//                     maxLines: 3),
//                 _buildTextField("Bemerkung", (value) => _remark = value,
//                     maxLines: 3),
//                 SizedBox(height: 16),
//                 Text("Unterschrift des Technikers:"),
//                 _buildSignaturePad(_technicianSignatureController),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       _technicianSignatureController.clear();
//                     });
//                   },
//                   child: Text("Unterschrift des Technikers löschen"),
//                 ),
//                 SizedBox(height: 16),
//                 Text("Unterschrift des Kunden:"),
//                 _buildSignaturePad(_customerSignatureController),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       _customerSignatureController.clear();
//                     });
//                   },
//                   child: Text("Kundensignatur löschen"),
//                 ),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: isCustomerSigned ? _sendForm : null,
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                           isCustomerSigned ? Colors.blue : Colors.grey,
//                       textStyle: TextStyle(color: Colors.white)),
//                   child: Text("Schicken"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDatePickerField(String label, Function(String?) onSaved) {
//     return TextFormField(
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(),
//       ),
//       readOnly: true,
//       onTap: () async {
//         DateTime? pickedDate = await showDatePicker(
//           context: context,
//           initialDate: DateTime.now(),
//           firstDate: DateTime(2000),
//           lastDate: DateTime(2100),
//         );
//         if (pickedDate != null) {
//           setState(() {
//             _date = "${pickedDate.toLocal()}".split(' ')[0];
//           });
//         }
//       },
//       controller: TextEditingController(text: _date),
//       onSaved: onSaved,
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please select a $label';
//         }
//         return null;
//       },
//     );
//   }
//
//   Widget _buildTimePickerField(String label, Function(String?) onSaved) {
//     return TextFormField(
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(),
//       ),
//       readOnly: true,
//       onTap: () async {
//         TimeOfDay? pickedTime = await showTimePicker(
//           context: context,
//           initialTime: TimeOfDay.now(),
//         );
//         if (pickedTime != null) {
//           setState(() {
//             _time = pickedTime.format(context);
//           });
//         }
//       },
//       controller: TextEditingController(text: _time),
//       onSaved: onSaved,
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please select a $label';
//         }
//         return null;
//       },
//     );
//   }
//
//   Widget _buildTextField(String label, Function(String?) onSaved,
//       {int maxLines = 1}) {
//     return TextFormField(
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(),
//       ),
//       onSaved: onSaved,
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please enter $label';
//         }
//         return null;
//       },
//       maxLines: maxLines,
//     );
//   }
//
//   Widget _buildDropdown(
//       String label, List<String> items, Function(String?) onChanged) {
//     return DropdownButtonFormField<String>(
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(),
//       ),
//       items: items
//           .map((item) => DropdownMenuItem(
//                 value: item,
//                 child: Text(item),
//               ))
//           .toList(),
//       onChanged: onChanged,
//       validator: (value) => value == null ? 'Please select $label' : null,
//     );
//   }
//
//   Widget _buildSignaturePad(SignatureController controller) {
//     return Container(
//       height: 150,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//       ),
//       child: Signature(
//         controller: controller,
//         backgroundColor: Colors.white,
//       ),
//     );
//   }
//
//   Future<void> _sendForm() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       _formKey.currentState?.save();
//
//       // TODO: Generate PDF and send via email
//
//       final email = Email(
//         body: 'Form details attached.',
//         subject: 'Report Form Submission',
//         recipients: [targetEmail],
//         isHTML: false,
//       );
//
//       print('Email Send');
//
//       await FlutterEmailSender.send(email);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Form sent successfully!")),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _customerSignatureController.dispose();
//     _technicianSignatureController.dispose();
//     super.dispose();
//   }
// }
