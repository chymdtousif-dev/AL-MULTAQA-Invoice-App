import 'package:flutter/material.dart';

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

  final List<Map<String, dynamic>> items = [];

  double get total {
    return items.fold(
      0,
      (sum, item) => sum + (item['qty'] * item['price']),
    );
  }

  void addItem() {
    final item = itemController.text.trim();
    final qty = double.tryParse(quantityController.text) ?? 1;
    final price = double.tryParse(priceController.text) ?? 0;

    if (item.isEmpty || price <= 0) return;

    setState(() {
      items.add({
        'name': item,
        'qty': qty,
        'price': price,
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AL MULTAQA Invoice',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'AL MULTAQA SMITHERY & ALUMINIUM WORKSHOP L.L.C.-O.P.C',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Al Ain, UAE',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

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

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
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
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price (AED)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            FilledButton.icon(
              onPressed: addItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),

            const SizedBox(height: 20),

            if (items.isNotEmpty)
              Card(
                child: Column(
                  children: [
                    const ListTile(
                      title: Text(
                        'Invoice Items',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...List.generate(
                      items.length,
                      (index) {
                        final item = items[index];
                        final amount =
                            item['qty'] * item['price'];

                        return ListTile(
                          title: Text(item['name']),
                          subtitle: Text(
                            '${item['qty']} × ${item['price'].toStringAsFixed(2)} AED',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${amount.toStringAsFixed(2)} AED',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => removeItem(index),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Invoice ready — PDF feature will be added next.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate Invoice PDF'),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share),
              label: const Text('Share Invoice'),
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
