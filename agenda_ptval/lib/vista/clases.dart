import 'package:flutter/material.dart';
import 'package:agenda_ptval/vista/agregar_clase.dart';
import 'package:agenda_ptval/controlador/clase_controller.dart';
import 'package:agenda_ptval/controlador/imagen_controller.dart';
import 'package:agenda_ptval/modelo/clase_modelo.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Importar foundation.dart para kIsWeb

class ClasesPage extends StatefulWidget {
  @override
  _ClasesPageState createState() => _ClasesPageState();
}

class _ClasesPageState extends State<ClasesPage> {
  final ClaseController _controller = ClaseController();
  final ImagenController _imagenController = ImagenController();
  final ImagePicker _picker = ImagePicker();
  List<Clase> clases = [];
  File? nuevaImagen;
  Uint8List? nuevaImagenBytes;

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

  Future<String?> _obtenerImagenClase(String nombreClase) async {
    try {
      return await _imagenController.obtenerImagenClase(nombreClase);
    } catch (e) {
      print('Error al obtener la imagen de la clase: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      if (kIsWeb) {
        nuevaImagenBytes = await pickedImage.readAsBytes();
      } else {
        nuevaImagen = File(pickedImage.path);
      }
      setState(() {});
    }
  }

  void _editarClase(Clase clase) async {
    TextEditingController _nombreController =
        TextEditingController(text: clase.nombre);

    String? imagenActualUrl = await _obtenerImagenClase(clase.nombre);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Clase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nuevo nombre'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Seleccionar Nueva Imagen'),
            ),
            const SizedBox(height: 10),
            if (nuevaImagen != null && !kIsWeb)
              Image.file(nuevaImagen!, height: 150),
            if (nuevaImagenBytes != null && kIsWeb)
              Image.memory(nuevaImagenBytes!, height: 150),
            if (nuevaImagen == null && nuevaImagenBytes == null && imagenActualUrl != null)
              Image.network(imagenActualUrl, height: 150),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                String nuevoNombre = _nombreController.text;
                if (nuevoNombre.isNotEmpty) {
                  await _controller.actualizarClase(clase.idClase, nuevoNombre);
                  if (nuevaImagen != null || nuevaImagenBytes != null) {
                    try {
                      await _imagenController.borrarImagen('img_clase/${clase.nombre}.jpg');
                    } catch (e) {
                      print('No se pudo borrar la imagen anterior: $e');
                    }
                    if (kIsWeb && nuevaImagenBytes != null) {
                      await _imagenController.subirImagenWeb(nuevaImagenBytes!, 'img_clase', nuevoNombre);
                    } else if (nuevaImagen != null) {
                      await _imagenController.subirImagen(nuevaImagen!, 'img_clase', nuevoNombre);
                    }
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Clase actualizada con éxito!')),
                  );
                  Navigator.pop(context);
                  _cargarClases();
                }
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

  //
  void _borrarClase(Clase clase) async {
    try {
      await _controller.borrarClase(clase.idClase);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Clase borrada con éxito')),
      );
      _cargarClases();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al borrar la clase: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clases'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: clases.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: clases.length,
                itemBuilder: (context, index) {
                  final clase = clases[index];
                  return FutureBuilder<String?>(
                    future: _obtenerImagenClase(clase.nombre),
                    builder: (context, snapshot) {
                      return Card(
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (snapshot.connectionState == ConnectionState.waiting)
                                Center(child: CircularProgressIndicator())
                              else if (snapshot.hasError || !snapshot.hasData)
                                SizedBox(height: 150) // Espacio vacío si hay un error o no hay imagen
                              else
                                Image.network(snapshot.data!, height: 150, fit: BoxFit.cover),
                              SizedBox(height: 10),
                              Text(
                                clase.nombre,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface, // Color del texto
                                ),
                              ),
                            ],
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
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgregarClase()),
          ).then((_) => _cargarClases());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}