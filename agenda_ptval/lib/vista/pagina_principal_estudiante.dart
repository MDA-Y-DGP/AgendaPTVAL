import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelo/tarea_modelo.dart'; // Importa el modelo de Tarea

class PaginaPrincipalEstudiante extends StatefulWidget {
  final String nickname;

  const PaginaPrincipalEstudiante({super.key, required this.nickname});

  @override
  _PaginaPrincipalEstudianteState createState() =>
      _PaginaPrincipalEstudianteState();
}

class _PaginaPrincipalEstudianteState extends State<PaginaPrincipalEstudiante> {
  late PageController _pageController;
  int _currentPage = 0;
  Map<String, List<Tarea>> _tareasPorDia = {};

  @override
  void initState() {
    super.initState();
    _currentPage = _getCurrentDayIndex();
    _pageController = PageController(initialPage: _currentPage);
    _loadTareasAsignadas();
  }

  Future<void> _loadTareasAsignadas() async {
    try {
      Map<String, List<Tarea>> tareasPorDia =
          await obtenerTareasAsignadas(widget.nickname);
      setState(() {
        _tareasPorDia = tareasPorDia;
      });
    } catch (e) {
      // Manejar error
      print('Error al obtener tareas asignadas: $e');
    }
  }

  Future<Map<String, List<Tarea>>> obtenerTareasAsignadas(
      String nicknameEstudiante) async {
    // Buscar al estudiante
    QuerySnapshot estudianteSnapshot = await FirebaseFirestore.instance
        .collection('estudiantes')
        .where('nickname', isEqualTo: nicknameEstudiante)
        .get();

    if (estudianteSnapshot.docs.isEmpty) {
      throw Exception('Estudiante no encontrado');
    }

    DocumentSnapshot estudianteDoc = estudianteSnapshot.docs.first;
    String estudianteId = estudianteDoc.id;

    // Obtener tareas asignadas
    CollectionReference tareasAsignadasRef = FirebaseFirestore.instance
        .collection('estudiantes')
        .doc(estudianteId)
        .collection('tareasAsignadas');

    QuerySnapshot tareasAsignadasSnapshot = await tareasAsignadasRef.get();

    // Convertir tareas a objetos Tarea y agrupar por fecha
    Map<String, List<Tarea>> tareasPorDia = {};
    for (var doc in tareasAsignadasSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Tarea tarea = Tarea.fromMap(data['tarea']);
      String fecha =
          data['fecha']; // Asumiendo que la fecha se añade en el controlador

      if (!tareasPorDia.containsKey(fecha)) {
        tareasPorDia[fecha] = [];
      }
      tareasPorDia[fecha]!.add(tarea);
    }

    return tareasPorDia;
  }

  int _getCurrentDayIndex() {
    // Implementa la lógica para obtener el índice del día actual
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
              },
              itemBuilder: (context, index) {
                return _buildDayView(index);
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

  Widget _buildDayView(int index) {
    String fecha = _getFechaPorDia(index);
    List<Tarea>? tareas = _tareasPorDia[fecha];

    if (tareas == null || tareas.isEmpty) {
      return Center(child: Text('No hay tareas asignadas para este día.'));
    }

    return ListView.builder(
      itemCount: tareas.length,
      itemBuilder: (context, index) {
        Tarea tarea = tareas[index];
        return ListTile(
          title: Text(tarea.titulo),
          subtitle: Text(tarea.descripcion),
        );
      },
    );
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
