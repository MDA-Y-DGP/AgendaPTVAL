import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelo/tarea_modelo.dart'; // Importa el modelo de Tarea
import '../controlador/tarea_controller.dart'; // Importa la función obtenerTareasAsignadasPorFecha

class PaginaPrincipalEstudiante extends StatefulWidget {
  final String nickname;

  const PaginaPrincipalEstudiante({super.key, required this.nickname});

  @override
  _PaginaPrincipalEstudianteState createState() =>
      _PaginaPrincipalEstudianteState();
}

class _PaginaPrincipalEstudianteState extends State<PaginaPrincipalEstudiante> {
  late PageController _pageController;
  late TareaController _tareaController;
  int _currentPage = 0;
  List<Tarea> _tareasDelDia = []; // Lista de tareas del día actual

  @override
  void initState() {
    super.initState();
    _currentPage = _getCurrentDayIndex();
    _pageController = PageController(initialPage: _currentPage);
    _tareaController = TareaController();
    _loadTareasPorDia(); // Cargar las tareas del día actual al iniciar
  }

  Future<void> _loadTareasPorDia() async {
    String fecha = _getFechaPorDia(_currentPage);
    try {
      List<Tarea> tareasData =
      await _tareaController.obtenerTareasAsignadasPorFecha(fecha, widget.nickname);
      setState(() {
        _tareasDelDia = tareasData;
      });
      print(_tareasDelDia);
    } catch (e) {
      // Manejar error
      print('Error al obtener tareas para la fecha $fecha: $e');
      setState(() {
        _tareasDelDia = [];
      });
    }
  }

  int _getCurrentDayIndex() {
    return DateTime.now().weekday - 1; // Ejemplo: Lunes es 0, Domingo es 6
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Principal Estudiante'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: 5, // Número de días de lunes a viernes
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                _loadTareasPorDia(); // Cargar tareas al cambiar de día
              },
              itemBuilder: (context, index) {
                return _buildDayView();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentPage > 0) {
              _pageController.previousPage(
                  duration: Duration(milliseconds: 300), curve: Curves.ease);
            }
          },
        ),
        Text(
          _getNombreDia(_currentPage),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () {
            if (_currentPage < 4) {
              _pageController.nextPage(
                  duration: Duration(milliseconds: 300), curve: Curves.ease);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDayView() {
    if (_tareasDelDia.isEmpty) {
      return Center(child: Text('No hay tareas asignadas para este día.'));
    }

    return ListView.builder(
      itemCount: _tareasDelDia.length,
      itemBuilder: (context, index) {
        Tarea tarea = _tareasDelDia[index];
        return ListTile(
          leading: Icon(_getIconForTask(tarea.tipo)),
          title: Text(tarea.titulo),
          subtitle: Text(tarea.descripcion),
        );
      },
    );
  }

  IconData _getIconForTask(String tipo) {
    switch (tipo) {
      case 'inventario':
        return Icons.inventory;
      case 'por pasos':
        return Icons.account_tree;
      case 'comedor':
        return Icons.restaurant_rounded;
      default:
        return Icons.help_outline;
    }
  }

  String _getFechaPorDia(int index) {
    DateTime now = DateTime.now();
    DateTime fecha = now.add(Duration(days: index - now.weekday + 1));
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
  }

  String _getNombreDia(int index) {
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
}
