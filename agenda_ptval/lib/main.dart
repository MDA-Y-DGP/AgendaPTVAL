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
        colorScheme: ColorScheme.light(
          primary: Colors.blueAccent,
          secondary: Colors.orangeAccent,
          surface: Colors.lightBlue[50]!,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
  void _navigateToProfesorLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InicioSesionProfesor()),
    );
  }

  void _navigateToStudentLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InicioSesionEstudiante()),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String label,
    required String imagePath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.width * 0.4,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 250,
              height: 250,
              semanticLabel: 'Imagen de $label',
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 24,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 28),
        ),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOption(
                  context: context,
                  label: 'Profesor',
                  imagePath: 'assets/profesor.png',
                  color: Colors.blueAccent,
                  onTap: () => _navigateToProfesorLogin(context),
                ),
                const SizedBox(width: 20),
                _buildOption(
                  context: context,
                  label: 'Estudiante',
                  imagePath: 'assets/estudiante.png',
                  color: Colors.orangeAccent,
                  onTap: () => _navigateToStudentLogin(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}