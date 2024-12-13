import 'package:flutter/material.dart';
import '../controlador/comanda_controller.dart';
import '../controlador/imagen_controller.dart';

class RealizarComanda extends StatefulWidget {
  @override
  _RealizarComandaState createState() => _RealizarComandaState();
}

class _RealizarComandaState extends State<RealizarComanda> {
  final ComandaController _controller = ComandaController();
  final ImagenController _imageController = ImagenController();

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
                            _buildNotaField(clase),
                            _buildAgregarNotaButton(clase),
                            _buildNota(clase),
                            if (_controller.paginaActual == _controller.clases.length - 1)
                              _buildConfirmButton(),
                            SizedBox(height: 20), // Añadir separación antes de las flechas
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
              icon: Icon(Icons.arrow_back, size: 60), // Aumentar tamaño de la flecha
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
              icon: Icon(Icons.arrow_forward, size: 60), // Aumentar tamaño de la flecha
              onPressed: _controller.paginaActual < _controller.clases.length - 1
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
    PageController _pageController = PageController();
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, size: 30),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 200, // Adjust height as needed
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _controller.tiposMenu.length,
                        itemBuilder: (context, index) {
                          String tipoMenu = _controller.tiposMenu[index];
                          return FutureBuilder<String>(
                            future: _imageController.obtenerFotoMenu(tipoMenu),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError || !snapshot.hasData) {
                                return Column(
                                  children: [
                                    SizedBox(height: 100), // Empty space when no image
                                    Text(
                                      tipoMenu,
                                      style: TextStyle(fontWeight: FontWeight.normal),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                                );
                              } else {
                                return Column(
                                  children: [
                                    Image.network(
                                      snapshot.data!,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    Text(
                                      tipoMenu,
                                      style: TextStyle(fontWeight: FontWeight.normal),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, size: 30),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotaField(String clase) {
    return _controller.nota == null
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Añadir nota',
                border: OutlineInputBorder(),
              ),
              child: TextField(
                controller: _controller.notaController,
                decoration: InputDecoration(
                  hintText: 'Escribe una nota',
                  border: InputBorder.none,
                ),
              ),
            ),
          )
        : Container();
  }

  Widget _buildAgregarNotaButton(String clase) {
    return _controller.nota == null
        ? ElevatedButton(
            onPressed: () {
              setState(() {
                if (_controller.nota == null) {
                  _controller.agregarNota(_controller.notaController.text);
                }
              });
            },
            child: Text('Agregar Nota'),
          )
        : Container();
  }

  Widget _buildNota(String clase) {
    return _controller.nota != null
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Nota',
                border: OutlineInputBorder(),
              ),
              child: Text(_controller.nota!),
            ),
          )
        : Container();
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