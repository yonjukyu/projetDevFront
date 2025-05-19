import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:projet_dev_front/screens/home_screen.dart';

import '../models/model_3d.dart';
import '../services/firebase_service.dart';
import '../services/graphql_service.dart';

class ModelGenerationScreen extends StatefulWidget {
  const ModelGenerationScreen({super.key});

  @override
  State<ModelGenerationScreen> createState() => _ModelGenerationScreenState();
}

class _ModelGenerationScreenState extends State<ModelGenerationScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  String? _error;
  String? _generatedModelUrl;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateModel() async {
    if (_promptController.text.isEmpty) {
      setState(() {
        _error = 'Veuillez entrer une description pour le modèle';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = null;
      _generatedModelUrl = null;
    });

    try {
      final GraphQLClient client = GraphQLProvider.of(context).value;
      final GraphQLService graphQLService = GraphQLService(client);
      final String? firebaseUrl =
          await graphQLService.generate3DTopia(_promptController.text);

      setState(() {
        _isGenerating = false;
        if (firebaseUrl != null) {
          _generatedModelUrl = firebaseUrl;
        } else {
          _error = 'Erreur lors de la génération du modèle';
        }
      });

      if (_generatedModelUrl != null) {
        // Créer un modèle simple avec les informations disponibles
        final Model3D newModel = Model3D(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _promptController.text,
          description: _promptController.text,
          complexity: 'Medium',
          vertices: 0, // Ces informations ne sont pas disponibles
          polygons: 0, // Ces informations ne sont pas disponibles
          status: 'completed',
          createdAt: DateTime.now(),
          modelUrl: _generatedModelUrl!,
        );

        // Sauvegarder le modèle dans Firestore
        FirebaseService().saveModel(newModel);

        // Naviguer vers l'écran de visualisation
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _error = 'Erreur: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générer un nouveau modèle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Décrivez le modèle 3D que vous souhaitez générer:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                hintText: 'Ex: Un chien assis avec un chapeau',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              enabled: !_isGenerating,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Center(
              child: _isGenerating
                  ? Column(
                      children: [
                        LoadingAnimationWidget.staggeredDotsWave(
                          color: Theme.of(context).primaryColor,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Génération en cours...\nCela peut prendre plusieurs minutes',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _generateModel,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 12.0,
                        ),
                      ),
                      child: const Text('Générer le modèle'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
