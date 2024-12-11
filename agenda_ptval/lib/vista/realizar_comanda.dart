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
                            SizedBox(
                                height:
                                    20), // Añadir separación antes de las flechas
                          ],
                        ),
                      );
                    },
                  ),
                ),
                _buildNavigationButtons(), // Mover los botones de navegación aquí
              ],
            ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back,
                  size: 60), // Aumentar tamaño de la flecha
              onPressed: _controller.paginaActual > 0
                  ? () {
                      setState(() {
                        _controller.paginaActual--;
                        _controller.pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      });
                    }
                  : null,
            ),
            Text('clase anterior'),
          ],
        ),
        Row(
          children: [
            Text('siguiente clase'),
            IconButton(
              icon: Icon(Icons.arrow_forward,
                  size: 60), // Aumentar tamaño de la flecha
              onPressed:
                  _controller.paginaActual < _controller.clases.length - 1
                      ? () {
                          setState(() {
                            _controller.paginaActual++;
                            _controller.pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          });
                        }
                      : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassTitle(String clase) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Clase',
        border: OutlineInputBorder(),
      ),
      child: Text(clase),
    );
  }

  Widget _buildMenuItems(String clase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Lista de menús',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(8.0),
          ),
          child: Column(
            children: _controller.tiposMenu.map((tipoMenu) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tipoMenu,
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
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
          ),
        ),
      ],
    );
  }

    Widget _buildNotes(String clase) {
    if (_controller.notas[clase] == null || _controller.notas[clase]!.isEmpty) {
      return SizedBox.shrink();
    }
  
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Lista de notas',
            border: OutlineInputBorder(),
          ),
          child: Container(
            height: 70, // Ajusta la altura según sea necesario
            child: ListView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(), // Permitir desplazamiento
              itemCount: _controller.notas[clase]!.length,
              itemBuilder: (context, index) {
                String nota = _controller.notas[clase]![index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Nota ${index + 1}: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: nota,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          ),
        ),
        SizedBox(height: 10), // Añadir separación
      ],
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
