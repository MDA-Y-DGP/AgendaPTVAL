import 'dart:convert';
import 'package:flutter/material.dart';
import '../controlador/estudiante_controller.dart';
import '../controlador/imagen_controller.dart';
import 'package:crypto/crypto.dart';
import 'pagina_principal_estudiante.dart'; // Importar la nueva página principal

class InicioSesionEstudiante extends StatefulWidget {

  const InicioSesionEstudiante({super.key});

  @override
  _InicioSesionEstudianteState createState() => _InicioSesionEstudianteState();
}

class _InicioSesionEstudianteState extends State<InicioSesionEstudiante> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late EstudianteController _estudianteController;
  late ImagenController _imagenController;
  List<Map<String, dynamic>> estudiantes = [];
  Map<String, dynamic>? estudianteSeleccionado;
  String pictogramaPassword = '';

  @override
  void initState() {
    super.initState();
    _estudianteController = EstudianteController();
    _imagenController = ImagenController();
    _cargarEstudiantes();
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _cargarEstudiantes() async {
    try {
      List<Map<String, dynamic>> lista = await _estudianteController.obtenerNombreGradoDeEstudiantes();
      setState(() {
        estudiantes = lista;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar estudiantes: $e')),
      );
    }
  }

  void _seleccionarEstudiante(Map<String, dynamic> estudiante) {
    setState(() {
      estudianteSeleccionado = estudiante;
    });
  }

  // Método para iniciar sesión
  void _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      String password = hashPassword(_passwordController.text);

      final estudiante = await _estudianteController.iniciarSesion(estudianteSeleccionado!['nickname']!, password);

      if (estudiante != null) {
        // Credenciales válidas
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaginaPrincipalEstudiante(nickname: estudianteSeleccionado!['nickname']),
          ),
        );
      } else {
        // Credenciales inválidas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales inválidas')),
        );
      }
    }
  }

  // Método para construir el formulario de contraseña
  Widget _buildPasswordForm() {
    if (estudianteSeleccionado == null) {
      return const SizedBox(); // Retorna un widget vacío si no hay estudiante seleccionado
    }

    // Obtener el grado de aprendizaje del estudiante seleccionado
    String gradoAprendizaje = estudianteSeleccionado!['gradoAprendizaje'] ?? 'alto';

    return LayoutBuilder(
      builder: (context, constraints) {
        double widthFactor = constraints.maxWidth * 0.8; // Ajusta el ancho relativo a la pantalla
        double imageSize = (constraints.maxWidth - 32) / 3; // Ajusta el tamaño de la imagen
        double maxImageSize = 100; // Tamaño máximo de la imagen

        if (imageSize > maxImageSize) {
          imageSize = maxImageSize;
        }

        if (gradoAprendizaje == 'alto') {
          // Campo de texto normal para grado alto
          return Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widthFactor),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hola, ${estudianteSeleccionado!['nickname']}!',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
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
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _iniciarSesion,
                        child: const Text('Iniciar Sesión'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          // Mostrar pictogramas para grado medio o bajo
          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: widthFactor),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hola, ${estudianteSeleccionado!['nickname']}!',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text('Ingresa tu contraseña usando los pictogramas:'),
                    const SizedBox(height: 10),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: constraints.maxHeight * 0.4, // Limita la altura del contenedor
                        maxWidth: constraints.maxWidth * 0.8, // Limita el ancho del contenedor
                      ),
                      child: LayoutBuilder(
                        builder: (context, innerConstraints) {
                          double imageSize = innerConstraints.maxWidth / 3 - 16; // Ajusta el tamaño de la imagen
                          double maxImageSize = 100; // Tamaño máximo de la imagen
                          if (imageSize > maxImageSize) {
                            imageSize = maxImageSize;
                          }
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              int pictogramaNumero = index + 1;
                              return GestureDetector(
                                onTap: () => _agregarDigitoPictograma(pictogramaNumero),
                                child: Image.asset(
                                  'assets/Sol.png',
                                  fit: BoxFit.contain,
                                  width: imageSize,
                                  height: imageSize,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Secuencia: $pictogramaPassword',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _resetPictogramaPassword,
                      child: const Text('Borrar Secuencia'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _iniciarSesionConPictograma,
                      child: const Text('Iniciar Sesión'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  void _agregarDigitoPictograma(int digito) {
    if (pictogramaPassword.length < 4) {
      setState(() {
        pictogramaPassword += digito.toString();
      });
    }
  }

  void _resetPictogramaPassword() {
    setState(() {
      pictogramaPassword = '';
    });
  }

  void _iniciarSesionConPictograma() async {
    if (pictogramaPassword.length == 4) {
      String contrasena = hashPassword(pictogramaPassword);

      final estudiante = await _estudianteController.iniciarSesion(
          estudianteSeleccionado!['nickname']!, contrasena);

      if (estudiante != null) {
        // Credenciales válidas
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaginaPrincipalEstudiante(nickname: estudianteSeleccionado!['nickname']),
          ),
        );
      } else {
        // Credenciales inválidas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales inválidas')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar 4 pictogramas')),
      );
    }
  }

  // Muestra todas las fotos con nombres debajo
  Widget _buildStudentGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
      ),
      itemCount: estudiantes.length,
      itemBuilder: (context, index) {
        final estudiante = estudiantes[index];
        return GestureDetector(
          onTap: () => _seleccionarEstudiante(estudiante),
          child: Column(
            children: [
              FutureBuilder<String>(
                future: _imagenController.obtenerFotoPerfil(estudiante['nickname']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Icon(Icons.error);
                  } else if (snapshot.hasData) {
                    return CircleAvatar(
                      radius: 40, // Hacer la imagen del perfil más pequeña
                      backgroundImage: NetworkImage(snapshot.data!),
                    );
                  } else {
                    return const Icon(Icons.error);
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(estudiante['nickname']!, style: const TextStyle(fontSize: 16)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión - Estudiante'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: estudianteSeleccionado == null
            ? _buildStudentGrid()
            : Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => estudianteSeleccionado = null),
                        child: FutureBuilder<String>(
                          future: _imagenController.obtenerFotoPerfil(estudianteSeleccionado!['nickname']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Icon(Icons.error);
                            } else if (snapshot.hasData) {
                              return CircleAvatar(
                                radius: 40, // Hacer la imagen del perfil más pequeña
                                backgroundImage: NetworkImage(snapshot.data!),
                              );
                            } else {
                              return const Icon(Icons.error);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordForm(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}