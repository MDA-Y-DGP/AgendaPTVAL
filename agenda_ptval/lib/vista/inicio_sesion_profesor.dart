import 'package:flutter/material.dart';
import '../controlador/profesor_controller.dart';
import 'inicio_profesor.dart';

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

  void _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      String nickname = _nicknameController.text;
      String password = _passwordController.text;

      try {
        final profesor =
            await _profesorController.verificarCredenciales(nickname, password);
        if (profesor != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaInicio(profesor: profesor),
            ),
          );
        } else {
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

  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset('assets/profesor.png', height: 150),
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
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildNicknameField() {
    return TextFormField(
      controller: _nicknameController,
      decoration: InputDecoration(
        labelText: 'Nickname',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu nickname';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu contraseña';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton.icon(
      onPressed: _iniciarSesion,
      icon: const Icon(Icons.login),
      label: const Text('Iniciar Sesión'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white, // Color del texto
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(Icons.arrow_back),
      label: const Text('Regresar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white, // Color del texto
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth * 0.1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Inicio de Sesión'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            const SizedBox(height: 40),
            _buildForm(),
          ],
        ),
      ),
    );
  }
}
