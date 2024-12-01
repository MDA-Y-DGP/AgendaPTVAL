import 'package:flutter/material.dart';
import 'package:agenda_ptval/controlador/profesor_controller.dart';
import 'package:agenda_ptval/modelo/profesor_modelo.dart';
import 'registro_profesor.dart';

class ListaProfesores extends StatefulWidget {
  @override
  _ListaProfesoresState createState() => _ListaProfesoresState();
}

class _ListaProfesoresState extends State<ListaProfesores> {
  final ProfesorController _controller = ProfesorController();
  List<Profesor> profesores = [];

  @override
  void initState() {
    super.initState();
    _cargarProfesores();
  }

  Future<void> _cargarProfesores() async {
    List<Profesor> profesoresObtenidos = await _controller.obtenerTodosLosProfesores();
    setState(() {
      profesores = profesoresObtenidos;
    });
  }

  Future<void> _eliminarProfesor(String id) async {
    try {
      await _controller.eliminarProfesor(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profesor eliminado con éxito!')),
      );
      _cargarProfesores(); // Recargar la lista de profesores
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar profesor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Profesores'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView.builder(
        itemCount: profesores.length,
        itemBuilder: (context, index) {
          final profesor = profesores[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(profesor.nickname[0].toUpperCase()),
              ),
              title: Text(profesor.nickname),
              subtitle: Text('Administrador: ${profesor.administrador ? "Sí" : "No"}'),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _eliminarProfesor(profesor.idProfesor.toString()),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegistroProfesor()),
          ).then((_) => _cargarProfesores());
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}