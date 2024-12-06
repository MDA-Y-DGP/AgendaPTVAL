import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:agenda_ptval/controlador/clase_controller.dart';
import 'package:flutter/material.dart';
import 'package:agenda_ptval/modelo/estudiante_modelo.dart';
import 'package:agenda_ptval/modelo/clase_modelo.dart';
import 'package:agenda_ptval/controlador/estudiante_controller.dart';
import 'package:agenda_ptval/controlador/imagen_controller.dart';
import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class ModificarEstudiante extends StatefulWidget {
  final Estudiante estudiante;

  ModificarEstudiante({required this.estudiante});

  @override
  _ModificarEstudianteState createState() => _ModificarEstudianteState();
}

class _ModificarEstudianteState extends State<ModificarEstudiante> {
  final _formKey = GlobalKey<FormState>();
  final EstudianteController _controller = EstudianteController();
  final ClaseController _claseController = ClaseController();
  final ImagenController _imagenController = ImagenController();
  final ImagePicker _picker = ImagePicker();

  late String nickname;
  late String gradoAprendizaje;
  String? claseAsignada;
  File? imagen;
  Uint8List? imagenBytes;
  late String contrasena;
  String? imagenUrl;

  List<Clase> clases = []; // Lista para almacenar las clases

  @override
  void initState() {
    super.initState();
    _cargarClases(); // Cargar clases al inicializar el estado
    _loadEstudianteData(); // Cargar datos del estudiante
  }

  Future<void> _cargarClases() async {
    List<Clase> clasesObtenidas = await _claseController.obtenerClases();
    setState(() {
      clases = clasesObtenidas;
    });
  }

  void _loadEstudianteData() async {
    nickname = widget.estudiante.nickname;
    gradoAprendizaje = widget.estudiante.gradoAprendizaje;
    claseAsignada = widget.estudiante.idClase.toString();
    contrasena = widget.estudiante.contrasena; // Inicializamos la contraseña con el valor existente
    imagenUrl = await _imagenController.obtenerFotoPerfil(nickname); // Inicializamos la URL de la imagen existente
    setState(() {});
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            imagenBytes = bytes;
            imagenUrl = null; // Limpiamos la URL de la imagen existente
          });
        } else {
          setState(() {
            imagen = File(pickedFile.path);
            imagenUrl = null; // Limpiamos la URL de la imagen existente
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar la imagen: $e')),
      );
    }
  }

  Future<void> _subirImagen() async {
    if (imagen != null || imagenBytes != null) {
      try {
        if (kIsWeb && imagenBytes != null) {
          await _imagenController.subirImagenWeb(imagenBytes!, 'img_perfil', nickname);
        } else if (imagen != null) {
          await _imagenController.subirImagen(imagen!, 'img_perfil', nickname);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: $e')),
        );
        return;
      }
    }
  }

  Future<void> _modificar() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      await _subirImagen();

      Map<String, dynamic> nuevosDatos = {
        'nickname': nickname,
        'grado_aprendizaje': gradoAprendizaje,
        'id_clase': int.parse(claseAsignada!),
        'contrasena': contrasena.isNotEmpty && contrasena != widget.estudiante.contrasena ? hashPassword(contrasena) : widget.estudiante.contrasena,
        // Añadir otros campos necesarios
      };

      try {
        await _controller.modificarPerfilEstudiante(widget.estudiante.idEstudiante.toString(), nuevosDatos);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil del estudiante modificado con éxito!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al modificar el perfil del estudiante: $e')),
        );
      }
    }
  }

  Widget _buildTextFormField({
    required String labelText,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    String? initialValue,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      onSaved: onSaved,
      validator: validator,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
    );
  }

  Widget _buildDropdownButtonFormField({
    required String labelText,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildClaseDropdownButtonFormField() {
    return DropdownButtonFormField<String>(
      value: claseAsignada,
      decoration: const InputDecoration(
        labelText: 'Clase Asignada',
        border: OutlineInputBorder(),
      ),
      items: clases.map((Clase clase) {
        return DropdownMenuItem<String>(
          value: clase.idClase.toString(), // Aquí guardamos el ID de la clase
          child: Text(clase.nombre), // Aquí mostramos el nombre de la clase
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          claseAsignada = value; // Aquí asignamos el ID de la clase seleccionada
        });
      },
      validator: (value) => value == null ? 'Selecciona una clase' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar Estudiante'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField(
                labelText: 'Nickname',
                onSaved: (value) => nickname = value!,
                validator: (value) => value!.isEmpty ? 'Ingresa un nickname' : null,
                initialValue: nickname,
              ),
              const SizedBox(height: 16),
              _buildDropdownButtonFormField(
                labelText: 'Grado de Aprendizaje',
                value: gradoAprendizaje,
                items: ['bajo', 'medio', 'alto'],
                onChanged: (value) {
                  setState(() {
                    gradoAprendizaje = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildClaseDropdownButtonFormField(),
              const SizedBox(height: 16),
              if (imagen != null)
                Image.file(imagen!, height: 200)
              else if (imagenBytes != null)
                Image.memory(imagenBytes!, height: 200)
              else if (imagenUrl != null)
                Image.network(imagenUrl!, height: 200),
              ListTile(
                title: Text(imagen == null && imagenBytes == null ? 'Selecciona una imagen (opcional)' : 'Imagen seleccionada'),
                trailing: const Icon(Icons.image),
                onTap: _pickImage,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                labelText: 'Contraseña',
                onSaved: (value) {
                  if (value!.isNotEmpty && value != widget.estudiante.contrasena) {
                    contrasena = value;
                  }
                },
                validator: (value) {
                  if (value!.isEmpty && contrasena.isEmpty) {
                    return 'Ingresa una contraseña';
                  }
                  if ((gradoAprendizaje == 'bajo' || gradoAprendizaje == 'medio') && !RegExp(r'^[1-6]{4}$').hasMatch(value)) {
                    return 'La contraseña debe ser de 4 dígitos entre 1 y 6';
                  }
                  return null;
                },
                obscureText: true,
                inputFormatters: (gradoAprendizaje == 'bajo' || gradoAprendizaje == 'medio')
                    ? [FilteringTextInputFormatter.allow(RegExp(r'[1-6]')), LengthLimitingTextInputFormatter(4)]
                    : null,
                initialValue: widget.estudiante.contrasena,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _modificar();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
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
                child: const Text('Actualizar Estudiante', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}