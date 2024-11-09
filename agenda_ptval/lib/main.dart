import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'vista/inicio_sesion_profesor.dart';
import 'vista/inicio_sesion_estudiante.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  runApp(MyApp(firestore: firestore));
}

class MyApp extends StatelessWidget {
  final FirebaseFirestore firestore;

  const MyApp({Key? key, required this.firestore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda PTVAL',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Agenda PTVAL', firestore: firestore),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final FirebaseFirestore firestore;

  const MyHomePage({Key? key, required this.title, required this.firestore}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Navega a la pantalla de inicio de sesión del profesor
  void _navigateToProfesorLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InicioSesionProfesor()),
    );
  }

  // Navega a la pantalla de inicio de sesión del estudiante
  void _navigateToStudentLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InicioSesionEstudiante()),
    );
  }

  // Construye el widget para la opción de profesor
  Widget _buildProfesorOption(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToProfesorLogin(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/profesor.png',
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.width * 0.4,
            semanticLabel: 'Imagen de un profesor',
          ),
          const SizedBox(height: 10),
          const Text(
            'Profesor',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  // Construye el widget para la opción de estudiante
  Widget _buildEstudianteOption(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToStudentLogin(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/estudiante.png',
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.width * 0.4,
            semanticLabel: 'Imagen de un estudiante',
          ),
          const SizedBox(height: 10),
          const Text(
            'Estudiante',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true, // Centra el título
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfesorOption(context),
              SizedBox(width: screenWidth * 0.05),
              _buildEstudianteOption(context),
            ],
          ),
        ),
      ),
    );
  }
}