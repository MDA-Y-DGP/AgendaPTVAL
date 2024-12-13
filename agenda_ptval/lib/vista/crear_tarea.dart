import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controlador/tarea_controller.dart';
import '../modelo/tarea_modelo.dart';
import '../controlador/inventario_controller.dart';
import '../modelo/inventario_modelo.dart';
import 'package:agenda_ptval/controlador/imagen_controller.dart';
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
  final InventarioController _inventarioController = InventarioController();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _nuevoPasoController = TextEditingController();
  List<Inventario> materiales = [];
  Map<String, int> materialesSeleccionados = {};
  String _tipo = 'comedor'; // Valor predeterminado

  List<Map<String, dynamic>> _pasos = [];
  File? _mediaFile;
  Uint8List? _mediaBytes;
  String? _mediaFileName;
  File? _perfilFile;
  Uint8List? _perfilBytes;
  String? _perfilFileName;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarInventario();  // Llamada para cargar el inventario
  }

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
                if (_tipo == 'inventario') ...[
                  _buildMaterialesList(),
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
        const SizedBox(height: 16),
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Imagen de Perfil',
          ),
          child: Container(
            height: 40,
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
        const SizedBox(height: 16),
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
            height: 40,
            child: ListTile(
              title: Text(_mediaFile == null && _mediaBytes == null
                  ? 'Selecciona una imagen/video'
                  : 'Media seleccionada: $_mediaFileName'),
              trailing: const Icon(Icons.image),
              onTap: _pickMedia,
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
        height: 150,
        child: ListView.builder(
          itemCount: _pasos.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${index + 1}. ${_pasos[index]['texto']}'),
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
          String? urlMedia = _mediaFile != null || _mediaBytes != null
              ? await _subirImagenPaso(_mediaFile, _mediaBytes, _pasos.length + 1)
              : null;

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
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      child: const Text('Agregar Paso', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildCrearTareaButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          try {
            if (_tipo == 'por pasos') {
              if (_perfilFile != null || _perfilBytes != null) {
                String? urlPerfil = await _subirImagenPaso(_perfilFile, _perfilBytes, 0);
                // Guardar la URL de la imagen de perfil en la tarea
              }

              for (var i = 0; i < _pasos.length; i++) {
                var paso = _pasos[i];
                if (paso['urlMedia'] == null &&
                    (paso['mediaFile'] != null || paso['mediaBytes'] != null)) {
                  String? urlMedia = await _subirImagenPaso(
                      paso['mediaFile'], paso['mediaBytes'], i + 1);
                  paso['urlMedia'] = urlMedia;
                }
              }
            }

            if (_tipo == 'inventario') {
              Map<String, int> materialesParaTarea = {};
              materialesSeleccionados.forEach((key, value) {
                if (value > 0) {
                  materialesParaTarea[key] = value;
                }
              });
            }

            Tarea nuevaTarea = Tarea(
              idTarea: 0,
              titulo: _tituloController.text,
              descripcion: _descripcionController.text,
              tipo: _tipo,
              pasos: _pasos.map((paso) => paso['texto'] as String).toList(),
              materiales: materialesSeleccionados,
              fecha: DateTime.now().toString(),
            );

            // Llamar al método para crear la tarea
            await _tareaController.crearTarea(nuevaTarea);

            // Mostrar mensaje de éxito
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tarea creada con éxito')),
            );

            // Regresar a la pantalla anterior
            Navigator.pop(context);
          } catch (e) {
            // Mostrar mensaje de error si ocurre algún problema
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al crear la tarea: $e')),
            );
          }
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
          color: Colors.white,
        ),
      ),
      child: const Text('Crear Tarea', style: TextStyle(color: Colors.white)),
    );
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

  Future<String?> _subirImagenPaso(
      File? mediaFile, Uint8List? mediaBytes, int pasoIndex) async {
    if (mediaFile != null || mediaBytes != null) {
      try {
        String nombreArchivo = pasoIndex == 0 ? _perfilFileName ?? '' : _mediaFileName ?? '';
        if (RegExp(r'^\d+$').hasMatch(nombreArchivo)) {
          return null;
        }

        String nombreFinal = '$pasoIndex $nombreArchivo';
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

  Future<void> _cargarInventario() async {
    var inventario = await _inventarioController.obtenerInventario();
    setState(() {
      materiales = inventario;
    });
  }

  Widget _buildMaterialesList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: materiales.length,
      itemBuilder: (context, index) {
        var material = materiales[index];
        int cantidadSeleccionada = materialesSeleccionados[material.nombre] ?? 0;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              material.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Cantidad disponible: ${material.cantidad}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: cantidadSeleccionada > 0
                      ? () {
                    setState(() {
                      // Disminuir la cantidad solo si es mayor a 0
                      materialesSeleccionados[material.nombre] =
                          cantidadSeleccionada - 1;
                    });
                  }
                      : null,
                ),
                Text(
                  '$cantidadSeleccionada',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: cantidadSeleccionada < material.cantidad
                      ? () {
                    setState(() {
                      // Incrementar la cantidad solo si no excede el disponible
                      materialesSeleccionados[material.nombre] =
                          cantidadSeleccionada + 1;
                    });
                  }
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
