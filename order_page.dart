import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:rms_application/home_page.dart';
import 'order_confirmation.dart';

// Order Model
class Order {
  final String orderId;
  final DateTime date;
  final String status;
  final List<int> tables;
  final int guests;
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double gst;
  final double total;
  final TimeOfDay selectedTime;

  Order({
    required this.orderId,
    required this.date,
    required this.status,
    required this.tables,
    required this.guests,
    required this.cartItems,
    required this.subtotal,
    required this.gst,
    required this.total,
    required this.selectedTime,
  });
}

// Order Provider
class OrderProvider with ChangeNotifier {
  List<Order> _orders = [
    Order(
      orderId: 'ORD001',
      date: DateTime.now().subtract(Duration(days: 1)),
      status: 'Completed',
      tables: [1, 2],
      guests: 4,
      cartItems: [
        {'name': 'Pizza', 'quantity': 2, 'discountedPrice': 150.0},
      ],
      subtotal: 300.0,
      gst: 54.0,
      total: 354.0,
      selectedTime: TimeOfDay(hour: 19, minute: 0),
    ),
    Order(
      orderId: 'ORD002',
      date: DateTime.now(),
      status: 'Pending',
      tables: [3],
      guests: 2,
      cartItems: [
        {'name': 'Burger', 'quantity': 1, 'discountedPrice': 100.0},
      ],
      subtotal: 100.0,
      gst: 18.0,
      total: 118.0,
      selectedTime: TimeOfDay(hour: 20, minute: 30),
    ),
  ];

  String _filterStatus = 'All';
  String _sortBy = 'DateDesc';
  String _searchQuery = '';

  List<Order> get orders {
    var filtered = _orders.where((order) {
      if (_filterStatus != 'All' && order.status != _filterStatus) return false;
      if (_searchQuery.isEmpty) return true;
      return order.orderId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.tables.join(', ').contains(_searchQuery);
    }).toList();

    if (_sortBy == 'DateDesc') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    } else if (_sortBy == 'DateAsc') {
      filtered.sort((a, b) => a.date.compareTo(b.date));
    } else if (_sortBy == 'TotalDesc') {
      filtered.sort((a, b) => b.total.compareTo(a.total));
    } else if (_sortBy == 'TotalAsc') {
      filtered.sort((a, b) => a.total.compareTo(b.total));
    }

    return filtered;
  }

  String get filterStatus => _filterStatus;
  String get sortBy => _sortBy;
  String get searchQuery => _searchQuery;

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void cancelOrder(String orderId) {
    _orders = _orders.map((order) {
      if (order.orderId == orderId && order.status == 'Pending') {
        return Order(
          orderId: order.orderId,
          date: order.date,
          status: 'Canceled',
          tables: order.tables,
          guests: order.guests,
          cartItems: order.cartItems,
          subtotal: order.subtotal,
          gst: order.gst,
          total: order.total,
          selectedTime: order.selectedTime,
        );
      }
      return order;
    }).toList();
    notifyListeners();
  }

  Future<void> refreshOrders() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network call
    notifyListeners();
  }
}

class OrderPage extends StatefulWidget {
  final Function(int)? onTabChange; // Callback to update selected index

  const OrderPage({super.key, this.onTabChange});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearching = false;
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      final statuses = ['All', 'Pending', 'Completed', 'Canceled'];
      Provider.of<OrderProvider>(context, listen: false)
          .setFilterStatus(statuses[_tabController.index]);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<String?> _generateAndSavePdf(BuildContext buildContext, Order order) async {
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
        ScaffoldMessenger.of(buildContext).showSnackBar(
          const SnackBar(content: Text("Storage permission denied, using app directory")),
        );
      }
    }

    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate = "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}";
    final formattedTime = order.selectedTime.format(buildContext);

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
            pw.Text(
              "My Restaurant",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text("Date: $formattedDate"),
            pw.SizedBox(height: 20),
            pw.Text(
              "Order Details",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            if (order.cartItems.isEmpty)
              pw.Text("No food items ordered.")
            else
              pw.Table(
                border: pw.TableBorder.all(width: 1),
                columnWidths: {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#eeeeee')),
                    children: [
                      _buildCell("Item", bold: true),
                      _buildCell("Qty", align: pw.TextAlign.center, bold: true),
                      _buildCell("Price", align: pw.TextAlign.center, bold: true),
                      _buildCell("Total", align: pw.TextAlign.center, bold: true),
                    ],
                  ),
                  for (var item in order.cartItems)
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
            pw.Text(
              "Booking Details",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            pw.Text("Table No${order.tables.length > 1 ? 's' : ''}: ${order.tables.join(', ')}"),
            pw.Text("Guests: ${order.guests}"),
            pw.Text("Dining Time: $formattedTime"),
            pw.SizedBox(height: 20),
            pw.Text(
              "Payment Summary",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            pw.Text("Subtotal: Rs. ${order.subtotal.toStringAsFixed(2)}"),
            pw.Text("GST (18%): Rs. ${order.gst.toStringAsFixed(2)}"),
            pw.Text("Total: Rs. ${order.total.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );

    final directory = Platform.isAndroid
        ? await getApplicationDocumentsDirectory()
        : await getTemporaryDirectory();
    final timestamp = now.toIso8601String().replaceAll(':', '-').substring(0, 19);
    try {
      final file = File("${directory.path}/receipt_${order.orderId}_$timestamp.pdf");
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      ScaffoldMessenger.of(buildContext).showSnackBar(
        SnackBar(content: Text("Failed to save receipt: $e")),
      );
      return null;
    }
  }

  Future<void> _downloadReceipt(BuildContext context, Order order) async {
    final filePath = await _generateAndSavePdf(context, order);
    if (filePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Receipt saved to $filePath")),
      );
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to open PDF: ${result.message}")),
        );
      }
      await Share.shareXFiles([XFile(filePath)], text: "Your Restaurant Receipt");
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Provider.of<OrderProvider>(context, listen: false).refreshOrders();
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderProvider(),
      child: WillPopScope(
        onWillPop: () async {
          // Update the selected index to Home (index 0) before going back
          widget.onTabChange?.call(0);
          return true; // Allow back navigation
        },
        child: Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: _isSearching
                    ? TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Order ID or Table',
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.lato(color: Colors.white70),
                  ),
                  style: GoogleFonts.lato(color: Colors.white),
                  onChanged: (value) {
                    Provider.of<OrderProvider>(context, listen: false).setSearchQuery(value);
                  },
                )
                    : Text(
                  'My Orders',
                ),
                centerTitle: true,
                backgroundColor: Colors.green.shade500,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    // Update the selected index to Home (index 0) when back button is pressed
                    widget.onTabChange?.call(0);
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  IconButton(
                    icon: Icon(_isSearching ? Icons.close : Icons.search),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchController.clear();
                          Provider.of<OrderProvider>(context, listen: false).setSearchQuery('');
                        }
                      });
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      Provider.of<OrderProvider>(context, listen: false).setSortBy(value);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'DateDesc', child: Text('Newest First')),
                      PopupMenuItem(value: 'DateAsc', child: Text('Oldest First')),
                      PopupMenuItem(value: 'TotalDesc', child: Text('Highest Total')),
                      PopupMenuItem(value: 'TotalAsc', child: Text('Lowest Total')),
                    ],
                    icon: Icon(Icons.sort),
                  ),
                ],
              ),
              body: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'All'),
                      Tab(text: 'Pending'),
                      Tab(text: 'Completed'),
                      Tab(text: 'Canceled'),
                    ],
                    labelStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
                    unselectedLabelStyle: GoogleFonts.lato(),
                    indicatorColor: Colors.green.shade500,
                  ),
                  Expanded(
                    child: OrientationBuilder(
                      builder: (context, orientation) {
                        return RefreshIndicator(
                          onRefresh: _handleRefresh,
                          color: Colors.green.shade500,
                          backgroundColor: Colors.white,
                          child: Consumer<OrderProvider>(
                            builder: (context, provider, child) {
                              if (provider.orders.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No orders found.',
                                    style: GoogleFonts.lato(fontSize: 18),
                                  ),
                                );
                              }
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  final isLandscape = orientation == Orientation.landscape;
                                  final crossAxisCount = isLandscape && constraints.maxWidth > 600 ? 2 : 1;
                                  return AnimationLimiter(
                                    child: GridView.builder(
                                      padding: EdgeInsets.all(16),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: isLandscape ? 2 : 3.5, // Increased for more vertical space
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                      itemCount: provider.orders.length,
                                      itemBuilder: (context, index) {
                                        final order = provider.orders[index];
                                        return AnimationConfiguration.staggeredGrid(
                                          position: index,
                                          columnCount: crossAxisCount,
                                          duration: Duration(milliseconds: 375),
                                          child: SlideAnimation(
                                            verticalOffset: 50.0,
                                            child: FadeInAnimation(
                                              child: _buildOrderCard(context, order),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FoodMenuScreen()),
                  );
                },
                backgroundColor: Colors.green.shade500,
                child: Icon(Icons.add),
              ),
            ),
            if (_isRefreshing)
              Center(
                child: SpinKitFadingCircle(
                  color: Colors.green.shade500,
                  size: MediaQuery.of(context).size.width * 0.15, // Responsive size
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontScale = screenWidth < 360 ? 0.9 : 1.0; // Scale fonts for small screens

    return GlassmorphicContainer(
      width: double.infinity,
      height: double.infinity,
      borderRadius: 12,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.2),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12), // Reduced padding
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Order #${order.orderId}',
                      style: GoogleFonts.lato(
                        fontSize: 18 * fontScale,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      order.status,
                      style: GoogleFonts.lato(fontSize: 12 * fontScale, color: Colors.white),
                    ),
                    backgroundColor: order.status == 'Pending'
                        ? Colors.orange
                        : order.status == 'Completed'
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Date: ${order.date.day}/${order.date.month}/${order.date.year}',
                style: GoogleFonts.lato(fontSize: 14 * fontScale),
              ),
              Text(
                'Tables: ${order.tables.join(', ')}',
                style: GoogleFonts.lato(fontSize: 14 * fontScale),
              ),
              Text(
                'Total: Rs. ${order.total.toStringAsFixed(2)}',
                style: GoogleFonts.lato(fontSize: 14 * fontScale, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (order.status == 'Pending')
                    IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red, size: 20 * fontScale),
                      onPressed: () {
                        Provider.of<OrderProvider>(context, listen: false).cancelOrder(order.orderId);
                      },
                    ),
                  IconButton(
                    icon: Icon(Icons.download, color: Colors.blue, size: 20 * fontScale),
                    onPressed: () => _downloadReceipt(context, order),
                  ),
                  IconButton(
                    icon: Icon(Icons.repeat, color: Colors.green, size: 20 * fontScale),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FoodMenuScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.visibility, color: Colors.grey, size: 20 * fontScale),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderConfirmationPage(
                            peopleCount: order.guests,
                            selectedTime: order.selectedTime,
                            selectedTables: order.tables,
                            cartItems: order.cartItems,
                            subtotal: order.subtotal,
                            gst: order.gst,
                            total: order.total,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}