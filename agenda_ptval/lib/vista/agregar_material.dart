import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../controlador/inventario_controller.dart';
import '../controlador/imagen_controller.dart';
import '../modelo/inventario_modelo.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AgregarMaterial extends StatefulWidget {
  @override
  _AgregarMaterialState createState() => _AgregarMaterialState();
}

class _AgregarMaterialState extends State<AgregarMaterial> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();
  final InventarioController _inventarioController = InventarioController();
  final ImagenController _imagenController = ImagenController();
  final ImagePicker _picker = ImagePicker();
  File? _imagen;
  Uint8List? _imagenBytes;

  Future<void> _agregarMaterial() async {
    if (_formKey.currentState!.validate() &&
        (_imagen != null || _imagenBytes != null)) {
      final nombre = _nombreController.text;
      final cantidad = int.parse(_cantidadController.text);

      final nuevoMaterial = Inventario(
        idObjeto: DateTime.now().millisecondsSinceEpoch,
        nombre: nombre,
        cantidad: cantidad,
      );

      await _inventarioController.agregarInventario(nuevoMaterial);
      await _subirImagen(nombre);
      Navigator.pop(context);
    } else if (_imagen == null && _imagenBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona una imagen')),
      );
    }
  }

  Future<void> _subirImagen(String nombre) async {
    try {
      if (kIsWeb && _imagenBytes != null) {
        await _imagenController.subirImagenWebPaso(
            _imagenBytes!, 'materiales', '$nombre.jpg');
      } else if (_imagen != null) {
        await _imagenController.subirImagenPaso(
            _imagen!, 'materiales', '$nombre.jpg');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la imagen: $e')),
      );
    }
  }

  Future<void> _seleccionarImagen() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _imagenBytes = bytes;
          });
        } else {
          setState(() {
            _imagen = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar la imagen: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Material'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidadController,
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la cantidad';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _seleccionarImagen,
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
                child: const Text('Seleccionar Imagen', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              if (_imagen != null)
                Image.file(_imagen!, height: 100)
              else if (_imagenBytes != null)
                Image.memory(_imagenBytes!, height: 100),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _agregarMaterial,
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
                child: const Text('Agregar Material', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}