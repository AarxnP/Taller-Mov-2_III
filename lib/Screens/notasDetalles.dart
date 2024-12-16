import 'package:app_taller/Navegacion/drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class NotesScreen extends StatefulWidget {
  final String userId;

  NotesScreen({required this.userId});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late DatabaseReference notesRef;

  @override
  void initState() {
    super.initState();
    notesRef = FirebaseDatabase.instance.ref('users/${widget.userId}/notes');
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await notesRef.child(noteId).remove();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nota eliminada')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar la nota')));
    }
  }

  void editNote(String noteId, String title, String description, double price) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(
          userId: widget.userId,
          noteId: noteId,
          initialTitle: title,
          initialDescription: description,
          initialPrice: price,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Notas"),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: MyDrawer(userId: widget.userId),
      body: StreamBuilder(
        stream: notesRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar las notas'));
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(
              child: Text(
                'No tienes notas guardadas.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          Map<dynamic, dynamic> notes = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          return ListView(
            padding: EdgeInsets.all(10),
            children: notes.entries.map((entry) {
              final key = entry.key;
              final value = entry.value;

              return Card(
                margin: EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: ListTile(
                  contentPadding: EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple[200],
                    child: Icon(Icons.note, color: Colors.white),
                  ),
                  title: Text(
                    value['title'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    "${value['description']}\n\$${value['price']}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => editNote(key, value['title'], value['description'], value['price']),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => deleteNote(key),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción para agregar una nueva nota
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class EditNoteScreen extends StatelessWidget {
  final String userId;
  final String noteId;
  final String initialTitle;
  final String initialDescription;
  final double initialPrice;

  EditNoteScreen({
    required this.userId,
    required this.noteId,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialPrice,
  });

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: initialTitle);
    final descriptionController = TextEditingController(text: initialDescription);
    final priceController = TextEditingController(text: initialPrice.toString());

    Future<void> updateNote() async {
      final title = titleController.text;
      final description = descriptionController.text;
      final price = double.tryParse(priceController.text) ?? 0.0;

      if (title.isEmpty || description.isEmpty || price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor, completa todos los campos')));
        return;
      }

      try {
        DatabaseReference noteRef = FirebaseDatabase.instance.ref('users/$userId/notes/$noteId');
        await noteRef.update({
          'title': title,
          'description': description,
          'price': price,
        });

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar la nota: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Nota"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Precio'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // primary: Colors.deepPurple,
              ),
              onPressed: updateNote,
              child: Text("Actualizar Nota"),
            ),
          ],
        ),
      ),
    );
  }
}
