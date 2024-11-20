import 'package:flutter/material.dart';
import 'package:agenda_ptval/controlador/tarea_controller.dart';
import 'package:agenda_ptval/controlador/imagen_controller.dart';
import 'package:agenda_ptval/modelo/tarea_modelo.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class CrearTarea extends StatefulWidget {
  @override
  _CrearTareaState createState() => _CrearTareaState();
}

class _CrearTareaState extends State<CrearTarea> {
  final _formKey = GlobalKey<FormState>();
  final TareaController _tareaController = TareaController();
  final ImagenController _imagenController = ImagenController();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _nuevoPasoController = TextEditingController();
  String _tipo = 'comedor'; // Valor predeterminado

  List<Map<String, dynamic>> _pasos = [];
  File? _mediaFile;
  Uint8List? _mediaBytes;
  String? _mediaFileName;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
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
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: InputDecoration(
                  labelText: 'Tipo de Tarea',
                  border: OutlineInputBorder(),
                ),
                items: ['comedor', 'por pasos', 'inventario'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tipo = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_tipo == 'por pasos') ...[
                _buildPasosList(),
                _buildAddPasoField(),
                const SizedBox(height: 10),
                _buildAddPasoButton(),
              ],
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Tarea nuevaTarea = Tarea(
                      idTarea: 0, // Este valor se actualizará en el controlador
                      titulo: _tituloController.text,
                      descripcion: _descripcionController.text,
                      tipo: _tipo,
                      pasos: _pasos.map((paso) => paso['texto'] as String).toList(),
                    );
                    int idTareaPorPasos = await _tareaController.crearTarea(nuevaTarea);

                    if (_tipo == 'por pasos') {
                      for (var i = 0; i < _pasos.length; i++) {
                        var paso = _pasos[i];
                        if (paso['mediaFile'] != null || paso['mediaBytes'] != null) {
                          String? urlMedia = await _subirImagenPaso(
                              paso['mediaFile'], paso['mediaBytes'], i);
                          paso['urlMedia'] = urlMedia;
                        }
                      }
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tarea creada correctamente')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Crear Tarea'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasosList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _pasos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_pasos[index]['texto']),
            subtitle: _pasos[index]['urlMedia'] != null
                ? Text('Media: ${_pasos[index]['urlMedia']}')
                : null,
          );
        },
      ),
    );
  }

  Widget _buildAddPasoField() {
    return Column(
      children: [
        TextField(
          controller: _nuevoPasoController,
          decoration: InputDecoration(
            labelText: 'Texto del Paso',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          title: Text(_mediaFile == null && _mediaBytes == null
              ? 'Selecciona una imagen/video (opcional)'
              : 'Media seleccionada: $_mediaFileName'),
          trailing: const Icon(Icons.image),
          onTap: _pickMedia,
        ),
      ],
    );
  }

  Widget _buildAddPasoButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_nuevoPasoController.text.isNotEmpty) {
          String? urlMedia;
          if (_mediaFile != null || _mediaBytes != null) {
            urlMedia = await _subirImagenPaso(_mediaFile, _mediaBytes, _pasos.length);
          }
          setState(() {
            _pasos.add({
              'texto': _nuevoPasoController.text,
              'mediaFile': _mediaFile,
              'mediaBytes': _mediaBytes,
              'urlMedia': urlMedia,
            });
            _nuevoPasoController.clear();
            _mediaFile = null;
            _mediaBytes = null;
            _mediaFileName = null;
          });
        }
      },
      child: const Text('Agregar Paso'),
    );
  }

  Future<void> _pickMedia() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _mediaBytes = bytes;
            _mediaFileName = pickedFile.name;
          });
        } else {
          setState(() {
            _mediaFile = File(pickedFile.path);
            _mediaFileName = pickedFile.path.split('/').last;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar la media: $e')),
      );
    }
  }

  Future<String?> _subirImagenPaso(File? mediaFile, Uint8List? mediaBytes, int pasoIndex) async {
    if (mediaFile != null || mediaBytes != null) {
      try {
        String nombreArchivo = _mediaFileName ?? '';

        // Verificar que el nombre del archivo no sea solo un número
        if (RegExp(r'^\d+$').hasMatch(nombreArchivo)) {
          return null;
        }

        // Construir el nombre final con el índice del paso y el nombre del archivo
        String nombreFinal = '$pasoIndex $nombreArchivo';

        // Ruta donde se almacenará la imagen
        String ruta = 'tareas/${_tituloController.text}';

        // Subir la imagen dependiendo de la fuente (web o dispositivo local)
        if (kIsWeb && mediaBytes != null) {
          return await _imagenController.subirImagenWebPaso(mediaBytes, ruta, nombreFinal);
        } else if (mediaFile != null) {
          return await _imagenController.subirImagenPaso(mediaFile, ruta, nombreFinal);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: $e')),
        );
      }
    }
    return null;
  }
}