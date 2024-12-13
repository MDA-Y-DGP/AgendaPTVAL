import 'package:agenda_ptval/vista/estudiante.dart';
import 'package:agenda_ptval/vista/profesor.dart';
import 'package:flutter/material.dart';
import '../modelo/profesor_modelo.dart';
import '../controlador/profesor_controller.dart';
import 'clases.dart';
import 'crear_menus.dart';
import 'pedir_materiales.dart';
import 'listas_inventario.dart';
import 'tareas.dart';
import 'notificaciones.dart';

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

  Widget _buildOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildWelcomeText() {
    return Text(
      '¡Bienvenido, ${widget.profesor.nickname}!',
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person, size: 20),
            const SizedBox(width: 10),
            Text(
              'Nickname: ${widget.profesor.nickname}',
              style: const TextStyle(fontSize: 16),
            ),
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
      ],
    );
  }

  Widget _buildChangePasswordButton() {
    return ElevatedButton.icon(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white, // Color del texto
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.lock),
      label: const Text('Modificar Contraseña'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white, // Color del texto
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOptionsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: widget.profesor.administrador ? 10 : 1,
      itemBuilder: (context, index) {
        if (widget.profesor.administrador) {
          switch (index) {
            case 0:
              return _buildOption(
                context: context,
                label: 'Clases',
                icon: Icons.class_,
                color: Theme.of(context).colorScheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClasesPage()),
                ),
              );
            case 1:
              return _buildOption(
                context: context,
                label: 'Estudiantes',
                icon: Icons.person_add_alt,
                color: Theme.of(context).colorScheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaEstudiantes()),
                ),
              );
            case 2:
              return _buildOption(
                context: context,
                label: 'Profesores',
                icon: Icons.person_add,
                color: Theme.of(context).colorScheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaProfesores()),
                ),
              );
            case 3:
              return _buildOption(
                context: context,
                label: 'Tareas',
                icon: Icons.assignment,
                color: Theme.of(context).colorScheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TareasPage()),
                ),
              );
            case 4:
              return _buildOption(
                context: context,
                label: 'Crear Menú',
                icon: Icons.menu_book,
                color: Theme.of(context).colorScheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CrearMenu()),
                ),
              );
            case 5:
              return _buildOption(
                context: context,
                label: 'Crear Listas de Inventario',
                icon: Icons.list,
                color: Theme.of(context).colorScheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CrearListasInventario()),
                ),
              );
            case 6:
              return _buildOption(
                context: context,
                label: 'Pedir Materiales',
                icon: Icons.shopping_cart,
                color: Theme.of(context).colorScheme.secondary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PedirMateriales()),
                ),
              );
            case 7:
              return _buildOption(
                context: context,
                label: 'Notificaciones',
                icon: Icons.notifications,
                color: Colors.orange, // Puedes elegir un color que te guste
                onTap: () {
                  // Aquí iría la lógica para abrir la pantalla de notificaciones
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificacionesPage()),
                  );
                },
              );
            default:
              return Container();
          }
        }
        else {
          return _buildOption(
            context: context,
            label: 'Pedir Materiales',
            icon: Icons.shopping_cart,
            color: Theme.of(context).colorScheme.secondary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PedirMateriales()),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text('Inicio'),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
    ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeText(),
            const SizedBox(height: 20),
            _buildUserInfo(),
            const SizedBox(height: 20),
            _buildChangePasswordButton(),
            const SizedBox(height: 20),
            _buildOptionsGrid(),
          ],
        ),
      ),
    );
  }
}