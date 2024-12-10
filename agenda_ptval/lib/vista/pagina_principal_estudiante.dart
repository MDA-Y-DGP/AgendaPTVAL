import 'package:flutter/material.dart';
import '../modelo/tarea_modelo.dart'; // Importa el modelo de Tarea
import '../controlador/tarea_controller.dart'; // Importa la función obtenerTareasAsignadasPorFecha
import 'realizar_comanda.dart'; // Importa la vista realizar_comanda.dart

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

  // Mapa para almacenar el estado de completado de cada tarea
  Map<int, bool> _tareasCompletadas = {};

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
      List<Tarea> tareasData = await _tareaController
          .obtenerTareasAsignadasPorFecha(fecha, widget.nickname);
      setState(() {
        _tareasDelDia = tareasData;

        // Inicializamos el estado de las tareas según el valor de 'completado' desde Firestore
        _tareasCompletadas = {
          for (var t in tareasData) t.idTarea: t.completado ?? false,
        };
      });
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

Widget _buildDayView() {
  // Definir el tamaño fijo de cada cuadrado
  double squareSize = 200.0; // Tamaño deseado (ajústalo según tu preferencia)

  return Padding(
    padding: const EdgeInsets.all(10.0), // Márgenes alrededor del GridView
    child: Center(
      child: Wrap(
        spacing: 10.0, // Espacio horizontal entre elementos
        runSpacing: 10.0, // Espacio vertical entre elementos
        children: _tareasDelDia.map((tarea) {
          return GestureDetector(
            onTap: () {
              if (tarea.tipo == 'comedor') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RealizarComanda(),
                  ),
                );
              }
            },
            child: Container(
              width: squareSize, // Ancho fijo
              height: squareSize, // Altura fija (cuadrado)
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8), // Bordes redondeados
              ),
              child: _getPictogramaTarea(tarea),
            ),
          );
        }).toList(),
      ),
    ),
  );
}


  Widget _getPictogramaTarea(Tarea tarea) {
    switch (tarea.tipo) {
      case 'comedor':
        return Image.asset(
          'assets/pictograma_comedor.png',
          fit: BoxFit.cover,
        );
      case 'inventario':
        return Image.asset(
          'assets/pictograma_inventario.png',
          fit: BoxFit.cover,
        );
      case 'por pasos':
        return Image.asset(
          'assets/pictograma_pasos.png',
          fit: BoxFit.cover,
        );
      default:
        return Center(
          child: Text(
            tarea.titulo,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        );
    }
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back,
                  size: 60), // Aumenta el tamaño del icono
              onPressed: () {
                if (_currentPage > 0) {
                  _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease);
                }
              },
            ),
            Text(
              'Día anterior',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        Image.asset(
          _getPictogramaDia(_currentPage),
          width: 200, // Ajusta el tamaño de la imagen
          height: 200, // Ajusta el tamaño de la imagen
        ),
        Row(
          children: [
            Text(
              'Día siguiente',
              style: TextStyle(fontSize: 20),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward,
                  size: 60), // Aumenta el tamaño del icono
              onPressed: () {
                if (_currentPage < 4) {
                  _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  String _getFechaPorDia(int index) {
    DateTime now = DateTime.now();
    DateTime fecha = now.add(Duration(days: index - now.weekday + 1));
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
  }

  String _getPictogramaDia(int index) {
    switch (index) {
      case 0:
        return 'assets/pictograma_lunes.png';
      case 1:
        return 'assets/pictograma_martes.png';
      case 2:
        return 'assets/pictograma_miercoles.png';
      case 3:
        return 'assets/pictograma_jueves.png';
      case 4:
        return 'assets/pictograma_viernes.png';
      default:
        return '';
    }
  }
}
