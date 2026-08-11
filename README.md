# AL MULTAQA Invoice Appimport 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const InvoiceApp());
}

class InvoiceApp extends StatelessWidget {
  const InvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AL MULTAQA Invoice',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const InvoiceHomePage(),
    );
  }
}

class InvoiceItem {
  String name;
  double quantity;
  double price;

  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get amount => quantity * price;
}

class InvoiceHomePage extends StatefulWidget {
  const InvoiceHomePage({super.key});

  @override
  State<InvoiceHomePage> createState() => _InvoiceHomePageState();
}

class _InvoiceHomePageState extends State<InvoiceHomePage> {
  final customerController = TextEditingController();
  final itemController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final priceController = TextEditingController();

  final List<InvoiceItem> items = [];

  late String invoiceNumber;
  String invoiceDate = '';

  @override
  void initState() {
    super.initState();
    invoiceNumber =
        'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    invoiceDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    loadCustomer();
  }

  Future<void> loadCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('last_customer') ?? '';
    customerController.text = name;
  }

  Future<void> saveCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'last_customer',
      customerController.text.trim(),
    );
  }

  double get total {
    return items.fold(0, (sum, item) => sum + item.amount);
  }

  void addItem() {
    final name = itemController.text.trim();
    final quantity =
        double.tryParse(quantityController.text.trim()) ?? 0;
    final price =
        double.tryParse(priceController.text.trim()) ?? 0;

    if (name.isEmpty || quantity <= 0 || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter item, quantity and price.'),
        ),
      );
      return;
    }

    setState(() {
      items.add(
        InvoiceItem(
          name: name,
          quantity: quantity,
          price: price,
        ),
      );

      itemController.clear();
      quantityController.text = '1';
      priceController.clear();
    });
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  Future<Uint8List> makePdf() async {
    final pdf = pw.Document();

    final tableData = <List<String>>[
      ['#', 'Description', 'Qty', 'Price', 'Amount'],
    ];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      tableData.add([
        '${i + 1}',
        item.name,
        item.quantity.toStringAsFixed(0),
        '${item.price.toStringAsFixed(2)} AED',
        '${item.amount.toStringAsFixed(2)} AED',
      ]);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'AL MULTAQA',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Center(
                child: pw.Text(
                  'SMITHERY & ALUMINIUM WORKSHOP L.L.C.-O.P.C',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),

              pw.SizedBox(height: 4),

              pw.Center(
                child: pw.Text(
                  'Al Ain, UAE',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),

              pw.SizedBox(height: 25),

              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Invoice No: $invoiceNumber'),
                        pw.Text('Date: $invoiceDate'),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 15),

              pw.Text(
                'Customer: ${customerController.text.trim().isEmpty ? 'Walk-in Customer' : customerController.text.trim()}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              if (items.isNotEmpty)
                pw.Table.fromTextArray(
                  headers: tableData.first,
                  data: tableData.skip(1).toList(),
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellAlignment: pw.Alignment.center,
                  headerDecoration:
                      const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                )
              else
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Text('No items added.'),
                ),

              pw.SizedBox(height: 20),

              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 220,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOTAL',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '${total.toStringAsFixed(2)} AED',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.Spacer(),

              pw.Center(
                child: pw.Text(
                  'Thank you for your business',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> generatePdf() async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item.'),
        ),
      );
      return;
    }

    await saveCustomer();

    final bytes = await makePdf();

    await Printing.sharePdf(
      bytes: bytes,
      filename: '$invoiceNumber.pdf',
    );
  }

  Future<void> printInvoice() async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item.'),
        ),
      );
      return;
    }

    await saveCustomer();

    final bytes = await makePdf();

    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: '$invoiceNumber.pdf',
    );
  }

  void clearInvoice() {
    setState(() {
      items.clear();
      customerController.clear();
      itemController.clear();
      quantityController.text = '1';
      priceController.clear();

      invoiceNumber =
          'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      invoiceDate =
          DateFormat('dd/MM/yyyy').format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AL MULTAQA Invoice',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'New Invoice',
            onPressed: clearInvoice,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      size: 50,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'AL MULTAQA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'SMITHERY & ALUMINIUM WORKSHOP L.L.C.-O.P.C',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Text('Al Ain, UAE'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              'Invoice No: $invoiceNumber',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            Text('Date: $invoiceDate'),

            const SizedBox(height: 15),

            TextField(
              controller: customerController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: itemController,
              decoration: const InputDecoration(
                labelText: 'Item / Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Price (AED)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: addItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),

            const SizedBox(height: 15),

            if (items.isNotEmpty)
              Card(
                child: Column(
                  children: [
                    const ListTile(
                      title: Text(
                        'Invoice Items',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    ...List.generate(
                      items.length,
                      (index) {
                        final item = items[index];

                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            '${item.quantity} × ${item.price.toStringAsFixed(2)} AED',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${item.amount.toStringAsFixed(2)} AED',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    removeItem(index),
                                icon: const Icon(
                                  Icons.delete_outline,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${total.toStringAsFixed(2)} AED',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            FilledButton.icon(
              onPressed: generatePdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate & Share PDF'),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: printInvoice,
              icon: const Icon(Icons.print),
              label: const Text('Print Invoice'),
            ),

            const SizedBox(height: 25),

            const Center(
              child: Text(
                'VAT not included',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    customerController.dispose();
    itemController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }
}

Flutter Android invoice app for:

AL MULTAQA SMITHERY & ALUMINIUM WORKSHOP L.L.C.-O.P.C.
Street No. 4, Sanaiya, Al Ain, U.A.E.

Included:
- Invoice number + date
- Customer name, phone, address
- Multiple invoice items
- Quantity, rate and automatic total
- VAT-free invoice
- A4 PDF generation
- Print preview
- Share PDF
- Auto invoice numbering
- Company logo asset
- Signature name

## Build
Run:
flutter pub get
flutter build apk --release

APK output:
build/app/outputs/flutter-apk/app-release.apk

The project also contains a GitHub Actions workflow. Upload the project to GitHub and run the "Build Android APK" action to build the APK without a local computer.
