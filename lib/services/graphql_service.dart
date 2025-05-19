import 'dart:async';

import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/model_3d.dart';

class GraphQLService {
  final GraphQLClient client;

  GraphQLService(this.client);

  Future<Model3D?> generateModel(String text) async {
    const String generateModelMutation = '''
    mutation GenerateModel(\$prompt: String!) {
      generateModel(prompt: \$prompt) {
        firebaseUrl
      }
    }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(generateModelMutation),
      variables: <String, dynamic>{
        'prompt': text,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      print('GraphQL Error: ${result.exception.toString()}');
      return null;
    }

    if (result.data == null) {
      return null;
    }

    return Model3D.fromGraphQL(result.data!['generateModel']);
  }

  Future<String?> generate3DTopia(String text) async {
    // IMPORTANT : Changer de mutation à query pour correspondre à la configuration serveur
    const String generate3DTopiaQuery = '''
  query Generate3DTopia(\$text: String!) {
    generate3DTopia(text: \$text) {
      error
      exitCode
      firebaseUrl
      generatedFilePath
      output
    }
  }
  ''';

    try {
      print(
          'Tentative d\'exécution de la query generate3DTopia avec le texte: "$text"');

      // Utiliser QueryOptions au lieu de MutationOptions
      final QueryOptions options = QueryOptions(
        document: gql(generate3DTopiaQuery),
        variables: <String, dynamic>{
          'text': text,
        },
        fetchPolicy: FetchPolicy.noCache,
      );

      // Utiliser client.query au lieu de client.mutate
      final QueryResult result = await client
          .query(options)
          .timeout(const Duration(minutes: 15), onTimeout: () {
        throw TimeoutException(
            'La requête a pris trop de temps à s\'exécuter (plus de 60 secondes)');
      });

      if (result.hasException) {
        print('GraphQL Error: ${result.exception.toString()}');
        return null;
      }

      if (result.data == null || result.data!['generate3DTopia'] == null) {
        print('Aucune donnée reçue du serveur.');
        return null;
      }

      // Vérifier s'il y a une erreur dans la réponse GraphQL
      final error = result.data!['generate3DTopia']['error'];
      if (error != null && error.toString().isNotEmpty) {
        print('Erreur renvoyée par le serveur: $error');
        return null;
      }

      final String? firebaseUrl =
          result.data!['generate3DTopia']['firebaseUrl'];
      print('URL Firebase reçue: $firebaseUrl');
      return firebaseUrl;
    } catch (e, stackTrace) {
      print('Exception pendant l\'appel GraphQL: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}
