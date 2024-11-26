import 'package:flutter/material.dart';
import '../controlador/estudiante_controller.dart';
import 'realizar_comanda.dart'; // Importa la página de realizar comanda
import 'realizar_tarea_inventario.dart'; // Importa la página de realizar tarea de inventario

class PaginaPrincipalEstudiante extends StatefulWidget {
  final String nickname;

  const PaginaPrincipalEstudiante({super.key, required this.nickname});

  @override
  _PaginaPrincipalEstudianteState createState() => _PaginaPrincipalEstudianteState();
}

class _PaginaPrincipalEstudianteState extends State<PaginaPrincipalEstudiante> {
  final List<Map<String, dynamic>> _tareas = [
    {'nombre': 'Tarea 1', 'completada': false},
    {'nombre': 'Tarea 2', 'completada': false},
    {'nombre': 'Tarea 3', 'completada': false},
  ];

  List<Map<String, dynamic>> _tareasBD = [];

  @override
  void initState() {
    super.initState();
    _loadTareas();
  }

  Future<void> _loadTareas() async {
    final tareas = await EstudianteController().obtenerTareasPorNickname(widget.nickname);
    setState(() {
      _tareasBD = tareas;
    });
  }

  void _navegarARealizarComanda() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RealizarComanda()),
    );
  }

  void _navegarARealizarTareaInventario() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RealizarTareaInventario()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Principal'),
      ),
      body: Column(
        children: [
          Center(
            child: Text(
              'Bienvenido, ${widget.nickname}',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tareas.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(_tareas[index]['nombre']),
                  value: _tareas[index]['completada'],
                  onChanged: (bool? value) {
                    setState(() {
                      _tareas[index]['completada'] = value!;
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tareasBD.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(_tareasBD[index]['nombre']),
                  value: _tareasBD[index]['completada'],
                  onChanged: (bool? value) async {
                    setState(() {
                      _tareasBD[index]['completada'] = value!;
                    });
                    // Aquí puedes agregar la lógica para actualizar la tarea en la base de datos
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _navegarARealizarComanda,
              child: Text('Realizar Comanda'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _navegarARealizarTareaInventario,
              child: Text('Realizar Tarea Inventario'),
            ),
          )
        ],
      ),
    );
  }
}