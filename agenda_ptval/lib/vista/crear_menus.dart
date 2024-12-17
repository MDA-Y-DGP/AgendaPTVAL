import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:agenda_ptval/controlador/menu_controller.dart';
import 'package:agenda_ptval/controlador/imagen_controller.dart';
import 'package:agenda_ptval/modelo/menu_modelo.dart';

class CrearMenu extends StatefulWidget {
  @override
  _CrearMenuState createState() => _CrearMenuState();
}

class _CrearMenuState extends State<CrearMenu> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final MenuController _menuController = MenuController();
  final ImagenController _imagenController = ImagenController();
  File? imagen;
  Uint8List? imagenBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            imagenBytes = bytes;
          });
        } else {
          setState(() {
            imagen = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar la imagen: $e')),
      );
    }
  }

  Future<void> _subirImagen(String nombreMenu) async {
    if (imagen != null || imagenBytes != null) {
      try {
        if (kIsWeb && imagenBytes != null) {
          await _imagenController.subirImagenWeb(imagenBytes!, 'img_menu', nombreMenu);
        } else if (imagen != null) {
          await _imagenController.subirImagen(imagen!, 'img_menu', nombreMenu);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: $e')),
        );
        return;
      }
    }
  }

  Future<void> _crearMenu() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Menu nuevoMenu = Menu(
        idMenu: 0, // Este valor se actualizará en el controlador
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
      );

      try {
        await _subirImagen(nuevoMenu.nombre);
        await _menuController.crearMenu(nuevoMenu);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menú creado correctamente')),
        );
        Navigator.pop(context); // Volver a la página anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el menú: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Menú'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (imagen != null)
                Image.file(imagen!, height: 200)
              else if (imagenBytes != null)
                Image.memory(imagenBytes!, height: 200),
              ListTile(
                title: Text(imagen == null && imagenBytes == null ? 'Selecciona una imagen (opcional)' : 'Imagen seleccionada'),
                trailing: const Icon(Icons.image),
                onTap: _pickImage,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _crearMenu,
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
                child: const Text('Crear Menú', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}