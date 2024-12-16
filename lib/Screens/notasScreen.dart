
import 'package:app_taller/Navegacion/drawer.dart';
import 'package:app_taller/Screens/notasDetalles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotesListScreen extends StatelessWidget {
  final String userId;

  NotesListScreen({required this.userId});

  Future<List<Map<String, dynamic>>> fetchNotes() async {
    DatabaseReference notesRef = FirebaseDatabase.instance.ref('users/$userId/notes');
    final snapshot = await notesRef.get();
    final data = snapshot.value;

    if (data != null) {
      Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> notesList = [];
      mapData.forEach((key, value) {
        notesList.add({
          'id': key,
          'title': value['title'],
          'description': value['description'],
          'price': value['price'],
        });
      });
      return notesList;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(userId: userId),
      appBar: AppBar(
        title: Text(
          "Notas de Estudio",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: FutureBuilder(
        future: fetchNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final notes = snapshot.data!;
            return notes.isNotEmpty
                ? ListView.builder(
                    itemCount: notes.length,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[200],
                            child: Icon(Icons.note, color: Colors.white),
                          ),
                          title: Text(
                            note['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueAccent,
                            ),
                          ),
                          subtitle: Text(
                            "${note['description']}\n\$${note['price']}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          isThreeLine: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotesScreen(userId: userId),
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[700]),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      "No hay notas disponibles",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
          } else {
            return Center(
              child: Text(
                "Error al cargar las notas",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          // Acción para añadir una nueva nota
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
