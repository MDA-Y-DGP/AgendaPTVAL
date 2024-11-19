import 'package:flutter/material.dart';
import '../controlador/profesor_controller.dart';
import 'inicio_administrador.dart';
import 'inicio_profesor.dart'; // Importar la nueva pantalla para profesores

class InicioSesionProfesor extends StatefulWidget {
  const InicioSesionProfesor({super.key});

  @override
  _InicioSesionState createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesionProfesor> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late ProfesorController _profesorController;

  @override
  void initState() {
    super.initState();
    _profesorController = ProfesorController();
  }

  // Método para iniciar sesión
  void _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      String nickname = _nicknameController.text;
      String password = _passwordController.text;

      try {
        // Verificar las credenciales en Firestore
        final profesor = await _profesorController.verificarCredenciales(nickname, password);

        if (profesor != null) {
          // Credenciales válidas, navegar a la nueva pantalla según el rol
          if (profesor.administrador) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PantallaInicioAdministrador(profesor: profesor),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PantallaInicioProfesor(profesor: profesor),
              ),
            );
          }
        } else {
          // Credenciales inválidas
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Credenciales inválidas')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e')),
        );
      }
    }
  }

  // Widget para el logo y el título
  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset('assets/profesor.png', height: 250),
        const SizedBox(height: 20),
        const Text(
          'Inicio de Sesión - Profesor',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // Widget para el formulario de inicio de sesión
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNicknameField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 20),
          _buildLoginButton(),
          const SizedBox(height: 20),
          _buildBackButton(), // Añadir el botón de regreso
        ],
      ),
    );
  }

  // Widget para el campo de nickname
  Widget _buildNicknameField() {
    return Semantics(
      label: 'Campo de nickname',
      hint: 'Ingresa tu nickname',
      child: TextFormField(
        controller: _nicknameController,
        decoration: InputDecoration(
          labelText: 'Nickname',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa tu nickname';
          }
          return null;
        },
      ),
    );
  }

  // Widget para el campo de contraseña
  Widget _buildPasswordField() {
    return Semantics(
      label: 'Campo de contraseña',
      hint: 'Ingresa tu contraseña',
      child: TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Contraseña',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
        ),
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa tu contraseña';
          }
          return null;
        },
      ),
    );
  }

  // Widget para el botón de inicio de sesión
  Widget _buildLoginButton() {
    return Semantics(
      label: 'Botón de inicio de sesión',
      hint: 'Presiona para iniciar sesión',
      child: ElevatedButton(
        onPressed: _iniciarSesion,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Iniciar Sesión'),
      ),
    );
  }

  // Widget para el botón de regreso
  Widget _buildBackButton() {
    return Semantics(
      label: 'Botón de regreso',
      hint: 'Presiona para volver a la página anterior',
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back),
        label: const Text('Regresar'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          label: 'Botón de atrás',
          hint: 'Vuelve a la página anterior',
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 30),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: 'Logo de la aplicación',
                    child: _buildLogo(),
                  ),
                  const SizedBox(height: 40),
                  Semantics(
                    label: 'Formulario de inicio de sesión',
                    child: _buildForm(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}