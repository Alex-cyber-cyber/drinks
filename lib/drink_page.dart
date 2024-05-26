import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cocktail App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Cocktail Categories'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _categories = [];
  List<String> _images = [
    'https://www.brewersfriend.com/images/1/3/9/4/1/2/2/IMG-3102.jpeg', // Placeholder image URL
    'https://s3-eu-west-1.amazonaws.com/verema/images/valoraciones/0011/0991/coctel.jpg?1353314930',
    'https://img.freepik.com/fotos-premium/batido-fresa_105495-418.jpg',
    'https://www.brewersfriend.com/images/1/3/9/4/1/2/2/IMG-3102.jpeg',
    'https://www.anediblemosaic.com/wp-content/uploads//2021/02/french-hot-chocolate-featurd-image.jpg',
    'https://opendrinks.io/img/pok-shot.fd8b0bcd.jpg',
    'https://www.marthastewart.com/thmb/xdSKUKWUJ0KV3qUkhbdom6TFX04=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/tea-coffee-which-is-better-for-you-0622-02efa81f8ce64ca6891048ef47fad04f.jpg',
    'https://www.allrecipes.com/thmb/YEmM5Pk9YWulK3sbyBgoMaAm6gI=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/31338-JW-105_vanilla-cherry-tangerine-liqueursj_meredith-9f7c95125e954e8b902cd70673167a28.jpg',
    'https://www.7up.com/images/recipes/hero/7up-holiday-party-punch_hero_m.jpg',
    'https://www.brewersfriend.com/images/1/3/9/4/1/2/2/IMG-3102.jpeg',
    'https://c8.alamy.com/comp/MGCHJG/poznan-poland-apr-6-2018-bottles-of-global-soft-drink-brands-including-products-of-coca-cola-company-and-pepsico-MGCHJG.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final response =
        await http.get(Uri.parse('https://www.thecocktaildb.com/api/json/v1/1/list.php?c=list'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _categories = List<String>.from(data['drinks'].map((drink) => drink['strCategory']));
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> _fetchDrinks(String category) async {
    final response =
        await http.get(Uri.parse('https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=$category'));
    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DrinksPage(category: category, drinks: json.decode(response.body)['drinks']),
        ),
      );
    } else {
      throw Exception('Failed to load drinks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _categories.isEmpty
            ? CircularProgressIndicator()
            : GridView.builder(
                padding: EdgeInsets.all(10.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _fetchDrinks(_categories[index]);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Stack(
                          children: [
                            Image.network(
                              _images[index % _images.length],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    _categories[index],
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorías',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Acerca de',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 5,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchCategories,
        tooltip: 'Recargar',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
class DrinksPage extends StatelessWidget {
  final String category;
  final List<dynamic> drinks;

  const DrinksPage({Key? key, required this.category, required this.drinks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: drinks.length,
              itemBuilder: (context, index) {
                final drink = drinks[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(drink['strDrinkThumb']),
                    ),
                    title: Text(drink['strDrink']),
                    subtitle: Text(drink['idDrink']),
                    onTap: () {
                      // Handle drink tap
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Regresar'),
            ),
          ),
        ],
      ),
    );
  }
}
