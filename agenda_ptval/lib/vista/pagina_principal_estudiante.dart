import 'package:flutter/material.dart';
import '../controlador/estudiante_controller.dart';
import 'realizar_comanda.dart'; // Importa la página de realizar comanda
import 'realizar_tarea_inventario.dart'; // Importa la página de realizar tarea de inventario
import '../modelo/tarea_modelo.dart'; // Importa el modelo de Tarea
import '../controlador/tarea_controller.dart'; // Importa el controlador de tareas

class PaginaPrincipalEstudiante extends StatefulWidget {
  final String nickname;

  const PaginaPrincipalEstudiante({super.key, required this.nickname});

  @override
  _PaginaPrincipalEstudianteState createState() =>
      _PaginaPrincipalEstudianteState();
}

class _PaginaPrincipalEstudianteState extends State<PaginaPrincipalEstudiante> {
  late PageController _pageController;
  final TareaController _tareaController = TareaController();
  int _currentPage = 0;
  Map<String, List<Map<String, dynamic>>> _tareasPorDia = {};

  @override
  void initState() {
    super.initState();
    _currentPage = _getCurrentDayIndex();
    _pageController = PageController(initialPage: _currentPage);
  }

  int _getCurrentDayIndex() {
    DateTime now = DateTime.now();
    int weekday = now.weekday;
    if (weekday >= 1 && weekday <= 5) {
      return weekday - 1; // Lunes es 0, Martes es 1, ..., Viernes es 4
    }
    return 0; // Si es fin de semana, por defecto mostrar Lunes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Principal Estudiante'),
        backgroundColor: Colors.orangeAccent, // Color del AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: 5,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                String fecha = _getFechaPorDia(index);
                List<Map<String, dynamic>> tareasDelDia =
                    _tareasPorDia[fecha] ?? [];

                return Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width *
                        0.85, // Ajustar el ancho del contenedor
                    height: MediaQuery.of(context).size.height *
                        0.75, // Ajustar la altura del contenedor
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getDayOfWeek(index),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          Expanded(
                            child: ListView.builder(
                              itemCount: tareasDelDia.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    tareasDelDia[index]['titulo'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    tareasDelDia[index]['descripcion'],
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 16,
              top: MediaQuery.of(context).size.height / 2 - 30,
              child: IconButton(
                icon: Icon(Icons.arrow_back, size: 30),
                onPressed: _currentPage > 0
                    ? () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    : null,
              ),
            ),
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height / 2 - 30,
              child: IconButton(
                icon: Icon(Icons.arrow_forward, size: 30),
                onPressed: _currentPage < 4
                    ? () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayOfWeek(int index) {
    switch (index) {
      case 0:
        return 'Lunes';
      case 1:
        return 'Martes';
      case 2:
        return 'Miércoles';
      case 3:
        return 'Jueves';
      case 4:
        return 'Viernes';
      default:
        return '';
    }
  }

  String _getFechaPorDia(int index) {
    DateTime now = DateTime.now();
    DateTime fecha = now.add(Duration(days: index - now.weekday + 1));
    return '${fecha.year}-${fecha.month}-${fecha.day}';
  }
}
