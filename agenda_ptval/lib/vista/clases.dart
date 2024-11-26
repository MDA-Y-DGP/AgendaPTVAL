import 'package:flutter/material.dart';
import 'package:agenda_ptval/vista/agregar_clase.dart';
import 'package:agenda_ptval/controlador/clase_controller.dart';
import 'package:agenda_ptval/modelo/clase_modelo.dart';

class ClasesPage extends StatefulWidget {
  @override
  _ClasesPageState createState() => _ClasesPageState();
}

class _ClasesPageState extends State<ClasesPage> {
  final ClaseController _controller = ClaseController();
  List<Clase> clases = [];

  @override
  void initState() {
    super.initState();
    _cargarClases();
  }

  Future<void> _cargarClases() async {
    try {
      List<Clase> lista = await _controller.obtenerClases();
      setState(() {
        clases = lista;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las clases: $e')),
      );
    }
  }

  void _editarClase(Clase clase) async {
    TextEditingController _nombreController =
        TextEditingController(text: clase.nombre);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Nombre de la Clase'),
        content: TextField(
          controller: _nombreController,
          decoration: const InputDecoration(labelText: 'Nuevo nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _controller.actualizarClase(clase.idClase, _nombreController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clase actualizada con éxito!')),
                );
                Navigator.pop(context);
                _cargarClases();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al actualizar la clase: $e')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _borrarClase(Clase clase) async {
    bool? confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: Text('¿Estás seguro de que deseas borrar la clase "${clase.nombre}"?'),
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
        await _controller.borrarClase(clase.idClase);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clase borrada con éxito!')),
        );
        _cargarClases();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al borrar la clase: $e')),
        );
      }
    }
  }

  void _navegarAgregarClase() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarClase(),
      ),
    ).then((_) => _cargarClases());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Clases'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _navegarAgregarClase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Color del texto
                ),
              ),
              child: const Text('Agregar Clase', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: clases.length,
                itemBuilder: (context, index) {
                  final clase = clases[index];
                  return Card(
                    color: Theme.of(context).colorScheme.surface, // Fondo de la tarjeta
                    child: ListTile(
                      title: Text(
                        clase.nombre,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface, // Color del texto
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editarClase(clase),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _borrarClase(clase),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}