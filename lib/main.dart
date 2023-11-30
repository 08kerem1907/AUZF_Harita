import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Building {
  String name;
  Offset location; // Bina konumu

  Building({required this.name, required this.location});
}

class MyApp extends StatelessWidget {
  final List<Building> buildings = [
    Building(name: 'A Blok', location: const Offset(100, 150)),
    Building(name: 'B Blok', location: const Offset(200, 250)),
    Building(name: 'C Blok', location: const Offset(100, 50)),
    // Diğer bina adları ve konumları buraya eklenebilir
  ];

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(buildings: buildings),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<Building> buildings;

  MyHomePage({required this.buildings});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String query = '';
  Offset selectedLocation = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () async {
              String? selectedBuilding = await showSearch(
                context: context,
                delegate: CustomSearchDelegate(widget.buildings),
              );

              if (selectedBuilding!.isNotEmpty) {
                Building selectedBuildingData = widget.buildings
                    .firstWhere((building) => building.name == selectedBuilding);

                // Seçilen binanın konumunu alın
                selectedLocation = selectedBuildingData.location;

                // Haritayı büyültmek için yeni bir sayfaya geçin
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapDetailPage(
                      selectedLocation: selectedLocation,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: InteractiveViewer(
        maxScale: 14.0,
        minScale: 1.0,
        boundaryMargin: const EdgeInsets.all(20.0),
        onInteractionUpdate: (details) {
          // Haritanın genişlemesi için bir kontrol ekleyin
          double newScale = details.scale;
          if (newScale < 1.0) {
            newScale = 1.0;
          } else if (newScale > 14.0) {
            newScale = 14.0;
          }

          // Yeni ölçeği kullanarak haritayı genişletin
          setState(() {
          });
        },
        child: Center(
          child: Image.asset(
            'assets/kerem-okul4.jpg',
          ),
        ),
      ),

    );
  }
}

class MapDetailPage extends StatefulWidget {
  final Offset selectedLocation;

  const MapDetailPage({super.key, required this.selectedLocation});

  @override
  // ignore: library_private_types_in_public_api
  _MapDetailPageState createState() => _MapDetailPageState();
}

class _MapDetailPageState extends State<MapDetailPage> {
  double scale = 1.0;
  double startingScale = 1.0;
  Offset focalPoint = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Detail'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white),
            onPressed: () {
              // Haritayı küçültmek için Navigator'ı kullanın
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: GestureDetector(
        onScaleStart: (details) {
          startingScale = scale;
          focalPoint = details.focalPoint;
        },
        onScaleUpdate: (details) {
          // Parmağın hareketine göre ölçeği güncelle
          setState(() {
            scale = startingScale * details.scale;
            focalPoint = details.focalPoint;
          });
        },
        child: Center(
          child: Transform.scale(
            scale: scale,
            origin: focalPoint,
            child: Stack(
              children: [
                // Harita resmi
                Image.asset(
                  'assets/kerem-okul4.jpg',
                ),
                // Seçilen yerde kırmızı bir nokta
                Positioned(
                  top: widget.selectedLocation.dy - 8,
                  left: widget.selectedLocation.dx - 8,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  final List<Building> buildings;

  CustomSearchDelegate(this.buildings);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          close(context, '');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final filteredBuildings = buildings
        .where((building) =>
        building.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredBuildings.length,
      itemBuilder: (context, index) {
        final building = filteredBuildings[index];
        return ListTile(
          title: Text(building.name),
          onTap: () {
            // Bina adına tıklandığında arama ekranını kapat ve seçilen binayı geri döndür
            close(context, building.name);
          },
        );
      },
    );
  }
}
