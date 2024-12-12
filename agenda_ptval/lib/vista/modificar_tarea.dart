import 'package:flutter/material.dart';
import 'package:agenda_ptval/controlador/tarea_controller.dart';
import 'package:agenda_ptval/modelo/tarea_modelo.dart';

class ModificarTarea extends StatefulWidget {
  final Tarea tarea;

  ModificarTarea({required this.tarea});

  @override
  _ModificarTareaState createState() => _ModificarTareaState();
}

class _ModificarTareaState extends State<ModificarTarea> {
  final _formKey = GlobalKey<FormState>();
  final TareaController _tareaController = TareaController();

  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late String _tipo;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.tarea.titulo);
    _descripcionController = TextEditingController(text: widget.tarea.descripcion);
    _tipo = widget.tarea.tipo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar Tarea'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(_tituloController, 'Título', 'Por favor ingresa un título'),
                const SizedBox(height: 16),
                _buildTextField(_descripcionController, 'Descripción', 'Por favor ingresa una descripción'),
                const SizedBox(height: 16),
                _buildDropdownButtonFormField(),
                const SizedBox(height: 16),
                _buildModificarTareaButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, String validationMessage) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  Widget _buildDropdownButtonFormField() {
    return DropdownButtonFormField<String>(
      value: _tipo,
      decoration: const InputDecoration(
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
    );
  }

  Widget _buildModificarTareaButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          Tarea tareaModificada = Tarea(
            idTarea: widget.tarea.idTarea,
            titulo: _tituloController.text,
            descripcion: _descripcionController.text,
            tipo: _tipo,
            pasos: widget.tarea.pasos,
          );

          await _tareaController.modificarTarea(tareaModificada);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarea modificada correctamente')),
          );
          Navigator.pop(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      child: const Text('Modificar Tarea', style: TextStyle(color: Colors.white)),
    );
  }
}
