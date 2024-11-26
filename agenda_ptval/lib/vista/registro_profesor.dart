import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:agenda_ptval/controlador/profesor_controller.dart';
import 'package:agenda_ptval/modelo/profesor_modelo.dart';
import 'package:crypto/crypto.dart';

class RegistroProfesor extends StatefulWidget {
  @override
  _RegistroProfesorState createState() => _RegistroProfesorState();
}

class _RegistroProfesorState extends State<RegistroProfesor> {
  final _formKey = GlobalKey<FormState>();
  final ProfesorController _controller = ProfesorController();

  String nickname = '';
  String contrasena = '';
  bool esAdministrador = false;

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _registrar() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Profesor nuevoProfesor = Profesor(
        idProfesor: 0, // Se actualizará en el controlador
        nickname: nickname,
        contrasena: hashPassword(contrasena),
        administrador: esAdministrador,
      );

      try {
        await _controller.registrarProfesor(nuevoProfesor);
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Profesor registrado con éxito!')),
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
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      onSaved: onSaved,
      validator: validator,
      obscureText: obscureText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Profesor'),
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
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa un nickname' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                labelText: 'Contraseña',
                onSaved: (value) => contrasena = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa una contraseña' : null,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Administrador'),
                value: esAdministrador,
                onChanged: (value) {
                  setState(() {
                    esAdministrador = value;
                  });
                },
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
                child: const Text('Registrar Profesor', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}