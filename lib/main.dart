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
        useMaterial3: true,
      ),

      // Named routes
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/addPlant': (context) => const AddPlantScreen(),
        '/details': (context) => const PlantDetailsScreen(),
      },
    );
  }
}

// ---------------- HOME SCREEN ----------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Care'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Plants',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Plant card
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.local_florist),
                ),
                title: const Text('Aloe Vera'),
                subtitle: const Text('Water every 3 days'),
                trailing: const Icon(Icons.arrow_forward_ios),

                // Navigate using named route
                onTap: () {
                  Navigator.pushNamed(context, '/details');
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Keep your plants healthy 🌱',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),

      // Navigate to Add Plant screen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addPlant');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------- ADD PLANT SCREEN ----------------

class AddPlantScreen extends StatelessWidget {
  const AddPlantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Plant'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Add a New Plant',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Plant Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_florist),
              ),
            ),

            const SizedBox(height: 20),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Watering Schedule',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.water_drop),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Plant'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- PLANT DETAILS SCREEN ----------------

class PlantDetailsScreen extends StatelessWidget {
  const PlantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Details'),
      ),

      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_florist,
                  size: 80,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Aloe Vera',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Water every 3 days',
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}