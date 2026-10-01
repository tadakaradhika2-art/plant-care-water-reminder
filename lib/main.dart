import 'package:flutter/material.dart';

void main() {
  runApp(const PlantCareApp());
}

class PlantCareApp extends StatelessWidget {
  const PlantCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plant Care Water Reminder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Plants',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PlantCard(
            plantName: 'Rose',
            wateringStatus: 'Watering: Today',
            icon: '🌹',
          ),
          SizedBox(height: 12),

          PlantCard(
            plantName: 'Aloe Vera',
            wateringStatus: 'Watering: Tomorrow',
            icon: '🌿',
          ),
          SizedBox(height: 12),

          PlantCard(
            plantName: 'Money Plant',
            wateringStatus: 'Watering: In 2 days',
            icon: '🪴',
          ),
        ],
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  final String plantName;
  final String wateringStatus;
  final String icon;

  const PlantCard({
    super.key,
    required this.plantName,
    required this.wateringStatus,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Text(
          icon,
          style: const TextStyle(
            fontSize: 40,
          ),
        ),
        title: Text(
          plantName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            wateringStatus,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.water_drop,
          color: Colors.blue,
        ),
      ),
    );
  }
}