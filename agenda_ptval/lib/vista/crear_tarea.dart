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
  List<File?> _imageFiles = [];
  List<Uint8List?> _imageBytesList = [];
  List<String?> _imageFileNames = [];
  List<File?> _videoFiles = [];
  List<Uint8List?> _videoBytesList = [];
  List<String?> _videoFileNames = [];
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
          child: Column(
            children: [
              ListTile(
                title: _imageFiles.isEmpty && _imageBytesList.isEmpty
                    ? const Text('Selecciona imágen')
                    : Row(
                        children: List.generate(_imageFiles.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: kIsWeb
                                ? Image.memory(_imageBytesList[index]!, width: 50, height: 50)
                                : Image.file(_imageFiles[index]!, width: 50, height: 50),
                          );
                        }),
                      ),
                trailing: const Icon(Icons.image),
                onTap: _pickImage,
              ),
              const SizedBox(height: 10),
              ListTile(
                title: _videoFiles.isEmpty && _videoBytesList.isEmpty
                    ? const Text('Selecciona video')
                    : Row(
                        children: List.generate(_videoFiles.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: kIsWeb
                                ? Icon(Icons.video_library, size: 50)
                                : Icon(Icons.video_library, size: 50),
                          );
                        }),
                      ),
                trailing: const Icon(Icons.video_library),
                onTap: _pickVideo,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null) {
        if (kIsWeb) {
          final bytesList = await Future.wait(pickedFiles.map((file) => file.readAsBytes()));
          setState(() {
            _imageBytesList = bytesList;
            _imageFileNames = pickedFiles.map((file) => file.name).toList();
          });
        } else {
          setState(() {
            _imageFiles = pickedFiles.map((file) => File(file.path)).toList();
            _imageFileNames = pickedFiles.map((file) => file.path.split('/').last).toList();
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar la imagen: $e')),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _videoBytesList.add(bytes);
            _videoFileNames.add(pickedFile.name);
          });
        } else {
          setState(() {
            _videoFiles.add(File(pickedFile.path));
            _videoFileNames.add(pickedFile.path.split('/').last);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar el video: $e')),
      );
    }
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
              subtitle: _pasos[index]['imageFiles'].isNotEmpty || _pasos[index]['imageBytesList'].isNotEmpty
                  ? SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _pasos[index]['imageFiles'].length,
                        itemBuilder: (context, mediaIndex) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: kIsWeb
                                ? Image.memory(_pasos[index]['imageBytesList'][mediaIndex]!, width: 50, height: 50)
                                : Image.file(_pasos[index]['imageFiles'][mediaIndex]!, width: 50, height: 50),
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
          List<String?> urlImageList = [];
          List<String?> urlVideoList = [];
          for (int i = 0; i < _imageFiles.length; i++) {
            String? urlImage = _imageFiles[i] != null || _imageBytesList[i] != null
                ? await _subirImagenPaso(_imageFiles[i], _imageBytesList[i], _pasos.length + 1, i)
                : null;
            urlImageList.add(urlImage);
          }
          for (int i = 0; i < _videoFiles.length; i++) {
            String? urlVideo = _videoFiles[i] != null || _videoBytesList[i] != null
                ? await _subirVideoPaso(_videoFiles[i], _videoBytesList[i], _pasos.length + 1, i)
                : null;
            urlVideoList.add(urlVideo);
          }

          setState(() {
            _pasos.add({
              'texto': _nuevoPasoController.text,
              'imageFiles': _imageFiles,
              'imageBytesList': _imageBytesList,
              'urlImageList': urlImageList,
              'videoFiles': _videoFiles,
              'videoBytesList': _videoBytesList,
              'urlVideoList': urlVideoList,
            });
            _nuevoPasoController.clear();
            _imageFiles = [];
            _imageBytesList = [];
            _imageFileNames = [];
            _videoFiles = [];
            _videoBytesList = [];
            _videoFileNames = [];
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
      File? imageFile, Uint8List? imageBytes, int pasoIndex, int mediaIndex) async {
    if (imageFile != null || imageBytes != null) {
      try {
        String nombreArchivo = _imageFileNames[mediaIndex] ?? '';
        if (RegExp(r'^\d+$').hasMatch(nombreArchivo)) {
          return null;
        }

        String nombreFinal = '$pasoIndex-$mediaIndex $nombreArchivo';
        String ruta = 'tareas/${_tituloController.text}';

        if (kIsWeb && imageBytes != null) {
          return await _imagenController.subirImagenWeb(
              imageBytes, ruta, nombreFinal);
        } else if (imageFile != null) {
          return await _imagenController.subirImagen(
              imageFile, ruta, nombreFinal);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: $e')),
        );
      }
    }
    return null;
  }

  Future<String?> _subirVideoPaso(
      File? videoFile, Uint8List? videoBytes, int pasoIndex, int mediaIndex) async {
    if (videoFile != null || videoBytes != null) {
      try {
        String nombreArchivo = _videoFileNames[mediaIndex] ?? '';
        if (RegExp(r'^\d+$').hasMatch(nombreArchivo)) {
          return null;
        }

        String nombreFinal = '$pasoIndex-$mediaIndex $nombreArchivo';
        String ruta = 'tareas/${_tituloController.text}';

        if (kIsWeb && videoBytes != null) {
          return await _imagenController.subirVideoWeb(
              videoBytes, ruta, nombreFinal);
        } else if (videoFile != null) {
          return await _imagenController.subirVideo(
              videoFile, ruta, nombreFinal);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir el video: $e')),
        );
      }
    }
    return null;
  }
}