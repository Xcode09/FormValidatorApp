import 'dart:io';
import 'dart:math';

import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formvalidatorapp/pdf_genrator.dart';
import 'package:formvalidatorapp/settings.dart';

import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:mailer/smtp_server.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'golbal_variables.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home:
            StepFormPage() //SfPdfViewer.asset('assets/Formular Bericht - 2025.pdf'),
        );
  }
}

class StepFormPage extends StatefulWidget {
  @override
  _StepFormPageState createState() => _StepFormPageState();
}

class _StepFormPageState extends State<StepFormPage> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final SignatureController _customerSignatureController =
      SignatureController(penStrokeWidth: 2, penColor: Colors.black);
  final SignatureController _technicianSignatureController =
      SignatureController(penStrokeWidth: 2, penColor: Colors.black);

  final _pdfController = PdfViewerController();
  final smtp = SmtpServer('smtp.gmail.com',
      username: 'alisaleem877@gmail.com',
      password: 'cnsh ezei nebd hkek',
      port: 465,
      ssl: true);

  // Form fields
  String? _date;
  String? _time;
  String? _technician;
  String? _customer;
  String? _location;
  String? _material;
  String? _ae1;
  String? _ae2;
  int _currentPage = 0;

  bool isSmtpServerSecure = true;

  bool isLoading = false;

  void _previousPage() {
    print(_currentPage);
    print('Previous Page');

    if (_currentPage > 0) {
      setState(() {
        _currentPage--; // Decrement the current page
      });
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Low level SMTP API example
  Future<void> smtpExample(File pdfFile) async {
    await _loadSettings();
    // final pdfFile = await _generatePdf();
    setState(() {
      isLoading = true;
    });
    if (smtpServerHost.isNotEmpty &&
        userName.isNotEmpty &&
        password.isNotEmpty &&
        recipients.isNotEmpty) {
      final client = SmtpClient('ionos.de', isLogEnabled: true);
      try {
        await client.connectToServer(smtpServerHost, smtpServerPort,
            isSecure: isSmtpServerSecure);
        await client.ehlo();
        if (client.serverInfo.supportsAuth(AuthMechanism.plain)) {
          await client.authenticate(userName, password, AuthMechanism.plain);
        } else if (client.serverInfo.supportsAuth(AuthMechanism.login)) {
          await client.authenticate(userName, password, AuthMechanism.login);
        } else {
          return;
        }
        // generate and send email:
        final mimeMessage = await buildMessageWithAttachment(pdfFile);
        final sendResponse = await client.sendMessage(mimeMessage);
        print('message sent: ${sendResponse.isOkStatus}');
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An Ihre E-Mail gesendet'),
          ),
        );
        final newPath = await PDFGE().createAndSaveEditablePDF();
        setState(() {
          filePath = newPath;
        });
      } on SmtpException catch (e) {
        print('SMTP failed with $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Bitte fügen Sie die SMTP-Details im Einstellungsbildschirm hinzu'),
        ),
      );
    }
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      technicians = prefs.getStringList('technicians') ?? [];
      recipients = prefs.getStringList('recipients') ?? [];
      smtpServerHost = prefs.getString('smtpServer') ?? "";
      smtpServerPort = prefs.getInt('smtpPort') ?? 0;
      userName = prefs.getString('smtpUser') ?? "";
      password = prefs.getString('smtpPassword') ?? "";
    });
  }

  String filePath = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((call) async {
      final path = await PDFGE().createAndSaveEditablePDF();
      setState(() {
        filePath = path;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Formular Bericht - 2025"),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SettingsScreen();
                }));
              },
              icon: Icon(Icons.settings))
        ],
      ),
      body: filePath.isNotEmpty
          ? Stack(
              children: [
                SfPdfViewer.file(
                  File(filePath),
                  controller: _pdfController,
                ),
              ],
            )
          : CircularProgressIndicator(),
      floatingActionButton: MaterialButton(
        onPressed: _nextPage,
        color: HexColor.fromHex('#86d008'),
        textColor: Colors.white,
        child: _loadingChecker(),
        padding: EdgeInsets.all(16),
        shape: CircleBorder(),
      ),
    );
  }

  Widget _loadingChecker() {
    if (isLoading == true) {
      return CircularProgressIndicator();
    } else {
      return Image.asset(
        'assets/images/email.png',
        width: 35,
        height: 35,
      );
    }
  }

  void _nextPage() async {
    List<int> saveData = await _pdfController.saveDocument();
    final path = await PDFGE()
        .saveDocumentInStorage(saveData, 'Formular Bericht - 2025.pdf');

    smtpExample(File(path));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<MimeMessage> buildMessageWithAttachment(File pdf) async {
    final builder = MessageBuilder()
      ..from = [
        const MailAddress('Bericht: Arbeits Materialnachweis',
            'berichte-br@baumgartner-rath.de')
      ]
      ..to = recipients.map((element) {
        return MailAddress('', element);
      }).toList();
    await builder.addFile(pdf, MediaSubtype.applicationPdf.mediaType);
    return builder.buildMimeMessage();
  }
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
