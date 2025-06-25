import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<void> generateReceipt({
  required List<dynamic> cartItems,
  required int tableNumber,
  required int numberOfPersons,
  required DateTime arrivalTime,
  required double subtotal,
  required double gst,
  required double total,
  required DateTime orderDate,
}) async {
  // Check Android version for permission handling
  bool useManageExternalStorage = false;
  if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    useManageExternalStorage = sdkInt >= 33;

    final permission = useManageExternalStorage
        ? Permission.manageExternalStorage
        : Permission.storage;
    var status = await permission.request();
    if (!status.isGranted) {
      // Fallback to app-specific directory if permission denied
      print("Storage permission denied, using app directory");
    }
  }

  final pdf = pw.Document();
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  pw.Widget _buildCell(String text,
      {pw.TextAlign align = pw.TextAlign.left, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Text(
            "My Restaurant",
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text("Date: ${dateFormat.format(orderDate)}"),
          pw.SizedBox(height: 20),

          // Order Details
          pw.Text(
            "Order Details",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          if (cartItems.isEmpty)
            pw.Text("No food items ordered.")
          else
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              columnWidths: {
                0: pw.FlexColumnWidth(3), // Item
                1: pw.FlexColumnWidth(1), // Qty
                2: pw.FlexColumnWidth(2), // Price
                3: pw.FlexColumnWidth(2), // Total
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#eeeeee')),
                  children: [
                    _buildCell("Item", bold: true),
                    _buildCell("Qty", align: pw.TextAlign.center, bold: true),
                    _buildCell("Price", align: pw.TextAlign.center, bold: true),
                    _buildCell("Total", align: pw.TextAlign.center, bold: true),
                  ],
                ),
                // Data rows
                for (var item in cartItems)
                  pw.TableRow(
                    children: [
                      _buildCell(item['name'] ?? 'Unknown Item'),
                      _buildCell(item['quantity'].toString(),
                          align: pw.TextAlign.center),
                      _buildCell("Rs. ${item['price']}", align: pw.TextAlign.center),
                      _buildCell(
                        "Rs. ${(item['quantity'] * double.parse(item['price'].toString())).toStringAsFixed(2)}",
                        align: pw.TextAlign.center,
                      ),
                    ],
                  ),
              ],
            ),
          pw.SizedBox(height: 20),

          // Booking Details
          pw.Text(
            "Booking Details",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(),
          pw.Text("Table No: $tableNumber"),
          pw.Text("Guests: $numberOfPersons"),
          pw.Text("Arrival Time: ${dateFormat.format(arrivalTime)}"),
          pw.SizedBox(height: 20),

          // Payment Summary
          pw.Text(
            "Payment Summary",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(),
          pw.Text("Subtotal: Rs. ${subtotal.toStringAsFixed(2)}"),
          pw.Text("GST (18%): Rs. ${gst.toStringAsFixed(2)}"),
          pw.Text("Total: Rs. ${total.toStringAsFixed(2)}"),
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              "Thank you for dining with us!",
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    ),
  );

  // Save PDF to app-specific directory
  final directory = Platform.isAndroid
      ? await getApplicationDocumentsDirectory()
      : await getTemporaryDirectory();
  final timestamp = orderDate.toIso8601String().replaceAll(':', '-').substring(0, 19);
  final filePath = "${directory.path}/receipt_$timestamp.pdf";
  final file = File(filePath);

  try {
    await file.writeAsBytes(await pdf.save());

    // Open PDF
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      print("Failed to open PDF: ${result.message}");
    }

    // Share PDF
    await Share.shareXFiles([XFile(filePath)], text: "Your Foodie's Paradise Receipt");
  } catch (e) {
    print("Failed to save or process receipt: $e");
  }
}