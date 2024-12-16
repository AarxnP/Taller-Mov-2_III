
import 'package:app_taller/Navegacion/drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CreateNoteScreen extends StatelessWidget {
  final String userId;

  CreateNoteScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();

    Future<void> saveNote() async {
      final title = titleController.text;
      final description = descriptionController.text;
      final price = double.tryParse(priceController.text) ?? 0.0;

      if (title.isEmpty || description.isEmpty || price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, completa todos los campos')),
        );
        return;
      }

      try {
        DatabaseReference notesRef = FirebaseDatabase.instance.ref('users/$userId/notes');
        final newNoteRef = notesRef.push();

        await newNoteRef.set({
          'title': title,
          'description': description,
          'price': price,
        });

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la nota: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nueva Nota",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      drawer: MyDrawer(userId: userId),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Crear una Nota",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.deepPurpleAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
                  ),
                  prefixIcon: Icon(Icons.title, color: Colors.deepPurpleAccent),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.deepPurpleAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
                  ),
                  prefixIcon: Icon(Icons.description, color: Colors.deepPurpleAccent),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nota',
                  labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.deepPurpleAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
                  ),
                  prefixIcon: Icon(Icons.note, color: Colors.deepPurpleAccent),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "Guardar Nota",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}