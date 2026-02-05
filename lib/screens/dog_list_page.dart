import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../database_helper.dart';

class DogListPage extends StatefulWidget {
  @override
  _DogListPageState createState() => _DogListPageState();
}

class _DogListPageState extends State<DogListPage> {
  late Future<List<Dog>> _dogsFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _refreshDogs();
  }

  void _refreshDogs() {
    setState(() {
      _dogsFuture = _dbHelper.getAllDogs();
    });
  }

  Widget _buildDogImage(String? imageBase64) {
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(imageBase64);
        return CircleAvatar(
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        return CircleAvatar(
          child: Icon(Icons.pets),
          backgroundColor: Colors.brown[100],
        );
      }
    }
    return CircleAvatar(
      child: Icon(Icons.pets),
      backgroundColor: Colors.brown[100],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Dogs'),
        backgroundColor: Colors.brown[300],
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.pushNamed(context, '/add-dog');
              _refreshDogs();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Dog>>(
        future: _dogsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final dogs = snapshot.data ?? [];

          if (dogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No dogs available',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: dogs.length,
            itemBuilder: (context, index) {
              final dog = dogs[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: _buildDogImage(dog.imageBase64),
                  title: Text(
                    dog.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${dog.breed} • ${dog.age} years old'),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: dog.isAdopted ? Colors.red[100] : Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          dog.isAdopted ? 'Adopted' : 'Available',
                          style: TextStyle(
                            fontSize: 12,
                            color: dog.isAdopted ? Colors.red[700] : Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'view',
                        child: Text('View Details'),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) => _handleMenuAction(value, dog),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/dog-details',
                      arguments: {'dogId': dog.id},
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleMenuAction(String action, Dog dog) async {
    switch (action) {
      case 'view':
        Navigator.pushNamed(
          context,
          '/dog-details',
          arguments: {'dogId': dog.id},
        );
        break;
      case 'edit':
        await Navigator.pushNamed(
          context,
          '/edit-dog',
          arguments: {'dogId': dog.id},
        );
        _refreshDogs();
        break;
      case 'delete':
        _showDeleteConfirmation(dog);
        break;
    }
  }

  void _showDeleteConfirmation(Dog dog) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${dog.name}?'),
        content: Text('Are you sure you want to delete this dog record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteDog(dog.id!);
              Navigator.pop(context);
              _refreshDogs();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${dog.name} deleted successfully !!')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
