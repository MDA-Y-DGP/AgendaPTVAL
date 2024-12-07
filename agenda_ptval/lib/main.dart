import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'vista/inicio_sesion_profesor.dart';
import 'vista/inicio_sesion_estudiante.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';  // Importar la librería

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Inicializar la aplicación con ScreenUtil
  runApp(ScreenUtilInit(
    designSize: Size(1024, 1366), // Tamaño base de diseño para iPad
    builder: (context, child) {  // Aceptar un BuildContext y un Widget hijo (child)
      return MyApp(firestore: firestore);  // Devolver MyApp con el contexto
    },
  ));
}

class MyApp extends StatelessWidget {
  final FirebaseFirestore firestore;

  const MyApp({Key? key, required this.firestore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda PTVAL',
      theme: ThemeData(
        fontFamily: 'Scholar', // Establecer la fuente predeterminada
        colorScheme: ColorScheme.light(
          primary: Colors.blueAccent,
          secondary: Colors.orangeAccent,
          surface: Colors.lightBlue[50]!,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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
        width: 0.4.sw,  // Usar .sw para el 40% del ancho de la pantalla
        height: 0.4.sw, // Usar .sw para el 40% del ancho de la pantalla
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.sp), // Usar .sp para el tamaño de padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 200.w,  // Ajustar el tamaño de la imagen
              height: 200.w, // Ajustar el tamaño de la imagen
              semanticLabel: 'Imagen de $label',
            ),
            SizedBox(height: 10.h),  // Usar .h para la altura
            Text(
              label,
              style: TextStyle(
                fontSize: 24.sp,  // Usar .sp para el tamaño de texto
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
          style: TextStyle(fontSize: 28.sp), // Usar .sp para el tamaño de texto
        ),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 32.0.h), // Escalar el padding
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
                SizedBox(width: 20.w), // Usar .w para el espacio entre los elementos
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