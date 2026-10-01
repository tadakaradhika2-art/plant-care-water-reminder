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
    // MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plant Care 🌱',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // LayoutBuilder
          final isWideScreen = constraints.maxWidth >= 600;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth > 600 ? 40 : 16,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning! 👋',
                  style: TextStyle(
                    fontSize: screenWidth > 600 ? 32 : 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Take care of your plants every day.',
                  style: TextStyle(
                    fontSize: screenWidth > 600 ? 18 : 16,
                  ),
                ),

                const SizedBox(height: 20),

                // Responsive statistics section
                isWideScreen
                    ? Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              Icons.water_drop,
                              '2',
                              'Water Today',
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _statCard(
                              Icons.eco,
                              '3',
                              'My Plants',
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _statCard(
                              Icons.check_circle,
                              '1',
                              'Completed',
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _statCard(
                                  Icons.water_drop,
                                  '2',
                                  'Water Today',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _statCard(
                                  Icons.eco,
                                  '3',
                                  'My Plants',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _statCard(
                            Icons.check_circle,
                            '1',
                            'Completed',
                          ),
                        ],
                      ),

                const SizedBox(height: 25),

                const Text(
                  'My Plants',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // Responsive plant cards
                isWideScreen
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _plantCard(
                              Icons.local_florist,
                              'Rose',
                              'Flower',
                              'Today',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _plantCard(
                              Icons.spa,
                              'Aloe Vera',
                              'Succulent',
                              'Tomorrow',
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _plantCard(
                            Icons.local_florist,
                            'Rose',
                            'Flower',
                            'Today',
                          ),
                          const SizedBox(height: 10),
                          _plantCard(
                            Icons.spa,
                            'Aloe Vera',
                            'Succulent',
                            'Tomorrow',
                          ),
                        ],
                      ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  // Reusable statistics widget
  Widget _statCard(
    IconData icon,
    String number,
    String label,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 35,
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  // Reusable plant card
  Widget _plantCard(
    IconData icon,
    String name,
    String type,
    String watering,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green.shade100,
              child: Icon(
                icon,
                color: Colors.green,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(type),
                  Text('Water: $watering 💧'),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}