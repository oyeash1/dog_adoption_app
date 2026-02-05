import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/dog_list_page.dart';
import 'screens/add_edit_dog_page.dart';
import 'screens/dog_details_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog Adoption App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/dogs': (context) => DogListPage(),
        '/add-dog': (context) => AddEditDogPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dog-details') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => DogDetailsPage(dogId: args['dogId']),
          );
        } else if (settings.name == '/edit-dog') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AddEditDogPage(dogId: args['dogId']),
          );
        }
        return null;
      },
    );
  }
}
