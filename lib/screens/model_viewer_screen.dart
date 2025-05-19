import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class EnhancedModelViewerScreen extends StatefulWidget {
  final String modelUrl;
  final String? title;

  const EnhancedModelViewerScreen({
    Key? key,
    required this.modelUrl,
    this.title,
  }) : super(key: key);

  @override
  _EnhancedModelViewerScreenState createState() =>
      _EnhancedModelViewerScreenState();
}

class _EnhancedModelViewerScreenState extends State<EnhancedModelViewerScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  double _scale = 1.5; // Commencer avec un modèle 150% plus grand

  @override
  Widget build(BuildContext context) {
    // JavaScript personnalisé pour détecter le chargement et les erreurs

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Visualiseur 3D'),
      ),
      body: Stack(
        children: [
          ModelViewer(
            backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
            src: widget.modelUrl,
            alt: widget.title ?? 'Modèle 3D',
            ar: true,
            autoRotate: true,
            cameraControls: true,
            scale:
                "$_scale $_scale $_scale", // Appliquer l'échelle uniformément sur les 3 axes
            debugLogging: true,
          ),
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 20),
                  Text(
                    'Erreur de chargement du modèle',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _hasError = false;
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          // Contrôles pour ajuster l'échelle du modèle
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _scale = _scale * 0.8; // Réduire de 20%
                      });
                    },
                    child: const Icon(Icons.zoom_out),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Échelle: ${_scale.toStringAsFixed(1)}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _scale = _scale * 1.2; // Augmenter de 20%
                      });
                    },
                    child: const Icon(Icons.zoom_in),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
