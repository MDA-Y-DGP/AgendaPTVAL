import 'package:flutter/material.dart';
import '../controlador/inventario_controller.dart';
import '../modelo/inventario_modelo.dart'; // Asegúrate de que la ruta sea correcta
import 'agregar_material.dart'; // Importa la nueva vista

class CrearListasInventario extends StatefulWidget {
  @override
  _CrearListasInventarioState createState() => _CrearListasInventarioState();
}

class _CrearListasInventarioState extends State<CrearListasInventario> {
  final InventarioController _inventarioController = InventarioController();
  List<Inventario> _materiales = [];

  @override
  void initState() {
    super.initState();
    _cargarInventario();
  }

  Future<void> _cargarInventario() async {
    List<Inventario> inventario =
        await _inventarioController.obtenerInventario();
    setState(() {
      _materiales = inventario;
    });
  }

  Future<void> _eliminarMaterial(int idObjeto, int index) async {
    try {
      await _inventarioController.eliminarInventario(idObjeto);
      setState(() {
        _materiales.removeAt(index);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el material: $e')),
      );
    }
  }

  Future<void> _mostrarPopupEditarMaterial(
      Inventario material, int index) async {
    final _nombreController = TextEditingController(text: material.nombre);
    final _cantidadController =
        TextEditingController(text: material.cantidad.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modificar Material'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextFormField(
                controller: _cantidadController,
                decoration: InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nombre = _nombreController.text;
                final cantidad = int.parse(_cantidadController.text);

                final materialModificado = Inventario(
                  idObjeto: material.idObjeto,
                  nombre: nombre,
                  cantidad: cantidad,
                );

                await _inventarioController
                    .actualizarInventario(materialModificado);
                setState(() {
                  _materiales[index] = materialModificado;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                textStyle: const TextStyle(
                  color: Colors.white,
                ),
              ),
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listas de Inventario'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _materiales.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Theme.of(context).colorScheme.surface, // Fondo de la tarjeta
                    child: ListTile(
                      title: Text(
                        _materiales[index].nombre,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface, // Color del texto
                        ),
                      ),
                      subtitle: Text('Cantidad: ${_materiales[index].cantidad}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _mostrarPopupEditarMaterial(_materiales[index], index);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _eliminarMaterial(_materiales[index].idObjeto, index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AgregarMaterial()),
                ).then((_) => _cargarInventario());
              },
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
              child: const Text('Agregar Material', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}