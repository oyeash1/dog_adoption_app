import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dog Adoption Center'),
        backgroundColor: Colors.brown[300],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.brown[50]!, Colors.brown[100]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets,
                  size: 120,
                  color: Colors.brown[400],
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome to Dog Adoption Center',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Find your perfect furry companion',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown[600],
                  ),
                ),
                SizedBox(height: 40),
                Column(
                  children: [
                    _buildActionCard(
                      context,
                      'View All Dogs',
                      Icons.list,
                      Colors.blue,
                      () => Navigator.pushNamed(context, '/dogs'),
                    ),
                    SizedBox(height: 16),
                    _buildActionCard(
                      context,
                      'Add New Dog',
                      Icons.add_circle,
                      Colors.green,
                      () => Navigator.pushNamed(context, '/add-dog'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        child: Container(
          width: double.infinity,
          height: 80,
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
