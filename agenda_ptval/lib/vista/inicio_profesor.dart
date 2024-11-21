import 'package:agenda_ptval/vista/clases.dart';
import 'package:flutter/material.dart';
import '../modelo/profesor_modelo.dart';
import '../controlador/profesor_controller.dart';
import 'registro_estudiante.dart';
import 'registro_profesor.dart';
import 'crear_tarea.dart';
import 'asignar_tarea.dart';
import 'crear_menus.dart';
import 'pedir_materiales.dart';
import 'listas_inventario.dart';
import 'evaluar_tarea.dart';

class PantallaInicio extends StatefulWidget {
  final Profesor profesor;

  const PantallaInicio({super.key, required this.profesor});

  @override
  _PantallaInicioState createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProfesorController _profesorController = ProfesorController();

  void _modificarContrasena() async {
    if (_formKey.currentState!.validate()) {
      String nuevaContrasena = _passwordController.text;

      try {
        await _profesorController.modificarContrasena(
            widget.profesor.nickname, nuevaContrasena);
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
        title: const Text('Inicio'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido, ${widget.profesor.nickname}!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 10),
                Text('Nickname: ${widget.profesor.nickname}',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.shield, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Administrador: ${widget.profesor.administrador ? "Sí" : "No"}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Modificar Contraseña'),
                    content: Form(
                      key: _formKey,
                      child: TextFormField(
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
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: _modificarContrasena,
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.lock),
              label: const Text('Modificar Contraseña'),
            ),
            const SizedBox(height: 20),
            if (widget.profesor.administrador) ...[
              _buildButton(context, 'Clases', ClasesPage(), Icons.class_),
              _buildButton(context, 'Registrar Estudiante',
                  RegistroEstudiante(), Icons.person_add_alt),
              _buildButton(context, 'Registrar Profesor', RegistroProfesor(),
                  Icons.person_add),
              _buildButton(context, 'Crear Tarea', CrearTarea(), Icons.task),
              _buildButton(context, 'Asignar Tarea',
                  AsignarTarea(), Icons.pending_actions),
              _buildButton(context, 'Evaluar Tarea',
                  EvaluarTarea(), Icons.thumb_up_alt),
              _buildButton(context, 'Crear Menú', CrearMenu(), Icons.menu_book),
              _buildButton(context, 'Crear Listas de Inventario',
                  CrearListasInventario(), Icons.list), // Nuevo botón
            ],
            _buildButton(context, 'Pedir Materiales', PedirMateriales(),
                Icons.shopping_cart),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Widget page, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
