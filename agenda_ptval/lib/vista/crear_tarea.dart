import 'package:flutter/material.dart';
import 'package:agenda_ptval/controlador/tarea_controller.dart';
import 'package:agenda_ptval/controlador/paso_controller.dart';
import 'package:agenda_ptval/modelo/tarea_modelo.dart';
import 'package:agenda_ptval/modelo/paso_modelo.dart';

class CrearTarea extends StatefulWidget {
  @override
  _CrearTareaState createState() => _CrearTareaState();
}

class _CrearTareaState extends State<CrearTarea> {
  final _formKey = GlobalKey<FormState>();
  final TareaController _tareaController = TareaController();
  final PasoController _pasoController = PasoController();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String _tipo = 'comedor'; // Valor predeterminado

  List<Paso> _pasos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: InputDecoration(
                  labelText: 'Tipo de Tarea',
                  border: OutlineInputBorder(),
                ),
                items: ['comedor', 'por pasos', 'inventario'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tipo = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_tipo == 'por pasos') ...[
                ElevatedButton(
                  onPressed: () {
                    _mostrarDialogoAgregarPaso(context);
                  },
                  child: const Text('Agregar Paso'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _pasos.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_pasos[index].texto),
                        subtitle: _pasos[index].urlMedia != null
                            ? Text('Media: ${_pasos[index].urlMedia}')
                            : null,
                      );
                    },
                  ),
                ),
              ],
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Tarea nuevaTarea = Tarea(
                      idTarea: 0, // Este valor se actualizará en el controlador
                      titulo: _tituloController.text,
                      descripcion: _descripcionController.text,
                      tipo: _tipo,
                    );
                    int idTareaPorPasos = await _tareaController.crearTarea(nuevaTarea);

                    if (_tipo == 'por pasos') {
                      for (var paso in _pasos) {
                        paso = Paso(
                          idPaso: paso.idPaso,
                          idTareaPorPasos: idTareaPorPasos,
                          texto: paso.texto,
                          urlMedia: paso.urlMedia,
                        );
                        await _pasoController.crearPaso(paso);
                      }
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tarea creada correctamente')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Crear Tarea'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoAgregarPaso(BuildContext context) {
    final TextEditingController _textoPasoController = TextEditingController();
    final TextEditingController _urlMediaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Paso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _textoPasoController,
                decoration: InputDecoration(
                  labelText: 'Texto del Paso',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un texto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlMediaController,
                decoration: InputDecoration(
                  labelText: 'URL de Media (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_textoPasoController.text.isNotEmpty) {
                  setState(() {
                    _pasos.add(Paso(
                      idPaso: 0, // Este valor se actualizará en el controlador
                      idTareaPorPasos: 0, // Este valor se actualizará en el controlador
                      texto: _textoPasoController.text,
                      urlMedia: _urlMediaController.text.isNotEmpty
                          ? _urlMediaController.text
                          : null,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Agregar Paso'),
            ),
          ],
        );
      },
    );
  }
}