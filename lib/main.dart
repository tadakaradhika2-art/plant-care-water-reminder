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
      title: 'Plant Care',
      theme: ThemeData(
        primarySwatch: Colors.green,
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
        title: const Text('Plant Care 🌱'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'My Plants',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),

          PlantCard(
            name: 'Rose',
            type: 'Flower',
            water: 'Today',
          ),

          PlantCard(
            name: 'Aloe Vera',
            type: 'Succulent',
            water: 'Tomorrow',
          ),

          PlantCard(
            name: 'Money Plant',
            type: 'Indoor Plant',
            water: 'In 2 days',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  final String name;
  final String type;
  final String water;

  const PlantCard({
    super.key,
    required this.name,
    required this.type,
    required this.water,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(
          Icons.local_florist,
          size: 40,
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$type\nWater: $water'),
      ),
    );
  }
}