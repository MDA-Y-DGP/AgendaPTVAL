import 'package:flutter/material.dart';
import 'package:agenda_ptval/controlador/tarea_controller.dart';
import 'package:agenda_ptval/modelo/tarea_modelo.dart';
import 'package:agenda_ptval/widgets/imagen_con_texto.dart'; // Importa el nuevo widget
import 'realizar_tarea_pasos.dart';
import 'seleccionar_clase.dart';
import 'realizar_tarea_inventario.dart';
import '../controlador/imagen_controller.dart';

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
  final ImagenController _imagenController = ImagenController();
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
        backgroundColor: Colors.blueAccent,
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
    return Wrap(
      spacing: 10, // Espacio horizontal entre los elementos
      runSpacing: 10, // Espacio vertical entre las filas
      alignment: WrapAlignment.center, // Centra los elementos en el Wrap
      children: _tareasDelDia.map((tarea) {
        return GestureDetector(
          onTap: () {
            if (tarea.tipo == 'inventario') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RealizarTareaInventario(),
                ),
              );
            } else if (tarea.tipo == 'comedor') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeleccionarClasePage(),
                ),
              );
            } else if (tarea.tipo == 'por pasos') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RealizarTareaPorPasos(idTarea: tarea.idTarea, nickname: widget.nickname),
                ),
              );
            }
          },
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _tareasCompletadas[tarea.idTarea]!
                      ? Colors.grey
                      : Colors.transparent,
                  BlendMode.saturation,
                ),
                    child: FutureBuilder<String>(
                          future: _getPictogramaTarea(tarea),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError || !snapshot.hasData) {
                              return ImagenConTexto(
                                imageUrl: 'assets/pictograma_pasos.png',
                                texto: tarea.titulo,
                              );
                            } else {
                              return ImagenConTexto(
                                imageUrl: snapshot.data!,
                                texto: tarea.titulo,
                              );
                            }
                          },
                        ),                           
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

    Future<String> _getPictogramaTarea(Tarea tarea) async {
    switch (tarea.tipo) {
      case 'comedor':
        return 'assets/pictograma_comedor.png';
      case 'inventario':
        return 'assets/pictograma_inventario.png';
      case 'por pasos':
      try {
        return await _imagenController.obtenerImagenPaso(tarea.idTarea, 0);
      } catch (e) {
        return 'assets/pictograma_pasos.png';
      }

      default:
        return 'assets/default.png';
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