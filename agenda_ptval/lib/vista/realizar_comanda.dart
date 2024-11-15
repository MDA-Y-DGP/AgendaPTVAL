import 'package:flutter/material.dart';
import '../controlador/comanda_controller.dart';

class RealizarComanda extends StatefulWidget {
  @override
  _RealizarComandaState createState() => _RealizarComandaState();
}

class _RealizarComandaState extends State<RealizarComanda> {
  final ComandaController _controller = ComandaController();

  @override
  void initState() {
    super.initState();
    _controller.obtenerClases(() {
      setState(() {});
    });
    _controller.obtenerMenus(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Realizar Comanda'),
      ),
      body: _controller.clases.isEmpty || _controller.tiposMenu.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildNavigationButtons(),
                Expanded(
                  child: PageView.builder(
                    controller: _controller.pageController,
                    itemCount: _controller.clases.length,
                    onPageChanged: (index) {
                      setState(() {
                        _controller.paginaActual = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      String clase = _controller.clases[index];
                      return Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildClassTitle(clase),
                            SizedBox(height: 10),
                            _buildMenuItems(clase),
                            SizedBox(height: 10),
                            _buildNotes(clase),
                            _buildAddNoteField(),
                            SizedBox(height: 10),
                            _buildAddNoteButton(clase),
                            if (_controller.paginaActual ==
                                _controller.clases.length - 1)
                              _buildConfirmButton(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, size: 60),
          onPressed: _controller.paginaActual > 0
              ? () {
                  setState(() {
                    _controller.cambiarPagina(_controller.paginaActual - 1);
                  });
                }
              : null,
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward, size: 60),
          onPressed: _controller.paginaActual < _controller.clases.length - 1
              ? () {
                  setState(() {
                    _controller.cambiarPagina(_controller.paginaActual + 1);
                  });
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildClassTitle(String clase) {
    return Text(
      clase,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMenuItems(String clase) {
    return Column(
      children: _controller.tiposMenu.map((tipoMenu) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tipoMenu),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, size: 30),
                    onPressed: () {
                      setState(() {
                        _controller.decrementarCantidad(clase, tipoMenu);
                      });
                    },
                  ),
                  Text(
                    _controller.comandas[clase]![tipoMenu].toString(),
                    style: TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: 30),
                    onPressed: () {
                      setState(() {
                        _controller.incrementarCantidad(clase, tipoMenu);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotes(String clase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _controller.notas[clase]!.map((nota) {
        int index = _controller.notas[clase]!.indexOf(nota) + 1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Nota $index:'),
              subtitle: Text(nota),
            ),
            Divider(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAddNoteField() {
    return TextField(
      controller: _controller.notaController,
      decoration: InputDecoration(
        labelText: 'Añadir nota',
        hintText: 'Escribe una nota',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {
          _controller.notaActual = value;
        });
      },
    );
  }

  Widget _buildAddNoteButton(String clase) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _controller.agregarNota(clase);
        });
      },
      child: Text('Agregar Nota'),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: _controller.confirmarComanda,
        child: Text('Confirmar Comanda'),
      ),
    );
  }
}