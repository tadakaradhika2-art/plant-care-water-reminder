import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlantCareApp());
}

const _green = Color(0xFF2E6B4F);
const _storageKey = 'plant_care_plants_v1';
const _themeKey = 'plant_care_dark_mode_v1';

class Plant {
  Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.emoji,
    required this.intervalDays,
    required this.lastWatered,
    required this.location,
    required this.history,
  });

  final String id;
  String name;
  String species;
  String emoji;
  int intervalDays;
  DateTime? lastWatered;
  String location;
  List<DateTime> history;

  DateTime get nextWatering =>
      (lastWatered ?? DateTime.now()).add(Duration(days: intervalDays));

  bool get isDue {
    final now = DateTime.now();
    final due = DateTime(nextWatering.year, nextWatering.month, nextWatering.day);
    final today = DateTime(now.year, now.month, now.day);
    return !due.isAfter(today);
  }

  int get daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(nextWatering.year, nextWatering.month, nextWatering.day);
    return due.difference(today).inDays;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'species': species,
        'emoji': emoji,
        'intervalDays': intervalDays,
        'lastWatered': lastWatered?.toIso8601String(),
        'location': location,
        'history': history.map((d) => d.toIso8601String()).toList(),
      };

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'My Plant',
        species: json['species'] as String? ?? 'Houseplant',
        emoji: json['emoji'] as String? ?? '🪴',
        intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 3,
        lastWatered: json['lastWatered'] == null
            ? null
            : DateTime.tryParse(json['lastWatered'] as String),
        location: json['location'] as String? ?? 'Home',
        history: ((json['history'] as List?) ?? [])
            .map((e) => DateTime.parse(e as String))
            .toList(),
      );
}

class PlantStore extends ChangeNotifier {
  List<Plant> plants = [];
  bool isLoading = true;
  bool isDarkMode = false;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDarkMode = prefs.getBool(_themeKey) ?? false;
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        plants = decoded
            .map((e) => Plant.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        plants = _starterPlants();
        await _savePlants();
      }
    } catch (_) {
      plants = _starterPlants();
    }
    isLoading = false;
    notifyListeners();
  }

  List<Plant> _starterPlants() {
    final now = DateTime.now();
    return [
      Plant(
        id: 'starter-1',
        name: 'Sunny',
        species: 'Money Plant',
        emoji: '🌿',
        intervalDays: 3,
        lastWatered: now.subtract(const Duration(days: 2)),
        location: 'Living room',
        history: [now.subtract(const Duration(days: 2))],
      ),
      Plant(
        id: 'starter-2',
        name: 'Lily',
        species: 'Peace Lily',
        emoji: '🪷',
        intervalDays: 4,
        lastWatered: now.subtract(const Duration(days: 1)),
        location: 'Bedroom',
        history: [now.subtract(const Duration(days: 1))],
      ),
    ];
  }

  Future<void> _savePlants() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(plants.map((p) => p.toJson()).toList()),
    );
  }

  Future<void> savePlant(Plant plant) async {
    final index = plants.indexWhere((p) => p.id == plant.id);
    if (index == -1) {
      plants.insert(0, plant);
    } else {
      plants[index] = plant;
    }
    await _savePlants();
    notifyListeners();
  }

  Future<void> deletePlant(String id) async {
    plants.removeWhere((p) => p.id == id);
    await _savePlants();
    notifyListeners();
  }

  Future<void> waterPlant(String id) async {
    final plant = plants.firstWhere((p) => p.id == id);
    final now = DateTime.now();
    plant.lastWatered = now;
    plant.history.insert(0, now);
    await _savePlants();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
    notifyListeners();
  }
}

class PlantCareApp extends StatefulWidget {
  const PlantCareApp({super.key});

  @override
  State<PlantCareApp> createState() => _PlantCareAppState();
}

class _PlantCareAppState extends State<PlantCareApp> {
  final PlantStore store = PlantStore();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Plant Care',
        themeMode: store.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: _green),
          scaffoldBackgroundColor: const Color(0xFFF5F8F3),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF5F8F3),
            surfaceTintColor: Colors.transparent,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF4F7F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8BC6A5),
            brightness: Brightness.dark,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
        home: store.isLoading
            ? const _LoadingScreen()
            : HomeScreen(store: store),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});
  final PlantStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _query = '';
  bool _dueOnly = false;

  PlantStore get store => widget.store;

  @override
  Widget build(BuildContext context) {
    final plants = store.plants.where((p) {
      final matches = '${p.name} ${p.species} ${p.location}'
          .toLowerCase()
          .contains(_query.toLowerCase());
      return matches && (!_dueOnly || p.isDue);
    }).toList();
    final dueCount = store.plants.where((p) => p.isDue).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.eco_rounded),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plant Care', style: TextStyle(fontWeight: FontWeight.w800)),
                Text('A little love, every day',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: store.isDarkMode ? 'Light mode' : 'Dark mode',
            onPressed: store.toggleTheme,
            icon: Icon(store.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: _tab == 0
            ? _buildHome(context, plants, dueCount)
            : _HistoryScreen(store: store),
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showPlantForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add plant'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'My plants',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'Watering history',
          ),
        ],
      ),
    );
  }

  Widget _buildHome(BuildContext context, List<Plant> plants, int dueCount) {
    final wateredToday = store.plants.where((p) {
      final d = p.lastWatered;
      if (d == null) return false;
      final now = DateTime.now();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D573E), Color(0xFF478765)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Grow a greener day 🌱',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(
                      dueCount == 0
                          ? 'Your plants are on track. Keep it up!'
                          : '$dueCount plant${dueCount == 1 ? '' : 's'} need${dueCount == 1 ? 's' : ''} your attention today.',
                      style: const TextStyle(
                          color: Color(0xFFE1F0E5), height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _green,
                      ),
                      onPressed: () => setState(() => _dueOnly = !_dueOnly),
                      child: Text(_dueOnly ? 'Show all plants' : 'Check reminders'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text('🪴', style: TextStyle(fontSize: 62)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.eco_outlined,
                label: 'Total plants',
                value: '${store.plants.length}',
                color: const Color(0xFFDBEBDD),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.water_drop_outlined,
                label: 'Watered today',
                value: '$wateredToday',
                color: const Color(0xFFDDEBF9),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.notifications_active_outlined,
                label: 'Due',
                value: '$dueCount',
                color: const Color(0xFFFFE9C9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text('Your plants',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            ),
            Text('${plants.length} plants',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(
            hintText: 'Search by name, type, or location',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 12),
        if (store.plants.isEmpty)
          _EmptyState(onAdd: () => _showPlantForm(context))
        else if (plants.isEmpty)
          const Padding(
            padding: EdgeInsets.all(28),
            child: Center(child: Text('No plants match your search.')),
          )
        else
          ...plants.map((plant) => _PlantCard(
                plant: plant,
                onWater: () async {
                  await store.waterPlant(plant.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${plant.name} has been watered! 💧')),
                    );
                  }
                },
                onEdit: () => _showPlantForm(context, plant: plant),
                onDelete: () => _confirmDelete(context, plant),
              )),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tips_and_updates_outlined),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Plant tip: Check the soil before watering. Different plants have different needs, even when their schedules look similar.',
                  style: TextStyle(height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showPlantForm(BuildContext context, {Plant? plant}) async {
    final result = await showModalBottomSheet<Plant>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _PlantForm(plant: plant),
    );
    if (result != null) {
      await store.savePlant(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(plant == null ? 'Plant added!' : 'Plant updated!')),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, Plant plant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete plant?'),
        content: Text('Remove ${plant.name} and its watering history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await store.deletePlant(plant.id);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 9),
          child: Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color,
                child: Icon(icon, size: 19, color: const Color(0xFF245D43)),
              ),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      );
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({
    required this.plant,
    required this.onWater,
    required this.onEdit,
    required this.onDelete,
  });
  final Plant plant;
  final VoidCallback onWater;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final due = plant.isDue;
    final status = due
        ? 'Watering due'
        : plant.daysUntil == 1
            ? 'Water tomorrow'
            : 'Due in ${plant.daysUntil} days';
    final color = due ? const Color(0xFFB45309) : const Color(0xFF28734D);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 76,
                  height: 86,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F2E8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(plant.emoji, style: const TextStyle(fontSize: 43)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plant.name,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(plant.species,
                          style: TextStyle(color: Theme.of(context).hintColor)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: Theme.of(context).hintColor),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(plant.location,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).hintColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: due
                              ? const Color(0xFFFFE9C9)
                              : const Color(0xFFE0F1E5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(status,
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit plant')),
                    PopupMenuItem(value: 'delete', child: Text('Delete plant')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Every ${plant.intervalDays} day${plant.intervalDays == 1 ? '' : 's'} · Last watered ${_formatDate(plant.lastWatered)}',
                    style: TextStyle(
                        fontSize: 11, color: Theme.of(context).hintColor),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onWater,
                  icon: const Icon(Icons.water_drop_rounded, size: 17),
                  label: const Text('Water now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantForm extends StatefulWidget {
  const _PlantForm({this.plant});
  final Plant? plant;

  @override
  State<_PlantForm> createState() => _PlantFormState();
}

class _PlantFormState extends State<_PlantForm> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _species;
  late final TextEditingController _location;
  late int _interval;
  late String _emoji;

  static const _emojis = ['🌿', '🪴', '🌵', '🌻', '🌷', '🪷', '🌱', '🌴'];

  @override
  void initState() {
    super.initState();
    final p = widget.plant;
    _name = TextEditingController(text: p?.name ?? '');
    _species = TextEditingController(text: p?.species ?? '');
    _location = TextEditingController(text: p?.location ?? 'Home');
    _interval = p?.intervalDays ?? 3;
    _emoji = p?.emoji ?? '🪴';
  }

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 4, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.plant == null ? 'Add a new plant' : 'Edit plant',
                  style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text('Give your plant a name and set its watering routine.',
                  style: TextStyle(color: Theme.of(context).hintColor)),
              const SizedBox(height: 18),
              const Text('Choose an icon'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _emojis.map((e) {
                  final selected = e == _emoji;
                  return ChoiceChip(
                    label: Text(e, style: const TextStyle(fontSize: 23)),
                    selected: selected,
                    onSelected: (_) => setState(() => _emoji = e),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Plant name', prefixIcon: Icon(Icons.edit_outlined)),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter a plant name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _species,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Plant type', prefixIcon: Icon(Icons.eco_outlined)),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter the plant type'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _location,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Location', prefixIcon: Icon(Icons.location_on_outlined)),
              ),
              const SizedBox(height: 16),
              
DropdownButtonFormField<int>(
  initialValue: _interval,
  decoration: const InputDecoration(
    labelText: 'Watering frequency',
    prefixIcon: Icon(Icons.calendar_month_outlined),
  ),
  items: List.generate(
    14,
    (i) => DropdownMenuItem<int>(
      value: i + 1,
      child: Text('Every ${i + 1} day${i == 0 ? '' : 's'}'),
    ),
  ),
  onChanged: (value) {
    if (value != null) {
      setState(() => _interval = value);
    }
  },
),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (!_key.currentState!.validate()) return;
                    final old = widget.plant;
                    Navigator.pop(
                      context,
                      Plant(
                        id: old?.id ??
                            DateTime.now().microsecondsSinceEpoch.toString(),
                        name: _name.text.trim(),
                        species: _species.text.trim(),
                        emoji: _emoji,
                        intervalDays: _interval,
                        lastWatered: old?.lastWatered,
                        location: _location.text.trim().isEmpty
                            ? 'Home'
                            : _location.text.trim(),
                        history: old?.history ?? [],
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: Text(widget.plant == null ? 'Save plant' : 'Update plant'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryScreen extends StatelessWidget {
  const _HistoryScreen({required this.store});
  final PlantStore store;

  @override
  Widget build(BuildContext context) {
    final events = <({Plant plant, DateTime date})>[];
    for (final plant in store.plants) {
      for (final date in plant.history) {
        events.add((plant: plant, date: date));
      }
    }
    events.sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Watering history',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('A record of every time you watered your plants.',
            style: TextStyle(color: Theme.of(context).hintColor)),
        const SizedBox(height: 20),
        if (events.isEmpty)
          const _EmptyState(
            message: 'No watering records yet. Water a plant to start your history.',
          )
        else
          ...events.map(
            (event) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE2F0E5),
                  child: Text(event.plant.emoji, style: const TextStyle(fontSize: 23)),
                ),
                title: Text(event.plant.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(event.plant.species),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.water_drop_rounded,
                        color: Color(0xFF3979B8), size: 19),
                    const SizedBox(height: 3),
                    Text(_formatDate(event.date),
                        style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.onAdd, this.message});
  final VoidCallback? onAdd;
  final String? message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            const Text('🌱', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 10),
            const Text('Your garden starts here',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              message ?? 'Add your first plant and start building a care routine.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).hintColor, height: 1.4),
            ),
            if (onAdd != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add your first plant'),
              ),
            ],
          ],
        ),
      );
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Never';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final now = DateTime.now();
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Today';
  }
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
