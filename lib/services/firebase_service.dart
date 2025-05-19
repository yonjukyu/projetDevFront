import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/model_3d.dart';

class FirebaseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer tous les fichiers PLY dans le bucket Firebase Storage
  Future<List<String>> getAllPlyFilesUrls() async {
    final ListResult result = await _storage.ref().listAll();

    List<String> plyUrls = [];
    for (var item in result.items) {
      if (item.name.toLowerCase().endsWith('.ply')) {
        final String downloadUrl = await item.getDownloadURL();
        plyUrls.add(downloadUrl);
      }
    }

    return plyUrls;
  }

  Future<List<Model3D>> getAllModels() async {
    // Liste pour stocker les modèles 3D
    List<Model3D> models = [];

    try {
      // 1. Récupérer tous les fichiers du bucket
      final ListResult result = await _storage.ref().listAll();

      // 2. Pour chaque élément, vérifier s'il s'agit d'un fichier PLY
      for (var item in result.items) {
        if (item.name.toLowerCase().endsWith('.glb')) {
          // 3. Récupérer l'URL de téléchargement
          final String downloadUrl = await item.getDownloadURL();

          // 4. Récupérer les métadonnées du fichier
          final FullMetadata metadata = await item.getMetadata();

          String name = item.name;
          String description = '';
          String complexity = '0';
          int vertices = 0;
          int polygons = 0;
          String status = 'available';
          String imageUrl = '';

          // 7. Créer un nouvel objet Model3D
          Model3D model = Model3D(
            name: name,
            description: description,
            complexity: complexity,
            vertices: vertices,
            polygons: polygons,
            status: status,
            modelUrl: downloadUrl,
            imageUrl: imageUrl,
            id: metadata.fullPath,
            createdAt: DateTime.now(),
          );

          // 8. Ajouter le modèle à la liste
          models.add(model);
        }
      }

      return models;
    } catch (e) {
      print('Erreur lors de la récupération des modèles 3D: $e');
      return [];
    }
  }

  // Sauvegarder un nouveau modèle dans Firestore
  Future<void> saveModel(Model3D model) async {
    await _firestore.collection('models').add({
      'name': model.name,
      'description': model.description,
      'complexity': model.complexity,
      'vertices': model.vertices,
      'polygons': model.polygons,
      'status': model.status,
      'createdAt': FieldValue.serverTimestamp(),
      'modelUrl': model.modelUrl,
      'imageUrl': model.imageUrl,
    });
  }

  // Obtenir l'URL de téléchargement à partir du nom du fichier
  Future<String?> getDownloadUrlFromFileName(String fileName) async {
    try {
      return await _storage.ref(fileName).getDownloadURL();
    } catch (e) {
      print('Erreur lors de la récupération de l\'URL: $e');
      return null;
    }
  }
}
