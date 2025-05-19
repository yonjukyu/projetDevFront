import 'package:cloud_firestore/cloud_firestore.dart';

class Model3D {
  final String id;
  final String name;
  final String description;
  final String complexity;
  final int vertices;
  final int polygons;
  final String status;
  final DateTime createdAt;
  final String modelUrl;
  final String? imageUrl;

  Model3D({
    required this.id,
    required this.name,
    required this.description,
    required this.complexity,
    required this.vertices,
    required this.polygons,
    required this.status,
    required this.createdAt,
    required this.modelUrl,
    this.imageUrl,
  });

  factory Model3D.fromGraphQL(Map<String, dynamic> data) {
    return Model3D(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      complexity: data['complexity'] ?? '',
      vertices: data['vertices'] ?? 0,
      polygons: data['polygons'] ?? 0,
      status: data['status'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      modelUrl: data['firebaseUrl'] ?? '',
      imageUrl: null, // Les images seront récupérées séparément si nécessaire
    );
  }

  factory Model3D.fromFirebase(Map<String, dynamic> data) {
    return Model3D(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      complexity: data['complexity'] ?? '',
      vertices: data['vertices'] ?? 0,
      polygons: data['polygons'] ?? 0,
      status: data['status'] ?? 'completed',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      modelUrl: data['modelUrl'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }
}
