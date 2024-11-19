import 'package:flutter/material.dart';
import '../modelo/profesor_modelo.dart';
import '../controlador/profesor_controller.dart';
import 'pedir_materiales.dart'; // Importar la pantalla de pedir materiales

class PantallaInicioProfesor extends StatelessWidget {
  final Profesor profesor;

  const PantallaInicioProfesor({super.key, required this.profesor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Has iniciado sesión, ${profesor.nickname}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Nickname: ${profesor.nickname}',
                style: const TextStyle(fontSize: 16)),
            Text('Administrador: ${profesor.administrador ? "Sí" : "No"}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ModificarContrasena(profesor: profesor)),
                );
              },
              child: const Text('Modificar Contraseña'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PedirMateriales()),
                );
              },
              child: const Text('Pedir Materiales'),
            ),
          ],
        ),
      ),
    );
  }
}


class ModificarContrasena extends StatefulWidget {
  final Profesor profesor;

  const ModificarContrasena({super.key, required this.profesor});

  @override
  _ModificarContrasenaState createState() => _ModificarContrasenaState();
}

class _ModificarContrasenaState extends State<ModificarContrasena> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProfesorController _profesorController = ProfesorController();

  void _modificarContrasena() async {
    if (_formKey.currentState!.validate()) {
      String nuevaContrasena = _passwordController.text;

      try {
        await _profesorController.modificarContrasena(widget.profesor.nickname, nuevaContrasena);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña modificada correctamente')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al modificar la contraseña: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar Contraseña'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Nueva Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nueva contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _modificarContrasena,
                child: const Text('Modificar Contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}