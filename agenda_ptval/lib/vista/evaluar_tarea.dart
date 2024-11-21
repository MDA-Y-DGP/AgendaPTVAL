import 'package:flutter/material.dart';
import '../controlador/tarea_controller.dart';
import '../controlador/estudiante_controller.dart';
import '../controlador/clase_controller.dart';
import '../modelo/clase_modelo.dart';
import '../modelo/estudiante_modelo.dart';
import '../modelo/tarea_modelo.dart';

class EvaluarTarea extends StatefulWidget {
  @override
  _EvaluarTareaState createState() => _EvaluarTareaState();
}

class _EvaluarTareaState extends State<EvaluarTarea> {
  final ClaseController _claseController = ClaseController();
  final EstudianteController _estudianteController = EstudianteController();
  final TareaController _tareaController = TareaController();

  String? _selectedClase;
  String? _selectedEstudiante;
  int? _selectedTarea;
  List<Estudiante> _estudiantes = [];
  List<Tarea> _tareas = [];
  bool _isLoading = false;

  final TextEditingController _evaluacionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluar Tarea'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildClasesDropdown(),
            const SizedBox(height: 20),
            if (_selectedClase != null) _buildEstudiantesDropdown(),
            const SizedBox(height: 20),
            if (_selectedEstudiante != null) _buildTareasDropdown(),
            const SizedBox(height: 20),
            if (_selectedTarea != null) _buildEvaluacionForm(),
          ],
        ),
      ),
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
                _selectedTarea = null;
                _estudiantes = [];
                _tareas = [];
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
          _selectedTarea = null;
          _fetchTareasPorEstudiante(newValue!);
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

  Widget _buildTareasDropdown() {
    return _tareas.isEmpty
        ? Center(child: Text('No hay tareas asignadas'))
        : DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: 'Selecciona una tarea',
        border: OutlineInputBorder(),
      ),
      value: _selectedTarea,
      onChanged: (int? newValue) {
        setState(() {
          _selectedTarea = newValue;
        });
      },
      items: _tareas.map((Tarea tarea) {
        return DropdownMenuItem<int>(
          value: tarea.idTarea,
          child: Text(tarea.titulo),
        );
      }).toList(),
    );
  }

  Widget _buildEvaluacionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _evaluacionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Escribe la evaluación',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _evaluacionController.text.isEmpty
              ? null
              : _evaluarTareaSeleccionada,
          child: Text('Confirmar Evaluación'),
        ),
      ],
    );
  }

  void _fetchEstudiantesPorClase(String claseId) async {
    setState(() {
      _isLoading = true;
    });
    List<Estudiante> estudiantes =
    await _estudianteController.obtenerEstudiantesPorClase(claseId);
    setState(() {
      _estudiantes = estudiantes;
      _isLoading = false;
    });
  }

  void _fetchTareasPorEstudiante(String estudianteId) async {
    setState(() {
      _isLoading = true;
    });
    List<Tarea> tareas = await _tareaController.obtenerTareasPorEstudiante(estudianteId);
    setState(() {
      _tareas = tareas;
      _isLoading = false;
    });
  }

  void _evaluarTareaSeleccionada() async {
    if (_selectedTarea != null && _evaluacionController.text.isNotEmpty) {
      try {
        await _tareaController.evaluarTarea(
          _selectedTarea!,
          _evaluacionController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarea evaluada correctamente')),
        );
        setState(() {
          _evaluacionController.clear();
          _selectedTarea = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al evaluar la tarea: $e')),
        );
      }
    }
  }
}
