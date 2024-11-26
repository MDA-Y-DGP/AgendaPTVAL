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

class RegistroEstudiante extends StatefulWidget {
  @override
  _RegistroEstudianteState createState() => _RegistroEstudianteState();
}

class _RegistroEstudianteState extends State<RegistroEstudiante> {
  final _formKey = GlobalKey<FormState>();
  final EstudianteController _controller = EstudianteController();
  final ClaseController _claseController = ClaseController();
  final ImagenController _imagenController = ImagenController();
  final ImagePicker _picker = ImagePicker();

  String nickname = '';
  String gradoAprendizaje = 'bajo'; // Valor predeterminado
  String? claseAsignada;
  File? imagen;
  Uint8List? imagenBytes;
  String contrasena = '';

  List<Clase> clases = []; // Lista para almacenar las clases

  @override
  void initState() {
    super.initState();
    _cargarClases(); // Cargar clases al inicializar el estado
  }

  Future<void> _cargarClases() async {
    List<Clase> clasesObtenidas = await _claseController.obtenerClases();
    setState(() {
      clases = clasesObtenidas;
    });
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

  Future<void> _registrar() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      await _subirImagen();

      Estudiante nuevoEstudiante = Estudiante(
        idEstudiante: 0, // Este valor se actualizará en el controlador
        nickname: nickname,
        gradoAprendizaje: gradoAprendizaje,
        idClase: int.parse(claseAsignada!), // Guardamos el ID de la clase
        idHistorial: 0, // Este valor se actualizará en el controlador
        contrasena: hashPassword(contrasena),
      );

      try {
        await _controller.registrarEstudiante(nuevoEstudiante);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estudiante registrado con éxito!')),
        );
        Navigator.pop(context); // Volver a la página anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar: $e')),
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
  }) {
    return TextFormField(
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
        title: const Text('Registro de Estudiante'),
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
                Image.memory(imagenBytes!, height: 200),
              ListTile(
                title: Text(imagen == null && imagenBytes == null ? 'Selecciona una imagen (opcional)' : 'Imagen seleccionada'),
                trailing: const Icon(Icons.image),
                onTap: _pickImage,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                labelText: 'Contraseña',
                onSaved: (value) => contrasena = value!,
                validator: (value) {
                  if (value!.isEmpty) {
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
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _registrar();
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
                child: const Text('Registrar Estudiante', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}