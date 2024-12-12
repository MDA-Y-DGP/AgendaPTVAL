import 'dart:io';
import 'package:flutter/material.dart';
import '../controlador/tarea_controller.dart'; // Asegúrate de importar tu controlador
import '../controlador/imagen_controller.dart'; // Importa el controlador de imagen

class RealizarTareaPorPasos extends StatefulWidget {
  final int idTarea;
  final String nickname;

  RealizarTareaPorPasos({required this.idTarea, required this.nickname});

  @override
  _RealizarTareaPorPasosState createState() => _RealizarTareaPorPasosState();
}

class _RealizarTareaPorPasosState extends State<RealizarTareaPorPasos> {
  List<Map<String, dynamic>> _pasos = [];
  String _tituloTarea = '';
  bool _isLoading = true; // Variable para controlar el estado de carga
  final PageController _pageController = PageController();
  final TareaController _controller = TareaController(); // Instancia de tu controlador
  final ImagenController _imagenController = ImagenController(); // Instancia del controlador de imagen

  @override
  void initState() {
    super.initState();
    _cargarTarea();
  }

  Future<void> _cargarTarea() async {
    try {
      var tarea = await _controller.obtenerTareaPorId(widget.idTarea);
      if (tarea != null) {
        setState(() {
          _tituloTarea = tarea.titulo;
        });
        _cargarPasos();
      } else {
        setState(() {
          _isLoading = false;
        });
        print('No se encontró la tarea con id: ${widget.idTarea}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error al cargar la tarea: $e');
    }
  }

  Future<void> _cargarPasos() async {
    try {
      List<Map<String, dynamic>> pasos = await _controller.obtenerPasos(widget.idTarea); // Método para obtener los pasos de la base de datos
      setState(() {
        _pasos = pasos;
        _isLoading = false; // Actualiza el estado de carga
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Manejar el error, por ejemplo, mostrando un mensaje
      print('Error al cargar los pasos: $e');
    }
  }

  Future<void> completarTarea() async {
    try {
      await _controller.completarTarea(widget.nickname, widget.idTarea);
      // Mostrar un mensaje de éxito o realizar alguna acción adicional
      print('Tarea completada');
    } catch (e) {
      // Manejar el error, por ejemplo, mostrando un mensaje
      print('Error al marcar la tarea como completada: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Realizar Tarea por Pasos'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Muestra un indicador de carga mientras se obtienen los pasos
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _tituloTarea,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: _pasos.length + 1, // Añadir uno para el paso de completado
                        itemBuilder: (context, index) {
                          if (index == _pasos.length) {
                            // Último paso: pictograma de completado
                            return GestureDetector(
                              onTap: () {
                                completarTarea();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/pictograma_completado.png',
                                      height: 200,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            var paso = _pasos[index];
                            var descripcion = paso['descripcion'] ?? 'Descripción no disponible';

                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Paso ${index + 1}',
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  FutureBuilder<String>(
                                    future: _imagenController.obtenerImagenPaso(widget.idTarea, index + 1),
                                    builder: (context, snapshot) {
                                      print('Llamando a obtenerImagenPaso para el paso ${index + 1}');
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        print('Error al obtener la imagen del paso ${index + 1}: ${snapshot.error}');
                                        return SizedBox(height: 200); // Espacio vacío si hay un error
                                      } else {
                                        print('Imagen del paso ${index + 1} obtenida: ${snapshot.data}');
                                        return Image.network(
                                          snapshot.data!,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    descripcion,
                                    style: TextStyle(fontSize: 24),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                      Positioned(
                        left: 16,
                        top: MediaQuery.of(context).size.height / 2 - 80,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, size: 64),
                          onPressed: () {
                            if (_pageController.page! > 0) {
                              _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                            }
                          },
                        ),
                      ),
                      Positioned(
                        right: 16,
                        top: MediaQuery.of(context).size.height / 2 - 80,
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward, size: 64),
                          onPressed: () {
                            if (_pageController.page! < _pasos.length) {
                              _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}