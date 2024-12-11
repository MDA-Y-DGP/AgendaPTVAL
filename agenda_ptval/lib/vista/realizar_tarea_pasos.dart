import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controlador/tarea_controller.dart'; // Asegúrate de importar tu controlador

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
  final ImagePicker _picker = ImagePicker();
  final PageController _pageController = PageController();
  final TareaController _controller = TareaController(); // Instancia de tu controlador

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

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pasos[index]['imagen'] = pickedFile.path;
      });
    }
  }

  Future<void> _pickVideo(int index) async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pasos[index]['video'] = pickedFile.path;
      });
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
                            var imagen = paso['imagen'];
                            var video = paso['video'];

                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    descripcion,
                                    style: TextStyle(fontSize: 24),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  if (imagen != null)
                                    Image.file(
                                      File(imagen),
                                      height: 200,
                                    ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => _pickImage(index),
                                    child: Text('Subir Imagen'),
                                  ),
                                  const SizedBox(height: 16),
                                  if (video != null)
                                    Text('Video seleccionado: ${video.split('/').last}'),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => _pickVideo(index),
                                    child: Text('Subir Video'),
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