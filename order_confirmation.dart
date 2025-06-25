import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:rms_application/home_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class OrderConfirmationPage extends StatelessWidget {
  final int peopleCount;
  final TimeOfDay selectedTime;
  final List<int> selectedTables;
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double gst;
  final double total;

  const OrderConfirmationPage({
    super.key,
    required this.peopleCount,
    required this.selectedTime,
    required this.selectedTables,
    required this.cartItems,
    required this.subtotal,
    required this.gst,
    required this.total,
  });

  Future<String?> _generateAndSavePdf(BuildContext buildContext) async {
    // Check Android version for permission handling
    bool useManageExternalStorage = false;
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      // Android 13+ (API 33+) requires MANAGE_EXTERNAL_STORAGE
      useManageExternalStorage = sdkInt >= 33;

      // Request appropriate permission
      final permission = useManageExternalStorage
          ? Permission.manageExternalStorage
          : Permission.storage;
      var status = await permission.request();
      if (!status.isGranted) {
        // If permission is denied, fall back to app-specific directory
        ScaffoldMessenger.of(buildContext).showSnackBar(
          const SnackBar(content: Text("Storage permission denied, using app directory")),
        );
      }
    }

    // Use pdf package to generate the receipt (clarifying usage)
    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate = "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}";
    final formattedTime = selectedTime.format(buildContext);

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
            pw.Text("Date: $formattedDate"),
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
                        _buildCell(item['name']),
                        _buildCell(item['quantity'].toString(), align: pw.TextAlign.center),
                        _buildCell("Rs. ${item['discountedPrice']}", align: pw.TextAlign.center),
                        _buildCell(
                          "Rs. ${(int.parse(item['quantity'].toString()) * double.parse(item['discountedPrice'].toString())).toStringAsFixed(2)}",
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
            pw.Text("Table No${selectedTables.length > 1 ? 's' : ''}: ${selectedTables.join(', ')}"),
            pw.Text("Guests: $peopleCount"),
            pw.Text("Dining Time: $formattedTime"),
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
          ],
        ),
      ),
    );

    // Save PDF to app-specific directory (no permission needed)
    final directory = Platform.isAndroid
        ? await getApplicationDocumentsDirectory() // App-specific directory
        : await getTemporaryDirectory(); // Temporary directory for iOS
    final timestamp = now.toIso8601String().replaceAll(':', '-').substring(0, 19);
    try {
      final file = File("${directory.path}/receipt_$timestamp.pdf");
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      ScaffoldMessenger.of(buildContext).showSnackBar(
        SnackBar(content: Text("Failed to save receipt: $e")),
      );
      return null;
    }
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    final filePath = await _generateAndSavePdf(context);
    if (filePath != null) {
      // Show success SnackBar with file path
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Receipt saved to $filePath")),
      );

      // Open PDF
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to open PDF: ${result.message}")),
        );
      }

      // Share PDF
      await Share.shareXFiles([XFile(filePath)], text: "Your Restaurant Receipt");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order Confirmation",
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade500,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildOrderDetails(),
            const SizedBox(height: 20),
            _buildBookingDetails(context),
            const SizedBox(height: 20),
            _buildPaymentSummary(),
            const SizedBox(height: 50),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 10),
          Text(
            "Thank You for Your Booking!",
            style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          const Text(
            "Your table booking has been successfully placed.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return _buildCard(
      "Order Details",
      cartItems.isEmpty
          ? [
        "No food items ordered yet.",
        "Proceed to the menu to add items.",
      ]
          : cartItems.map((item) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Qty: ${item['quantity']} @ Rs. ${item['discountedPrice']}",
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
      Icons.fastfood,
    );
  }

  Widget _buildBookingDetails(BuildContext context) {
    final formattedTime = selectedTime.format(context);
    return _buildCard(
      "Table Booking Details",
      [
        "Table No${selectedTables.length > 1 ? 's' : ''}: ${selectedTables.join(', ')}",
        "Guests: $peopleCount",
        "Dining Time: $formattedTime",
      ],
      Icons.event_seat,
    );
  }

  Widget _buildPaymentSummary() {
    return _buildCard(
      "Payment Summary",
      [
        "Subtotal: Rs. ${subtotal.toStringAsFixed(2)}",
        "GST (18%): Rs. ${gst.toStringAsFixed(2)}",
        "Total: Rs. ${total.toStringAsFixed(2)}",
      ],
      Icons.payment,
    );
  }

  Widget _buildCard(String title, List<dynamic> details, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green.shade500),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...details.map((detail) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: detail is String
                  ? Text(
                detail,
                style: GoogleFonts.lato(fontSize: 16),
              )
                  : detail,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => FoodMenuScreen()),
                    (route) => false,
              );
            },
            icon: const Icon(Icons.home, color: Colors.white),
            label: const Text(
              "Back to Home",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade500,
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              await _downloadReceipt(context);
            },
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text(
              "Download Receipt",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
          ),
        ),
      ],
    );
  }
}