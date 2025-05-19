import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase avec la configuration automatique
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialiser le client GraphQL
  await initHiveForFlutter();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuration du client GraphQL
    final HttpLink httpLink = HttpLink('http://192.168.1.170:8080/graphql');

    WidgetsFlutterBinding.ensureInitialized();
    // Création du client GraphQL
    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: HiveStore()),
    );

    // Créer un ValueNotifier pour le client GraphQL
    final ValueNotifier<GraphQLClient> clientNotifier =
        ValueNotifier<GraphQLClient>(client);

    return GraphQLProvider(
      client: clientNotifier,
      child: MaterialApp(
        title: 'Visualisateur 3D',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
