import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../database_helper.dart';

class AddEditDogPage extends StatefulWidget {
  final int? dogId;

  AddEditDogPage({this.dogId});

  @override
  _AddEditDogPageState createState() => _AddEditDogPageState();
}

class _AddEditDogPageState extends State<AddEditDogPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isAdopted = false;
  bool _isLoading = false;
  String? _imageBase64;
  Uint8List? _imageBytes;
  
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.dogId != null) {
      _loadDogData();
    }
  }

  Future<void> _loadDogData() async {
    final dog = await _dbHelper.getDog(widget.dogId!);
    if (dog != null) {
      setState(() {
        _nameController.text = dog.name;
        _breedController.text = dog.breed;
        _ageController.text = dog.age.toString();
        _descriptionController.text = dog.description;
        _imageBase64 = dog.imageBase64;
        _isAdopted = dog.isAdopted;
        
        if (_imageBase64 != null) {
          _imageBytes = base64Decode(_imageBase64!);
        }
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final base64String = base64Encode(bytes);
        
        setState(() {
          _imageBytes = bytes;
          _imageBase64 = base64String;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_imageBytes != null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _imageBytes!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _imageBytes = null;
                    _imageBase64 = null;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 60,
            color: Colors.grey[400],
          ),
          SizedBox(height: 10),
          Text(
            'No image selected',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dogId == null ? 'Add Dog' : 'Edit Dog'),
        backgroundColor: Colors.brown[300],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Dog Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter dog name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _breedController,
              decoration: InputDecoration(
                labelText: 'Breed',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter breed';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: 'Age (years)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter age';
                }
                final age = int.tryParse(value);
                if (age == null || age <= 0) {
                  return 'Please enter valid age';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // Image Upload Section
            Text(
              'Dog Photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.brown[700],
              ),
            ),
            SizedBox(height: 8),
            _buildImagePreview(),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo_camera),
              label: Text('Select Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[300],
              ),
            ),
            
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Adopted'),
              subtitle: Text(_isAdopted ? 'This dog has been adopted' : 'Available for adoption'),
              value: _isAdopted,
              onChanged: (value) {
                setState(() {
                  _isAdopted = value;
                });
              },
              secondary: Icon(_isAdopted ? Icons.favorite : Icons.favorite_border),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveDog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[300],
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.dogId == null ? 'Add Dog' : 'Update Dog',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dog = Dog(
        id: widget.dogId,
        name: _nameController.text,
        breed: _breedController.text,
        age: int.parse(_ageController.text),
        description: _descriptionController.text,
        imageBase64: _imageBase64,
        isAdopted: _isAdopted,
      );

      if (widget.dogId == null) {
        await _dbHelper.insertDog(dog);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dog added successfully')),
        );
      } else {
        await _dbHelper.updateDog(dog);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dog updated successfully')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving dog: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
