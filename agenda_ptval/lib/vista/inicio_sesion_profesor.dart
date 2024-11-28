import 'package:flutter/material.dart';
import '../controlador/profesor_controller.dart';
import 'inicio_profesor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';  // Importar la librería

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
        Image.asset('assets/profesor.png', height: 300.h), // Usar .h para el tamaño
        SizedBox(height: 20.h),
        Text(
          'Inicio de Sesión - Profesor',
          style: TextStyle(
            fontSize: 24.sp, // Usar .sp para el tamaño de texto dentro del método build
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
          SizedBox(height: 16.h),
          _buildPasswordField(),
          SizedBox(height: 20.h),
          _buildLoginButton(),
          SizedBox(height: 20.h),
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
          borderRadius: BorderRadius.circular(10.r), // Usar .r para el radio del borde
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
      style: TextStyle(fontSize: 16.sp), // Usar .sp para el tamaño del texto
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r), // Usar .r para el radio del borde
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
      style: TextStyle(fontSize: 16.sp), // Usar .sp para el tamaño del texto
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
        padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 15.h), // Usar .w y .h
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r), // Usar .r para el radio
        ),
        textStyle: TextStyle(
          fontSize: 16.sp, // Usar .sp para el tamaño del texto
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
        padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 15.h), // Usar .w y .h
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r), // Usar .r para el radio
        ),
        textStyle: TextStyle(
          fontSize: 16.sp, // Usar .sp para el tamaño del texto
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
        title: Text(
          'Inicio de Sesión',
          style: TextStyle(fontSize: 24.sp), // Usar .sp aquí también
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center( // Centrar todo el contenido dentro del body
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding.w), // Usar .w para el padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Centrar el contenido horizontalmente
            children: [
              _buildLogo(),
              SizedBox(height: 40.h), // Usar .h para la altura
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }
}
