import 'package:flutter/material.dart';
import '../controlador/clase_controller.dart';
import '../controlador/tarea_controller.dart';
import '../controlador/estudiante_controller.dart';
import '../modelo/clase_modelo.dart';
import '../modelo/estudiante_modelo.dart';
import '../modelo/tarea_modelo.dart';

class AsignarTarea extends StatefulWidget {
  @override
  _AsignarTareaState createState() => _AsignarTareaState();
}

class _AsignarTareaState extends State<AsignarTarea> {
  final ClaseController _claseController = ClaseController();
  final EstudianteController _estudianteController = EstudianteController();
  final TareaController _tareaController = TareaController();

  String? _tipoTareaSeleccionada;
  String? _selectedTarea;
  String? _selectedClase;
  String? _selectedEstudiante;
  List<Estudiante> _estudiantes = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Tarea'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTipoTareaDropdown(),
            const SizedBox(height: 20),
            if (_tipoTareaSeleccionada != null) _buildFormularioSegunTipoTarea(),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoTareaDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Selecciona el tipo de tarea',
        border: OutlineInputBorder(),
      ),
      value: _tipoTareaSeleccionada,
      onChanged: (String? newValue) {
        setState(() {
          _tipoTareaSeleccionada = newValue;
          _selectedTarea = null;
          _selectedClase = null;
          _selectedEstudiante = null;
          _estudiantes = [];
        });
      },
      items: [
        DropdownMenuItem(value: 'comedor', child: Text('Comedor')),
        DropdownMenuItem(value: 'por pasos', child: Text('Por pasos')),
        DropdownMenuItem(value: 'inventario', child: Text('Inventario')),
      ],
    );
  }

  Widget _buildFormularioSegunTipoTarea() {
    switch (_tipoTareaSeleccionada) {
      case 'comedor':
        return _buildFormularioGenerico(
          tipo: 'Comedor',
          obtenerTareas: _tareaController.obtenerTareasDeTipoComedor,
          asignarTarea: _asignarTareaComedor,
        );
      case 'por pasos':
        return _buildFormularioGenerico(
          tipo: 'Por pasos',
          obtenerTareas: _tareaController.obtenerTareasDeTipoPorPasos,
          asignarTarea: _asignarTareaPorPasos,
        );
      case 'inventario':
        return _buildFormularioGenerico(
          tipo: 'Inventario',
          obtenerTareas: _tareaController.obtenerTareasDeTipoInventario,
          asignarTarea: _asignarTareaInventario,
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildFormularioGenerico({
    required String tipo,
    required Future<List<Tarea>> Function() obtenerTareas,
    required VoidCallback asignarTarea,
  }) {
    return Column(
      children: [
        _buildTareasDropdown(tipo, obtenerTareas),
        const SizedBox(height: 20),
        _buildClasesDropdown(),
        const SizedBox(height: 20),
        _buildEstudiantesDropdown(),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _selectedClase == null || _selectedTarea == null || _selectedEstudiante == null
              ? null
              : asignarTarea,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Color del texto
            ),
          ),
          child: Text('Asignar Tarea de $tipo', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTareasDropdown(
      String tipo, Future<List<Tarea>> Function() obtenerTareas) {
    return FutureBuilder<List<Tarea>>(
      future: obtenerTareas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error al cargar tareas de $tipo'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay tareas de $tipo disponibles'));
        } else {
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Selecciona una tarea de $tipo',
              border: OutlineInputBorder(),
            ),
            value: _selectedTarea,
            onChanged: (String? newValue) {
              setState(() {
                _selectedTarea = newValue;
              });
            },
            items: snapshot.data!.map((Tarea tarea) {
              return DropdownMenuItem<String>(
                value: tarea.idTarea.toString(),
                child: Text(tarea.titulo),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildClasesDropdown() {
    return FutureBuilder<List<Clase>>(
      future: _claseController.obtenerClases(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error al cargar clases'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay clases disponibles'));
        } else {
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Selecciona una clase',
              border: OutlineInputBorder(),
            ),
            value: _selectedClase,
            onChanged: (String? newValue) {
              setState(() {
                _selectedClase = newValue;
                _selectedEstudiante = null;
                _fetchEstudiantesPorClase(newValue!);
              });
            },
            items: snapshot.data!.map((Clase clase) {
              return DropdownMenuItem<String>(
                value: clase.idClase.toString(),
                child: Text(clase.nombre),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildEstudiantesDropdown() {
    return _estudiantes.isEmpty
        ? Center(child: Text('No hay estudiantes disponibles'))
        : DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Selecciona un estudiante',
        border: OutlineInputBorder(),
      ),
      value: _selectedEstudiante,
      onChanged: (String? newValue) {
        setState(() {
          _selectedEstudiante = newValue;
        });
      },
      items: _estudiantes.map((Estudiante estudiante) {
        return DropdownMenuItem<String>(
          value: estudiante.nickname,
          child: Text(estudiante.nickname),
        );
      }).toList(),
    );
  }

  void _fetchEstudiantesPorClase(String claseId) async {
    setState(() {
    });
    List<Estudiante> estudiantes = await _estudianteController.obtenerEstudiantesPorClase(claseId);
    setState(() {
      _estudiantes = estudiantes;
    });
  }

  void _asignarTareaComedor() async => _asignarTareaGenerica('comedor');
  void _asignarTareaPorPasos() async => _asignarTareaGenerica('por pasos');
  void _asignarTareaInventario() async => _asignarTareaGenerica('inventario');

  void _asignarTareaGenerica(String tipo) async {
    if (_selectedClase != null && _selectedTarea != null && _selectedEstudiante != null) {
      try {
        await _tareaController.asignarTarea(_selectedTarea!, _selectedEstudiante!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarea de $tipo asignada correctamente')),
        );
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al asignar tarea: $e')),
        );
      }
    }
  }
}