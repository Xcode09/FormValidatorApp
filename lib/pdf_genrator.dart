import 'dart:core';
import 'dart:typed_data';
import 'package:flutter/services.dart' show Offset, Rect, rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PDFGE {
  Future<String> createAndSaveEditablePDF() async {
    // Create a PDF document
    final PdfDocument document = PdfDocument();
    PdfPage page = document.pages.add();
    PdfGraphics graphics = page.graphics;
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 14);

    double yPosition = 20;
    double xPosition = 0;

    // // Title
    // graphics.drawString("Formular Bericht - 2025",
    //     PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold),
    //     bounds: Rect.fromLTWH(20, yPosition, 500, 30));
    yPosition += 50;

    // Load and draw an image on the left side
    final ByteData imageData = await rootBundle
        .load('assets/images/Screenshot 2025-01-29 at 12.19.11.png');
    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final PdfBitmap image = PdfBitmap(imageBytes);
    graphics.drawImage(image, Rect.fromLTWH(xPosition, yPosition, 300, 100));

    // Create editable form fields on the right side
    double formFieldStartX = 340;
    double formFieldWidth = 200;
    PdfTextBoxField dateField = PdfTextBoxField(document.pages[0], 'Datum',
        Rect.fromLTWH(formFieldStartX, yPosition, formFieldWidth, 30));
    dateField.text = "Datum";
    dateField.font = font;
    document.form.fields.add(dateField);
    yPosition += 30;

    PdfTextBoxField timeField = PdfTextBoxField(document.pages[0], 'Uhrzeit',
        Rect.fromLTWH(formFieldStartX, yPosition, formFieldWidth, 30));
    timeField.text = "Uhrzeit";
    timeField.font = font;
    document.form.fields.add(timeField);
    yPosition += 30;

    PdfTextBoxField technicianField = PdfTextBoxField(
        document.pages[0],
        'Techniker',
        Rect.fromLTWH(formFieldStartX, yPosition, formFieldWidth, 30));
    technicianField.text = "Techniker";
    technicianField.font = font;
    document.form.fields.add(technicianField);
    yPosition += 60;

    final double pageWidth = page.getClientSize().width;
    final double textWidth =
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold)
            .measureString("Bericht: Arbeits- / Materialnachweis")
            .width;
    final double centerX = (pageWidth - textWidth) / 2;

    graphics.drawString("Bericht: Arbeits- / Materialnachweis",
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(centerX, yPosition, textWidth, 30));
    yPosition += 30;

    PdfTextBoxField customerField = PdfTextBoxField(document.pages[0], 'Kunde',
        Rect.fromLTWH(xPosition, yPosition, pageWidth / 2, 30),
        borderStyle: PdfBorderStyle.underline);
    customerField.text = "Kunde";
    customerField.font = font;
    document.form.fields.add(customerField);

    PdfTextBoxField lField = PdfTextBoxField(document.pages[0], 'Ort',
        Rect.fromLTWH(pageWidth / 2, yPosition, 260, 30),
        borderStyle: PdfBorderStyle.underline);
    lField.text = "Ort";
    lField.font = font;
    document.form.fields.add(lField);

    yPosition += 50;

    PdfTextBoxField emailField = PdfTextBoxField(document.pages[0], 'Email',
        Rect.fromLTWH(xPosition, yPosition, pageWidth, 30),
        borderStyle: PdfBorderStyle.underline);
    emailField.text = "Email Address";
    emailField.font = font;
    document.form.fields.add(emailField);
    yPosition += 40;

    // Material Section with Editable Fields in 2 Columns
    graphics.drawString("Material:",
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(xPosition, yPosition, 500, 30));
    yPosition += 20;

    double leftColumnX = 0;
    double rightColumnX = 280;
    double rowHeight = 30;
    for (int i = 0; i < 4; i++) {
      PdfTextBoxField materialFieldLeft = PdfTextBoxField(document.pages[0],
          'Material_Left_$i', Rect.fromLTWH(leftColumnX, yPosition, 250, 30),
          borderStyle: PdfBorderStyle.underline);
      materialFieldLeft.text = "${i + 1}";
      materialFieldLeft.font = font;
      document.form.fields.add(materialFieldLeft);

      PdfTextBoxField materialFieldRight = PdfTextBoxField(document.pages[0],
          'Material_Right_$i', Rect.fromLTWH(rightColumnX, yPosition, 250, 30),
          borderStyle: PdfBorderStyle.underline);
      materialFieldRight.text = "${i + 5}";
      materialFieldRight.font = font;
      document.form.fields.add(materialFieldRight);

      yPosition += rowHeight;
    }
    yPosition += 20;
    // Draw table headers (Bold Text)
    graphics.drawString("AE1",
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(xPosition, yPosition, 100, 30));
    graphics.drawString("AE2",
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(80, yPosition, 100, 30));
    graphics.drawString("Beschreibung",
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(240, yPosition, 280, 30));
    yPosition += 20; // Move to the next row

// Create 8 editable rows
    for (int i = 0; i < 8; i++) {
      PdfTextBoxField ae1Field = PdfTextBoxField(document.pages[0], 'AE1_$i',
          Rect.fromLTWH(xPosition, yPosition, 60, 30));
      ae1Field.text = "";
      ae1Field.font = PdfStandardFont(PdfFontFamily.helvetica, 12);
      // ae1Field.borderColor = PdfColor(0, 0, 0); // Black border
      // ae1Field.backColor = PdfColor(1, 1, 1); // White background
      document.form.fields.add(ae1Field);

      PdfTextBoxField ae2Field = PdfTextBoxField(
          document.pages[0], 'AE2_$i', Rect.fromLTWH(65, yPosition, 60, 30));
      ae2Field.text = "";
      ae2Field.font = PdfStandardFont(PdfFontFamily.helvetica, 12);
      // ae2Field.borderColor = PdfColor(0, 0, 0);
      // ae2Field.backColor = PdfColor(1, 1, 1);
      document.form.fields.add(ae2Field);

      PdfTextBoxField beschreibungField = PdfTextBoxField(
          document.pages[0],
          'Beschreibung_$i',
          Rect.fromLTWH(130, yPosition, pageWidth - 100, 30));
      beschreibungField.text = "";
      beschreibungField.font = PdfStandardFont(PdfFontFamily.helvetica, 12);
      // beschreibungField.borderColor = PdfColor(0, 0, 0);
      // beschreibungField.backColor = PdfColor(1, 1, 1);
      document.form.fields.add(beschreibungField);

      yPosition += 30; // Move to the next row
    }
    yPosition += 20;

    // _checkPageOverflow(document, yPosition);
    //document.pages.add();

    page = _ensurePageSpace(document, page, yPosition);
    graphics = page.graphics; // Update graphics for the new page

    // Move down to create space for the next section
    yPosition = 30;

    PdfTextBoxField remarksField = PdfTextBoxField(
        page, 'Bemerkung', Rect.fromLTWH(xPosition, yPosition, 500, 50),
        borderStyle: PdfBorderStyle.underline);
    remarksField.text = "Bemerkung";
    remarksField.font = font;
    document.form.fields.add(remarksField);
    // // Draw only the bottom line
    // graphics.drawLine(
    //     PdfPen(PdfColor(0, 0, 0), width: 1), // Black line with 1px thickness
    //     Offset(20, yPosition + 30), // Start of the line
    //     Offset(
    //         page.getClientSize().width - 20, yPosition + 30) // End of the line
    // );

    yPosition += 60;

// Draw section headers
    graphics.drawString("Unterschrift Techniker:",
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(xPosition, yPosition, 200, 20));

    graphics.drawString("Stempel / Unterschrift:",
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(240, yPosition, 280, 20));

    yPosition += 20; // Move down for the signature fields

// Create digital signature fields
    PdfSignatureField technicianSignatureField = PdfSignatureField(
        page, 'Techniker_Unterschrift',
        bounds: Rect.fromLTWH(xPosition, yPosition, 200, 50));
    technicianSignatureField.borderColor = PdfColor(0, 0, 0);
    technicianSignatureField.tooltip = 'Techniker Unterschrift';
    document.form.fields.add(technicianSignatureField);

    PdfSignatureField stampSignatureField = PdfSignatureField(
        page, 'Stempel_Unterschrift',
        bounds: Rect.fromLTWH(240, yPosition, 280, 50));
    stampSignatureField.borderColor = PdfColor(0, 0, 0);
    stampSignatureField.tooltip = 'Stempel_Unterschrift';

    document.form.fields.add(stampSignatureField);

    yPosition += 80; // Move down for the next section if needed

    PdfTextBoxField field1 = PdfTextBoxField(page, 'Interne Bemerkungen: ',
        Rect.fromLTWH(xPosition, yPosition, 150, 30),
        borderStyle: PdfBorderStyle.underline);
    field1.text = "Interne Bemerkungen: ";
    field1.font = font;
    document.form.fields.add(field1);

    PdfTextBoxField field2 = PdfTextBoxField(
        page, 'O berechnet  ', Rect.fromLTWH(150, yPosition, 80, 30),
        borderStyle: PdfBorderStyle.underline);
    field2.text = "O berechnet  ";
    field2.font = font;
    document.form.fields.add(field2);

    PdfTextBoxField field3 = PdfTextBoxField(
        page, 'O keine Rechnung ', Rect.fromLTWH(230, yPosition, 80, 30),
        borderStyle: PdfBorderStyle.underline);
    field3.text = "O keine Rechnung ";
    field3.font = font;
    document.form.fields.add(field3);

    PdfTextBoxField field4 = PdfTextBoxField(
        page, 'Rechnungsdatum: ', Rect.fromLTWH(310, yPosition, 100, 30),
        borderStyle: PdfBorderStyle.underline);
    field4.text = "Rechnungsdatum: ";
    field4.font = font;
    document.form.fields.add(field4);

    PdfTextBoxField field5 = PdfTextBoxField(
        page, 'Rechnungs-Nr.:', Rect.fromLTWH(410, yPosition, 120, 30),
        borderStyle: PdfBorderStyle.underline);
    field5.text = "Rechnungs-Nr.:";
    field5.font = font;
    document.form.fields.add(field5);

    // PdfCheckBoxField checkBox1 = PdfCheckBoxField(
    //     page, 'Berechnet', Rect.fromLTWH(20, yPosition, 15, 15));
    // document.form.fields.add(checkBox1);
    // graphics.drawString("Berechnet", font,
    //     bounds: Rect.fromLTWH(40, yPosition, 200, 20));
    //
    // PdfCheckBoxField checkBox2 = PdfCheckBoxField(document.pages[0],
    //     'Keine Rechnung', Rect.fromLTWH(20, yPosition + 30, 15, 15));
    // document.form.fields.add(checkBox2);
    // graphics.drawString("Keine Rechnung", font,
    //     bounds: Rect.fromLTWH(40, yPosition + 30, 200, 20));
    // yPosition += 60;
    //
    // PdfTextBoxField invoiceField = PdfTextBoxField(document.pages[0],
    //     'InvoiceDetails', Rect.fromLTWH(20, yPosition, 300, 20));
    // invoiceField.text = "Enter Invoice Details";
    // invoiceField.font = font;
    // document.form.fields.add(invoiceField);

    // Save and launch
    final List<int> bytes = document.saveSync();
    document.dispose();

    // final String path = (await getApplicationDocumentsDirectory()).path;
    // final String filePath = '$path/Editable_Formular_Bericht_2025.pdf';
    // final File file = File(filePath);
    // await file.writeAsBytes(bytes, flush: true);

    return saveDocumentInStorage(bytes, 'Editable_Formular_Bericht_2025.pdf');
    //OpenFile.open(filePath);
  }

  Future<String> saveDocumentInStorage(List<int> bytes, String pathName) async {
    final String path = (await getApplicationDocumentsDirectory()).path;
    final String filePath = '$path/$pathName';
    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return filePath;
  }

  PdfPage _ensurePageSpace(
      PdfDocument document, PdfPage currentPage, double yPosition) {
    final double pageHeight = currentPage.getClientSize().height;

    if (yPosition > pageHeight - 50) {
      // If content reaches near the bottom
      currentPage = document.pages.add(); // Add a new page
      yPosition = 20; // Reset position for new page
    }
    return currentPage;
  }
}
