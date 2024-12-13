import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../controlador/imagen_controller.dart';
import '../controlador/clase_controller.dart';
import '../modelo/clase_modelo.dart';

class AgregarClase extends StatefulWidget {
  @override
  _AgregarClaseState createState() => _AgregarClaseState();
}

class _AgregarClaseState extends State<AgregarClase> {
  final _formKey = GlobalKey<FormState>();
  final ClaseController _controller = ClaseController();
  final ImagenController _imagenController = ImagenController();
  final ImagePicker _picker = ImagePicker();

  String nombreClase = '';
  File? imagen;
  Uint8List? imagenBytes;

  Future<void> _subirImagen() async {
    if (imagen != null || imagenBytes != null) {
      try {
        if (kIsWeb && imagenBytes != null) {
          await _imagenController.subirImagenWeb(imagenBytes!, 'img_clase', nombreClase);
        } else if (imagen != null) {
          await _imagenController.subirImagen(imagen!, 'img_clase', nombreClase);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: $e')),
        );
        return;
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      if (kIsWeb) {
        imagenBytes = await pickedImage.readAsBytes();
      } else {
        imagen = File(pickedImage.path);
      }
      setState(() {});
    }
  }

  Future<void> _agregarClase() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _subirImagen();
      Clase nuevaClase = Clase(
        idClase: 0, // Este valor se actualizará en el controlador
        nombre: nombreClase,
      );

      _controller.agregarClase(nuevaClase).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clase agregada con éxito!')),
        );
        Navigator.pop(context); // Regresar a la vista anterior
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar la clase: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Clase'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nombre de la Clase',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Ingrese el nombre de la clase',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre de la clase';
                  }
                  return null;
                },
                onSaved: (value) {
                  nombreClase = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Seleccionar Imagen'),
              ),
              const SizedBox(height: 20),
              if (imagen != null && !kIsWeb)
                Image.file(imagen!, height: 150),
              if (imagenBytes != null && kIsWeb)
                Image.memory(imagenBytes!, height: 150),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _agregarClase,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Agregar Clase'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}