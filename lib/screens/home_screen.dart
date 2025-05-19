import 'package:flutter/material.dart';

import '../models/model_3d.dart';
import '../services/firebase_service.dart';
import '../widget/model_card.dart';
import 'model_generation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late List<Model3D> _models = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Model3D> models = await _firebaseService.getAllModels();
      setState(() {
        _models = models;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des modèles: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Modèles 3D'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadModels,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _models.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Aucun modèle trouvé',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadModels,
                        child: const Text('Rafraîchir'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _models.length,
                  itemBuilder: (context, index) {
                    return ModelCard(model: _models[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ModelGenerationScreen(),
            ),
          ).then((_) => _loadModels());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
