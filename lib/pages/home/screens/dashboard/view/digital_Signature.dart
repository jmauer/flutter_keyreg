import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kontrolle_keyreg/localization/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:digital_signature_flutter/digital_signature_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'pdf.dart';
import 'package:kontrolle_keyreg/globals.dart' as globals;

class DigitalSignature extends StatefulWidget {
  const DigitalSignature({Key? key, required this.scannedTag})
      : super(key: key);

  final String scannedTag;

  @override
  State<DigitalSignature> createState() => _DigitalSignatureState();
}

class _DigitalSignatureState extends State<DigitalSignature> {
  SignatureController? controller;
  Uint8List? signature;

  String path = "";

  late TextEditingController emailController;
  late TextEditingController nameController;
  late TextEditingController telefonController;

  final font1 = pw.Font.helvetica();

  final font2 = pw.Font.helveticaBold();

  final pdf = pw.Document();
  @override
  void initState() {
    controller = SignatureController(penStrokeWidth: 2, penColor: Colors.black);
    emailController = TextEditingController();
    nameController = TextEditingController();
    telefonController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context).translate('tag')}: " +
            widget.scannedTag),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xffE8761E), Color(0xffFE9879)]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Text(AppLocalizations.of(context).translate('enter_data'),
                  style: TextStyle(fontSize: 20, color: Colors.black)),
              const SizedBox(height: 15),
              nameTextField(size),
              emailTextField(size),
              telefonTextField(size),
              Card(
                child: Center(
                  child: Signature(
                    height: 200,
                    width: 350,
                    controller: controller!,
                    backgroundColor: Colors.white,
                  ),
                  // ),
                ),
              ),
              buttonWidgets(context)!,
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  buttonWidgets(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () async {
            if (controller!.isNotEmpty) {
              var sign = await exportSignature();

              var file = File('my_image.jpg').writeAsBytes(sign!);

              Map data = {
                'Name': nameController.text,
                'Email': emailController.text,
                'Telefon': telefonController.text,
                'Unterschrift': file
              };

              if (await newPDF(nameController.text, emailController.text,
                  telefonController.text)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFScreen(
                      path: path,
                      tag: widget.scannedTag,
                    ),
                  ),
                );
              }
              ;
            } else {
              //showMessage
              // Please put your signature;
            }
          },
          child: Text(AppLocalizations.of(context).translate('save'),
              style: TextStyle(fontSize: 20, color: Colors.green)),
        ),
        TextButton(
          onPressed: () {
            controller?.clear();
            emailController.clear();
            telefonController.clear();
            nameController.clear();
            setState(() {
              signature = null;
            });
          },
          child: Text(AppLocalizations.of(context).translate('new'),
              style: TextStyle(fontSize: 20, color: Colors.red)),
        ),
      ],
    );
  }

  Future<Uint8List?> exportSignature() async {
    final exportController = SignatureController(
      penStrokeWidth: 2,
      exportBackgroundColor: Colors.white,
      penColor: Colors.black,
      points: controller!.points,
    );

    final signature = exportController.toPngBytes();

    //clean up the memory
    exportController.dispose();

    return signature;
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  Widget emailTextField(Size size) {
    return SizedBox(
      height: size.height / 13,
      child: TextField(
        controller: emailController,
        style: GoogleFonts.inter(
          fontSize: 18.0,
          color: const Color(0xFF151624),
        ),
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        cursorColor: const Color(0xFF151624),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).translate('enter_email'),
          hintStyle: GoogleFonts.inter(
            fontSize: 14.0,
            color: const Color(0xFFABB3BB),
            height: 1.0,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(width: 3, color: Color(0xffFE9879)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: Icon(
            Icons.mail_outline_rounded,
            color: emailController.text.isEmpty
                ? const Color(0xFF151624).withOpacity(0.5)
                : const Color(0xffE8761E),
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget nameTextField(Size size) {
    return SizedBox(
      height: size.height / 13,
      child: TextField(
        controller: nameController,
        style: GoogleFonts.inter(
          fontSize: 18.0,
          color: const Color(0xFF151624),
        ),
        maxLines: 1,
        cursorColor: const Color(0xFF151624),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).translate('enter_customer'),
          hintStyle: GoogleFonts.inter(
            fontSize: 14.0,
            color: const Color(0xFFABB3BB),
            height: 1.0,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(width: 3, color: Color(0xffFE9879)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: Icon(
            Icons.person_outlined,
            color: nameController.text.isEmpty
                ? const Color(0xFF151624).withOpacity(0.5)
                : const Color(0xffE8761E),
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget telefonTextField(Size size) {
    return SizedBox(
      height: size.height / 13,
      child: TextField(
        controller: telefonController,
        style: GoogleFonts.inter(
          fontSize: 18.0,
          color: const Color(0xFF151624),
        ),
        maxLines: 1,
        cursorColor: const Color(0xFF151624),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).translate('enter_mobile'),
          hintStyle: GoogleFonts.inter(
            fontSize: 14.0,
            color: const Color(0xFFABB3BB),
            height: 1.0,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(width: 3, color: Color(0xffFE9879)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: Icon(
            Icons.phone_android_outlined,
            color: telefonController.text.isEmpty
                ? const Color(0xFF151624).withOpacity(0.5)
                : const Color(0xffE8761E),
            size: 16,
          ),
        ),
      ),
    );
  }

  Future<bool> newPDF(String kunde, String email, String mobile) async {
    var now = DateTime.now();
    var formatter = DateFormat('dd.MM.yyyy');
    String formattedDate = formatter.format(now);

    var sign = await exportSignature();
    final pdf = pw.Document();
    final image1 = pw.MemoryImage(sign!);

    pdf.addPage(pw.MultiPage(
        theme: pw.ThemeData.withFont(
          base: font1,
          bold: font2,
        ),
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          if (context.pageNumber == 1) {
            return pw.SizedBox();
          }
          return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(width: 0.5, color: PdfColors.grey))),
              child: pw.Text('Übergabeprotokoll',
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)));
        },
        footer: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: pw.Text('Dieses Dokument wurde automatisch erstellt.',
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)));
        },
        build: (pw.Context context) => <pw.Widget>[
              pw.Header(
                  level: 0,
                  title: 'Übergabeprotokoll',
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: <pw.Widget>[
                        pw.Text('Übergabeprotokoll', textScaleFactor: 2),
                      ])),
              pw.Paragraph(
                  text: 'Der Kunde $kunde hat den Schlüssel ' +
                      widget.scannedTag +
                      ' am $formattedDate von unserem Mitarbeiter erhalten.'),
              pw.Paragraph(
                  text: 'Eingetragene E-Mail Adresse des Kunden: $email'),
              pw.Paragraph(
                  text: 'Eingetragene Telefonnummer des Kunden: $mobile'),
              pw.Paragraph(text: 'Wir bedanken uns für Ihr Vertrauen.'),
              pw.Padding(padding: const pw.EdgeInsets.all(10)),
              pw.Spacer(),
              pw.Paragraph(text: 'Unterschrift des Kunden'),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                height: 80,
                child: pw.Image(image1),
              )
            ]));

    final output = await getTemporaryDirectory();

    // final file = File("example.pdf");
    final file = File("${output.path}/${kunde}.pdf");
    path = file.path;
    await file.writeAsBytes(await pdf.save());
    if (await file.exists()) {
      return true;
    } else {
      return false;
    }
  }
}
