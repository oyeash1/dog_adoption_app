import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../database_helper.dart';

class DogDetailsPage extends StatefulWidget {
  final int dogId;

  DogDetailsPage({required this.dogId});

  @override
  _DogDetailsPageState createState() => _DogDetailsPageState();
}

class _DogDetailsPageState extends State<DogDetailsPage> {
  late Future<Dog?> _dogFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _dogFuture = _dbHelper.getDog(widget.dogId);
  }

  Widget _buildDogImage(String? imageBase64) {
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(imageBase64);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 300,
        );
      } catch (e) {
        return _buildPlaceholderImage();
      }
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[300],
      child: Icon(
        Icons.pets,
        size: 100,
        color: Colors.grey[600],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dog Details'),
        backgroundColor: Colors.brown[300],
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                '/edit-dog',
                arguments: {'dogId': widget.dogId},
              );
              setState(() {
                _dogFuture = _dbHelper.getDog(widget.dogId);
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Dog?>(
        future: _dogFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final dog = snapshot.data;
          if (dog == null) {
            return Center(child: Text('Dog not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDogImage(dog.imageBase64),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dog.name,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: dog.isAdopted ? Colors.red[100] : Colors.green[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              dog.isAdopted ? 'Adopted' : 'Available',
                              style: TextStyle(
                                color: dog.isAdopted ? Colors.red[700] : Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildInfoCard('Breed', dog.breed, Icons.category),
                      SizedBox(height: 12),
                      _buildInfoCard('Age', '${dog.age} years old', Icons.cake),
                      SizedBox(height: 20),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.brown[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.brown[200]!),
                        ),
                        child: Text(
                          dog.description,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.brown[700],
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      if (!dog.isAdopted)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _markAsAdopted(dog),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[400],
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Mark as Adopted',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown[400], size: 24),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _markAsAdopted(Dog dog) async {
    final updatedDog = Dog(
      id: dog.id,
      name: dog.name,
      breed: dog.breed,
      age: dog.age,
      description: dog.description,
      imageBase64: dog.imageBase64,
      isAdopted: true,
    );

    await _dbHelper.updateDog(updatedDog);
    setState(() {
      _dogFuture = _dbHelper.getDog(widget.dogId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${dog.name} marked as adopted!')),
    );
  }
}
