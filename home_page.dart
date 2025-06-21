import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rms_application/about_us.dart';
import 'package:rms_application/contact_us.dart';
import 'package:rms_application/menu.dart';
import 'package:rms_application/order_page.dart';
import 'package:rms_application/product_detail.dart';
import 'package:rms_application/profile.dart';
import 'dart:async';
import 'package:rms_application/see_all.dart';
import 'package:rms_application/sign_in.dart';
import 'add_to_cart.dart';
import 'favorite.dart';
import 'models/food_category.dart';
import 'models/product.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FoodMenuScreen(),
    );
  }
}

class FoodMenuScreen extends StatefulWidget {
  const FoodMenuScreen({super.key});

  @override
  _FoodMenuScreenState createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends State<FoodMenuScreen> {
  List<Product> favoriteItems = [];
  int _selectedIndex = 0;
  final String username = "John Doe";
  List<Map<String, dynamic>> cartItems = [];

  final List<String> banners = [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ];

  final List<String> bannerTexts = [
    'Book Table for enjoying the delicious Food!',
    'Enjoy the Curry Festival with Sambar!',
    'Get 10% Off on Italian Pizza Orders!',
  ];

  int currentBannerIndex = 0;
  late Timer bannerTimer;
  late PageController _pageController;
  String searchQuery = "";
  late List<Product> filteredItems;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    bannerTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        currentBannerIndex = (currentBannerIndex + 1) % banners.length;
      });
      _pageController.animateToPage(
        currentBannerIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
    filteredItems = getAllFoodItems();
  }

  @override
  void dispose() {
    bannerTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<Product> getAllFoodItems() {
    return foodCategories.values.expand((list) => list).toList();
  }

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredItems = getAllFoodItems();
      });
    } else {
      setState(() {
        filteredItems = getAllFoodItems()
            .where((item) =>
            item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void addToCart(Map<String, dynamic> item) {
    final existingItemIndex = cartItems.indexWhere(
          (cartItem) => cartItem['name'] == item['name'],
    );

    setState(() {
      if (existingItemIndex != -1) {
        cartItems[existingItemIndex]['quantity'] =
            (cartItems[existingItemIndex]['quantity'] as int) +
                (item['quantity'] as int);
      } else {
        cartItems.add({
          'name': item['name'],
          'image': item['image'],
          'price': item['price'],
          'discountedPrice': item['discountedPrice'].toString(),
          'quantity': item['quantity'],
        });
      }
    });
  }

  void adjustQuantity(Map<String, dynamic> item, int change) {
    final existingItemIndex = cartItems.indexWhere(
          (cartItem) => cartItem['name'] == item['name'],
    );

    setState(() {
      if (existingItemIndex != -1) {
        cartItems[existingItemIndex]['quantity'] += change;
        if (cartItems[existingItemIndex]['quantity'] <= 0) {
          cartItems.removeAt(existingItemIndex);
        }
      } else if (change > 0) {
        cartItems.add({
          'name': item['name'],
          'image': item['image'],
          'price': item['price'],
          'discountedPrice': item['discountedPrice'],
          'quantity': 1,
        });
      }
    });
  }

  void removeFromFavorites(String itemName) {
    setState(() {
      favoriteItems.removeWhere((item) => item.name == itemName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 200,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.green),
                    ),
                    SizedBox(width: 20),
                    Text(
                      username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About Us'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutUsPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Contact Us'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ContactUsPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Favorite'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritePage(
                      favoriteItems: favoriteItems
                          .map((product) => {
                        'name': product.name,
                        'image': product.image,
                        'price': product.price,
                        'description': product.description,
                        'discount': product.discount,
                      })
                          .toList(),
                      onRemoveFavorite: removeFromFavorites,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage(),));
              },
            ),
            ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Exit'),
                onTap: () {
                  Navigator.of(context).pop();
                  Future.delayed(Duration(milliseconds: 200), () {
                    SystemNavigator.pop();
                  });
                }),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate:
                  FoodSearchDelegate(filteredItems, filterSearchResults));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: banners.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentBannerIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.green, width: 4),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Image.asset(
                              banners[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 180,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Text(
                                bannerTexts[index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: banners.map((url) {
                      int index = banners.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentBannerIndex == index
                              ? Colors.greenAccent
                              : Colors.green,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Column(
                  children: foodCategories.keys.map((category) {
                    return buildFoodCategorySection(
                        category, foodCategories[category]!);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodMenuScreen(),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddToCartPage(
                    cartItems: cartItems,
                    onNavigateBack: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuCardPage(
                    selectedIndex: _selectedIndex,
                    onTabChange: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderPage(
                    onTabChange: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    selectedIndex: _selectedIndex,
                    onTabChange: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
              );
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cartItems.fold<int>(0, (sum, item) => sum + ((item["quantity"] ?? 0) as int))}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        iconSize: 24,
      ),
    );
  }

  Widget buildFoodCategorySection(String title, List<Product> items) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(left: 12),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodDetailScreen(
                      categoryTitle: title,
                      items: items
                          .map((product) => {
                        'name': product.name,
                        'image': product.image,
                        'price': product.price,
                        'description': product.description,
                        'discount': product.discount,
                      })
                          .toList(),
                      cartItems: cartItems,
                      addToCart: addToCart,
                      adjustQuantity: adjustQuantity,
                    ),
                  ),
                );
              },
              child: Text(
                'See All',
                style: TextStyle(color: Colors.green, fontSize: 17),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 269,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              return buildFoodItem(product);
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildFoodItem(Product product) {
    final cartItem = cartItems.firstWhere(
          (item) => item['name'] == product.name,
      orElse: () => {},
    );
    final isFavorite = favoriteItems.any((item) => item.name == product.name);
    int quantity = cartItem.isNotEmpty ? cartItem['quantity'] : 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: {
                'name': product.name,
                'image': product.image,
                'price': product.price,
                'description': product.description,
                'quantity': quantity.toString(),
                'discount': product.discount,
                'discountedPrice': product.discountedPrice.toStringAsFixed(2),
              },
              cartItems: cartItems,
              addToCart: addToCart,
              adjustQuantity: adjustQuantity,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green.shade200,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Colors.green),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 7,
                offset: Offset(4, 3),
              ),
            ],
          ),
          width: 170,
          margin: EdgeInsets.only(right: 5),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          product.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isFavorite) {
                              favoriteItems
                                  .removeWhere((item) => item.name == product.name);
                            } else {
                              favoriteItems.add(product);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Center(
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '-${product.discount}%',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs.${product.price}.00',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Rs.${product.discountedPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Center(
                  child: quantity > 0
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => adjustQuantity({'name': product.name}, -1),
                        icon: Icon(Icons.remove, color: Colors.black),
                      ),
                      Text('$quantity',
                          style: TextStyle(color: Colors.black)),
                      IconButton(
                        onPressed: () => adjustQuantity({'name': product.name}, 1),
                        icon: Icon(Icons.add, color: Colors.black),
                      ),
                    ],
                  )
                      : ElevatedButton(
                    onPressed: () {
                      addToCart({
                        'name': product.name,
                        'image': product.image,
                        'price': product.price,
                        'discountedPrice': product.discountedPrice.toStringAsFixed(2),
                        'quantity': 1,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 40),
                    ),
                    child: Text(
                      'Add To Cart',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCartItem(Map<String, dynamic> cartItem) {
    String price = cartItem['discountedPrice'] ?? cartItem['price'];
    return ListTile(
      leading: Image.asset(
        cartItem['image'],
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
      title: Text(cartItem['name']),
      subtitle: Text("Rs.$price x ${cartItem['quantity']}"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () => adjustQuantity(cartItem, -1),
          ),
          Text(cartItem['quantity'].toString()),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => adjustQuantity(cartItem, 1),
          ),
        ],
      ),
    );
  }

  Widget buildCart() {
    return ListView.builder(
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        return buildCartItem(cartItems[index]);
      },
    );
  }
}

class FoodSearchDelegate extends SearchDelegate {
  final List<Product> foodItems;
  final Function(String) onSearch;

  FoodSearchDelegate(this.foodItems, this.onSearch);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
          onSearch("");
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = foodItems
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          title: Text(product.name),
          subtitle: Row(
            children: [
              Text(
                'Rs.${product.price}',
                style: TextStyle(
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Rs.${product.discountedPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          leading: Image.asset(product.image, width: 50, fit: BoxFit.cover),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = foodItems
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final product = suggestions[index];
        return ListTile(
          title: Text(product.name),
          subtitle: Row(
            children: [
              Text(
                'Rs.${product.price}',
                style: TextStyle(
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Rs.${product.discountedPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          leading: Image.asset(product.image, width: 50, fit: BoxFit.cover),
        );
      },
    );
  }
}