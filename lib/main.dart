import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const StockAverageCalculatorApp());
}

class StockAverageCalculatorApp extends StatefulWidget {
  const StockAverageCalculatorApp({super.key});

  @override
  State<StockAverageCalculatorApp> createState() => _StockAverageCalculatorAppState();
}

class _StockAverageCalculatorAppState extends State<StockAverageCalculatorApp> {
  bool isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Average Calculator',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: StockAverageHomePage(
        isDarkTheme: isDarkTheme,
        onThemeToggle: () {
          setState(() {
            isDarkTheme = !isDarkTheme;
          });
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StockEntry {
  int quantity;
  double price;

  StockEntry({this.quantity = 0, this.price = 0.0});
}

class StockAverageHomePage extends StatefulWidget {
  final bool isDarkTheme;
  final VoidCallback onThemeToggle;

  const StockAverageHomePage({super.key, required this.isDarkTheme, required this.onThemeToggle});

  @override
  State<StockAverageHomePage> createState() => _StockAverageHomePageState();
}

class _StockAverageHomePageState extends State<StockAverageHomePage> {
  List<StockEntry> entries = [StockEntry()];

  int totalQuantity = 0;
  double totalInvestment = 0.0;
  double averagePrice = 0.0;

  void calculateAverage() {
    int quantitySum = 0;
    double investmentSum = 0.0;

    for (var entry in entries) {
      quantitySum += entry.quantity;
      investmentSum += entry.quantity * entry.price;
    }

    setState(() {
      totalQuantity = quantitySum;
      totalInvestment = investmentSum;
      averagePrice = quantitySum > 0 ? (investmentSum / quantitySum) : 0.0;
    });
  }

  void resetCalculator() {
    setState(() {
      entries = [StockEntry()];
      totalQuantity = 0;
      totalInvestment = 0.0;
      averagePrice = 0.0;
    });
  }

  Future<void> generatePdfReport() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('📈 Stock Average Report',
                  style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Entries:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...entries.asMap().entries.map(
                    (e) => pw.Text(
                  '${e.key == 0 ? "Early Investment" : "New Entry"}: Quantity = ${e.value.quantity}, Price = ₹${e.value.price.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ),
              pw.Divider(height: 20, thickness: 1),
              pw.Text('Summary:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Total Shares Bought: $totalQuantity', style: const pw.TextStyle(fontSize: 14)),
              pw.Text('Total Investment: ₹${totalInvestment.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 14)),
              pw.Text('Average Buying Price: ₹${averagePrice.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 14)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Widget buildEntry(int index) {
    final isFirst = index == 0;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isFirst ? 'Early Investment' : 'New Entry',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    onChanged: (value) {
                      setState(() {
                        entries[index].quantity = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true, signed: false),
                    decoration: const InputDecoration(
                      labelText: 'Price (₹)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.price_change),
                    ),
                    onChanged: (value) {
                      setState(() {
                        entries[index].price = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ),
                if (entries.length > 1)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        entries.removeAt(index);
                      });
                    },
                    icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                    tooltip: 'Remove Entry',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Average Calculator'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkTheme ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.onThemeToggle,
            tooltip: widget.isDarkTheme ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) => buildEntry(index),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      entries.add(StockEntry());
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Entry'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: calculateAverage,
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Calculate'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,  // <-- Added this line for clarity
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: resetCalculator,
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📊 Result Summary',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            Text('Total Shares Bought: $totalQuantity'),
            Text('Total Investment: ₹${totalInvestment.toStringAsFixed(2)}'),
            Text('Average Buying Price: ₹${averagePrice.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Download PDF Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: generatePdfReport,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
