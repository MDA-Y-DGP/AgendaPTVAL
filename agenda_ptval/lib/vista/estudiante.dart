import 'package:flutter/material.dart';
import 'package:agenda_ptval/controlador/estudiante_controller.dart';
import 'package:agenda_ptval/controlador/imagen_controller.dart';
import 'package:agenda_ptval/modelo/estudiante_modelo.dart';
import 'modificar_estudiante.dart'; // Importa la vista de modificar estudiante
import 'registro_estudiante.dart'; // Importa la vista de registro de estudiante

class ListaEstudiantes extends StatefulWidget {
  @override
  _ListaEstudiantesState createState() => _ListaEstudiantesState();
}

class _ListaEstudiantesState extends State<ListaEstudiantes> {
  final EstudianteController _controller = EstudianteController();
  final ImagenController _imagenController = ImagenController();
  List<Estudiante> estudiantes = [];

  @override
  void initState() {
    super.initState();
    _cargarEstudiantes();
  }

  Future<void> _cargarEstudiantes() async {
    List<Estudiante> estudiantesObtenidos = await _controller.obtenerTodosEstudiantes();
    estudiantesObtenidos.sort((a, b) => a.nickname.compareTo(b.nickname)); // Ordenar alfabéticamente
    setState(() {
      estudiantes = estudiantesObtenidos;
    });
  }

  Future<void> _eliminarEstudiante(String id) async {
    try {
      await _controller.eliminarEstudiante(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estudiante eliminado con éxito!')),
      );
      _cargarEstudiantes(); // Recargar la lista de estudiantes
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar estudiante: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Estudiantes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView.builder(
        itemCount: estudiantes.length,
        itemBuilder: (context, index) {
          final estudiante = estudiantes[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: FutureBuilder<String>(
                future: _imagenController.obtenerFotoPerfil(estudiante.nickname),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      radius: 20,
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/default_profile.png'),
                    );
                  } else {
                    return CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(snapshot.data!),
                    );
                  }
                },
              ),
              title: Text(estudiante.nickname),
              subtitle: Text('Grado: ${estudiante.gradoAprendizaje}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ModificarEstudiante(estudiante: estudiante),
                        ),
                      ).then((_) {
                        _cargarEstudiantes();
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _eliminarEstudiante(estudiante.idEstudiante.toString()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroEstudiante(),
            ),
          ).then((_) {
            _cargarEstudiantes();
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}