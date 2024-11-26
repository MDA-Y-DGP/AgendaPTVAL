import 'package:flutter/material.dart';
import '../controlador/inventario_controller.dart';
import '../modelo/inventario_modelo.dart';

class RealizarTareaInventario extends StatefulWidget {
  @override
  _RealizarTareaInventarioState createState() => _RealizarTareaInventarioState();
}

class _RealizarTareaInventarioState extends State<RealizarTareaInventario> {
  final InventarioController _controller = InventarioController();
  List<Inventario> _inventarioList = [];

  @override
  void initState() {
    super.initState();
    _cargarInventario();
  }

  Future<void> _cargarInventario() async {
    List<Inventario> inventario = await _controller.obtenerInventario();
    setState(() {
      _inventarioList = inventario;
    });
  }

  void _incrementarCantidad(int index) {
    setState(() {
      _inventarioList[index].cantidad++;
    });
  }

  void _decrementarCantidad(int index) {
    setState(() {
      if (_inventarioList[index].cantidad > 0) {
        _inventarioList[index].cantidad--;
      }
    });
  }

  Future<void> _guardarCambios() async {
    try {
      for (var item in _inventarioList) {
        await _controller.actualizarInventario(item);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inventario actualizado con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el inventario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Realizar Tarea de Inventario'),
      ),
      body: _inventarioList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _inventarioList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(_inventarioList[index].nombre),
                    subtitle: Text('Cantidad: ${_inventarioList[index].cantidad}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => _decrementarCantidad(index),
                        ),
                        Text(_inventarioList[index].cantidad.toString()),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _incrementarCantidad(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _guardarCambios,
        label: Text('Guardar Cambios'),
        icon: Icon(Icons.save),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}