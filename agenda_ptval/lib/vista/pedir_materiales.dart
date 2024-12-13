import 'package:flutter/material.dart';
import '../controlador/inventario_controller.dart';
import '../controlador/clase_controller.dart';
import '../controlador/pedidos_materiales_controller.dart';
import '../modelo/inventario_modelo.dart';
import '../modelo/clase_modelo.dart';
import '../modelo/pedido_materiales_modelo.dart';

class PedirMateriales extends StatefulWidget {
  @override
  _PedirMaterialesState createState() => _PedirMaterialesState();
}

class _PedirMaterialesState extends State<PedirMateriales> {
  final InventarioController _inventarioController = InventarioController();
  final ClaseController _claseController = ClaseController();
  final PedidosMaterialesController _pedidosMaterialesController =
      PedidosMaterialesController();
  List<Inventario> _inventarioList = [];
  Map<int, int> _pedidos = {};
  Map<int, TextEditingController> _controllers = {};
  String? _selectedClase;

  @override
  void initState() {
    super.initState();
    _cargarInventario();
  }

  Future<void> _cargarInventario() async {
    try {
      List<Inventario> lista = await _inventarioController.obtenerInventario();
      setState(() {
        _inventarioList = lista;
        _pedidos = {for (var item in lista) item.idObjeto: 0};
        _controllers = {
          for (var item in lista)
            item.idObjeto: TextEditingController(text: '0')
        };
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar inventario: $e')),
      );
    }
  }

  void _incrementarCantidad(int idObjeto, int cantidadDisponible) {
    setState(() {
      if (_pedidos[idObjeto]! < cantidadDisponible) {
        _pedidos[idObjeto] = _pedidos[idObjeto]! + 1;
        _controllers[idObjeto]!.text = _pedidos[idObjeto]!.toString();
      }
    });
  }

  void _decrementarCantidad(int idObjeto) {
    setState(() {
      if (_pedidos[idObjeto]! > 0) {
        _pedidos[idObjeto] = _pedidos[idObjeto]! - 1;
        _controllers[idObjeto]!.text = _pedidos[idObjeto]!.toString();
      }
    });
  }

  void _pedirMateriales() async {
    bool pedidoValido = true;
    List<Inventario> materialesPedidos = [];

    _pedidos.forEach((idObjeto, cantidadPedida) {
      final inventario =
          _inventarioList.firstWhere((item) => item.idObjeto == idObjeto);
      if (cantidadPedida > inventario.cantidad) {
        pedidoValido = false;
      } else if (cantidadPedida > 0) {
        materialesPedidos.add(Inventario(
          idObjeto: inventario.idObjeto,
          nombre: inventario.nombre,
          cantidad: cantidadPedida,
        ));
      }
    });

    if (pedidoValido && _selectedClase != null) {
      PedidoMateriales pedido = PedidoMateriales(
        idClase: _selectedClase!,
        fecha: DateTime.now(),
        materiales: materialesPedidos,
        visto: false,
      );

      try {
        await _pedidosMaterialesController.agregarPedido(pedido);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Materiales pedidos correctamente')),
        );
        Navigator.pop(context); // Volver a la página anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al pedir materiales: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'No se puede pedir más de la cantidad disponible o clase no seleccionada')),
      );
    }
  }

  Widget _buildClasesDropdown() {
    return FutureBuilder<List<Clase>>(
      future: _claseController.obtenerClases(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error al cargar clases'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay clases disponibles'));
        } else {
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Selecciona una clase',
              border: OutlineInputBorder(),
            ),
            value: _selectedClase,
            onChanged: (String? newValue) {
              setState(() {
                _selectedClase = newValue;
              });
            },
            items: snapshot.data!.map((Clase clase) {
              return DropdownMenuItem<String>(
                value: clase.idClase.toString(),
                child: Text(clase.nombre),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildInventarioList() {
    return ListView.builder(
      itemCount: _inventarioList.length,
      itemBuilder: (context, index) {
        final inventario = _inventarioList[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(inventario.nombre),
            subtitle: Text('Cantidad disponible: ${inventario.cantidad}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => _decrementarCantidad(inventario.idObjeto),
                ),
                SizedBox(
                  width: 40,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    controller: _controllers[inventario.idObjeto],
                    onChanged: (value) {
                      int cantidad = int.tryParse(value) ?? 0;
                      if (cantidad >= 0 && cantidad <= inventario.cantidad) {
                        setState(() {
                          _pedidos[inventario.idObjeto] = cantidad;
                        });
                      } else {
                        _controllers[inventario.idObjeto]!.text =
                            _pedidos[inventario.idObjeto]!.toString();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _incrementarCantidad(
                      inventario.idObjeto, inventario.cantidad),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedir Materiales'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildClasesDropdown(),
            const SizedBox(height: 20),
            Expanded(child: _buildInventarioList()),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pedirMateriales,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Color del texto
                ),
              ),
              child: Text('Pedir Materiales', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}