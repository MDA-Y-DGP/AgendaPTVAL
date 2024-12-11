import 'package:flutter/material.dart';
import 'package:agenda_ptval/vista/crear_tarea.dart';
import 'package:agenda_ptval/vista/asignar_tarea.dart';
import 'package:agenda_ptval/vista/evaluar_tarea.dart'; // Importa la nueva página de Evaluar Tarea
import 'package:agenda_ptval/controlador/tarea_controller.dart';
import 'package:agenda_ptval/modelo/tarea_modelo.dart';
import 'package:agenda_ptval/vista/modificar_tarea.dart'; // Import the modify task page

class TareasPage extends StatefulWidget {
  @override
  _TareasPageState createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TareaController _controller = TareaController();
  List<Tarea> tareas = [];

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  Future<void> _cargarTareas() async {
    try {
      List<Tarea> lista = await _controller.obtenerTodasLasTareas();
      setState(() {
        tareas = lista;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las tareas: $e')),
      );
    }
  }

  void _borrarTarea(Tarea tarea) async {
    bool? confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: Text('¿Estás seguro de que deseas borrar la tarea "${tarea.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _controller.borrarTarea(tarea.idTarea);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarea borrada con éxito!')),
        );
        _cargarTareas();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al borrar la tarea: $e')),
        );
      }
    }
  }

  void _navegarAgregarTarea() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearTarea(),
      ),
    ).then((_) => _cargarTareas());
  }

  void _navegarAsignarTarea() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AsignarTarea(),
      ),
    ).then((_) => _cargarTareas());
  }

  void _navegarEvaluarTarea() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EvaluarTarea(),
      ),
    ).then((_) => _cargarTareas());
  }

  void _navegarModificarTarea(Tarea tarea) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModificarTarea(tarea: tarea),
      ),
    ).then((_) => _cargarTareas());
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Tarea>> tareasPorTipo = {};
    for (var tarea in tareas) {
      if (!tareasPorTipo.containsKey(tarea.tipo)) {
        tareasPorTipo[tarea.tipo] = [];
      }
      tareasPorTipo[tarea.tipo]!.add(tarea);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Tareas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _navegarAgregarTarea,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Color del texto
                    ),
                  ),
                  child: const Text('Crear Tarea', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _navegarAsignarTarea,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Color del texto
                    ),
                  ),
                  child: const Text('Asignar Tarea', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _navegarEvaluarTarea,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Color del texto
                    ),
                  ),
                  child: const Text('Evaluar Tarea', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: tareasPorTipo.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...entry.value.map((tarea) {
                        return Card(
                          color: Theme.of(context).colorScheme.surface, // Fondo de la tarjeta
                          child: ListTile(
                            title: Text(
                              tarea.titulo,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface, // Color del texto
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _navegarModificarTarea(tarea),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _borrarTarea(tarea),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}