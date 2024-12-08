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
  List<File?> _mediaFiles = [];
  List<Uint8List?> _mediaBytesList = [];
  List<String?> _mediaFileNames = [];
  File? _mediaFile;
  Uint8List? _mediaBytes;
  String? _mediaFileName;
  File? _perfilFile;
  Uint8List? _perfilBytes;
  String? _perfilFileName;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Tarea'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                    _tituloController, 'Título', 'Por favor ingresa un título'),
                const SizedBox(height: 16),
                _buildTextField(_descripcionController, 'Descripción',
                    'Por favor ingresa una descripción'),
                const SizedBox(height: 16),
                _buildDropdownButtonFormField(),
                const SizedBox(height: 16),
                if (_tipo == 'por pasos') ...[
                  _buildPerfilField(),
                  const SizedBox(height: 16),
                  _buildPasosList(),
                  _buildAddPasoField(),
                  const SizedBox(height: 10),
                  _buildAddPasoButton(),
                ],
                const SizedBox(height: 16),
                _buildCrearTareaButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerfilField() {
    return Column(
      children: [
        const SizedBox(height: 16), // Añadir separación
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Imagen de Perfil',
          ),
          child: Container(
            height: 40, // Ajusta la altura según sea necesario
            child: ListTile(
              title: Text(_perfilFile == null && _perfilBytes == null
                  ? 'Selecciona una imagen de perfil'
                  : 'Imagen seleccionada: $_perfilFileName'),
              trailing: const Icon(Icons.image),
              onTap: _pickPerfil,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPasoField() {
    return Column(
      children: [
        const SizedBox(height: 16), // Añadir separación
        TextField(
          controller: _nuevoPasoController,
          decoration: const InputDecoration(
            labelText: 'Texto del paso',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          child: Container(
            height: 100, // Ajusta la altura según sea necesario
            child: Column(
              children: [
                ListTile(
                  title: Text(_mediaFiles.isEmpty && _mediaBytesList.isEmpty
                      ? 'Selecciona imágenes/videos'
                      : 'Media seleccionada: ${_mediaFileNames.join(", ")}'),
                  trailing: const Icon(Icons.image),
                  onTap: _pickMedia,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _mediaFiles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: kIsWeb
                            ? Image.memory(_mediaBytesList[index]!, width: 50, height: 50)
                            : Image.file(_mediaFiles[index]!, width: 50, height: 50),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      String validationMessage) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  Widget _buildDropdownButtonFormField() {
    return DropdownButtonFormField<String>(
      value: _tipo,
      decoration: const InputDecoration(
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
    );
  }

  Widget _buildPasosList() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Lista de pasos',
        border: OutlineInputBorder(),
      ),
      child: Container(
        height: 150, // Ajusta la altura según sea necesario
        child: ListView.builder(
          itemCount: _pasos.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${index + 1}. ${_pasos[index]['texto']}'),
              subtitle: _pasos[index]['mediaFiles'].isNotEmpty || _pasos[index]['mediaBytesList'].isNotEmpty
                  ? SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _pasos[index]['mediaFiles'].length,
                        itemBuilder: (context, mediaIndex) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: kIsWeb
                                ? Image.memory(_pasos[index]['mediaBytesList'][mediaIndex]!, width: 50, height: 50)
                                : Image.file(_pasos[index]['mediaFiles'][mediaIndex]!, width: 50, height: 50),
                          );
                        },
                      ),
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddPasoButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_nuevoPasoController.text.isNotEmpty) {
          List<String?> urlMediaList = [];
          for (int i = 0; i < _mediaFiles.length; i++) {
            String? urlMedia = _mediaFiles[i] != null || _mediaBytesList[i] != null
                ? await _subirImagenPaso(_mediaFiles[i], _mediaBytesList[i], _pasos.length + 1, i)
                : null;
            urlMediaList.add(urlMedia);
          }

          setState(() {
            _pasos.add({
              'texto': _nuevoPasoController.text,
              'mediaFiles': _mediaFiles,
              'mediaBytesList': _mediaBytesList,
              'urlMediaList': urlMediaList,
            });
            _nuevoPasoController.clear();
            _mediaFiles = [];
            _mediaBytesList = [];
            _mediaFileNames = [];
          });
        }
      },
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
      child: const Text('Agregar Paso', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildCrearTareaButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          if (_tipo == 'por pasos') {
            if (_perfilFile != null || _perfilBytes != null) {
              //String? urlPerfil = await _subirImagenPaso(_perfilFile, _perfilBytes, 0);
              // Guardar la URL de la imagen de perfil en la tarea
            }

            for (var i = 0; i < _pasos.length; i++) {
              var paso = _pasos[i];
              if (paso['urlMedia'] == null &&
                  (paso['mediaFile'] != null || paso['mediaBytes'] != null)) {
                String? urlMedia = await _subirImagenPaso(
                    paso['mediaFile'], paso['mediaBytes'], i + 1, i); // Added missing argument
                paso['urlMedia'] = urlMedia;
              }
            }
          }

          Tarea nuevaTarea = Tarea(
            idTarea: 0, // El ID se asignará en el controlador
            titulo: _tituloController.text,
            descripcion: _descripcionController.text,
            tipo: _tipo,
            pasos: _pasos.map((paso) => paso['texto'] as String).toList(),
          );

          await _tareaController.crearTarea(nuevaTarea);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarea creada correctamente')),
          );
          Navigator.pop(context);
        }
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
      child: const Text('Crear Tarea', style: TextStyle(color: Colors.white)),
    );
  }

  Future<void> _pickMedia() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null) {
        if (kIsWeb) {
          final bytesList = await Future.wait(pickedFiles.map((file) => file.readAsBytes()));
          setState(() {
            _mediaBytesList = bytesList;
            _mediaFileNames = pickedFiles.map((file) => file.name).toList();
          });
        } else {
          setState(() {
            _mediaFiles = pickedFiles.map((file) => File(file.path)).toList();
            _mediaFileNames = pickedFiles.map((file) => file.path.split('/').last).toList();
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar la media: $e')),
      );
    }
  }

  Future<void> _pickPerfil() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _perfilBytes = bytes;
            _perfilFileName = pickedFile.name;
          });
        } else {
          setState(() {
            _perfilFile = File(pickedFile.path);
            _perfilFileName = pickedFile.path.split('/').last;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar la imagen de perfil: $e')),
      );
    }
  }

  Future<String?> _subirImagenPaso(
      File? mediaFile, Uint8List? mediaBytes, int pasoIndex, int mediaIndex) async {
    if (mediaFile != null || mediaBytes != null) {
      try {
        String nombreArchivo = _mediaFileNames[mediaIndex] ?? '';
        if (RegExp(r'^\d+$').hasMatch(nombreArchivo)) {
          return null;
        }

        String nombreFinal = '$pasoIndex-$mediaIndex $nombreArchivo';
        String ruta = 'tareas/${_tituloController.text}';

        if (kIsWeb && mediaBytes != null) {
          return await _imagenController.subirImagenWebPaso(
              mediaBytes, ruta, nombreFinal);
        } else if (mediaFile != null) {
          return await _imagenController.subirImagenPaso(
              mediaFile, ruta, nombreFinal);
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