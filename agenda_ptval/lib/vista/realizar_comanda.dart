import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RealizarComanda extends StatefulWidget {
  @override
  _RealizarComandaState createState() => _RealizarComandaState();
}

class _RealizarComandaState extends State<RealizarComanda> {
  final Map<String, Map<String, int>> _comandas = {};
  final Map<String, List<String>> _notas = {};
  List<String> _clases = [];
  List<String> _tiposMenu = [];
  String _notaActual = '';
  final PageController _pageController = PageController();
  int _paginaActual = 0;
  final TextEditingController _notaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _obtenerClases();
    _obtenerMenus();
  }

  Future<void> _obtenerClases() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('clases').get();
      List<String> clases =
          snapshot.docs.map((doc) => doc['nombre'] as String).toList();
      setState(() {
        _clases = clases;
        for (var clase in _clases) {
          _comandas[clase] = {};
          for (var tipoMenu in _tiposMenu) {
            _comandas[clase]![tipoMenu] = 0;
          }
          _notas[clase] = [];
        }
      });
    } catch (e) {
      print('Error al obtener clases: $e');
    }
  }

  Future<void> _obtenerMenus() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('menus').get();
      List<String> menus =
          snapshot.docs.map((doc) => doc['nombre'] as String).toList();
      setState(() {
        _tiposMenu = menus;
        for (var clase in _clases) {
          for (var tipoMenu in _tiposMenu) {
            _comandas[clase]![tipoMenu] = 0;
          }
        }
      });
    } catch (e) {
      print('Error al obtener menús: $e');
    }
  }

  void _incrementarCantidad(String clase, String tipoMenu) {
    setState(() {
      _comandas[clase]![tipoMenu] = _comandas[clase]![tipoMenu]! + 1;
    });
  }

  void _decrementarCantidad(String clase, String tipoMenu) {
    setState(() {
      if (_comandas[clase]![tipoMenu]! > 0) {
        _comandas[clase]![tipoMenu] = _comandas[clase]![tipoMenu]! - 1;
      }
    });
  }

  void _agregarNota(String clase) {
    if (_notaActual.isNotEmpty) {
      setState(() {
        _notas[clase]!.add(_notaActual);
        _notaActual = '';
        _notaController.clear();
      });
    }
  }

  void _confirmarComanda() {
    // Aquí puedes agregar la lógica para confirmar la comanda
    print('Comanda confirmada: $_comandas');
    print('Notas: $_notas');
  }

  void _cambiarPagina(int index) {
    setState(() {
      _paginaActual = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Realizar Comanda'),
      ),
      body: Stack(
        children: [
          _clases.isEmpty || _tiposMenu.isEmpty
              ? Center(child: CircularProgressIndicator())
              : PageView.builder(
                  controller: _pageController,
                  itemCount: _clases.length,
                  onPageChanged: (index) {
                    setState(() {
                      _paginaActual = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    String clase = _clases[index];
                    return Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clase,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          ..._tiposMenu.map((tipoMenu) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(tipoMenu),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove, size: 30),
                                        onPressed: () => _decrementarCantidad(
                                            clase, tipoMenu),
                                      ),
                                      Text(
                                        _comandas[clase]![tipoMenu].toString(),
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add, size: 30),
                                        onPressed: () => _incrementarCantidad(
                                            clase, tipoMenu),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          SizedBox(height: 10),
                          ..._notas[clase]!.map((nota) {
                            int index = _notas[clase]!.indexOf(nota) + 1;
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
                          TextField(
                            controller: _notaController,
                            decoration: InputDecoration(
                              labelText: 'Añadir nota',
                              hintText: 'Escribe una nota',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _notaActual = value;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _agregarNota(clase),
                            child: Text('Agregar Nota'),
                          ),
                          if (_paginaActual == _clases.length - 1)
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: ElevatedButton(
                                onPressed: _confirmarComanda,
                                child: Text('Confirmar Comanda'),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
          Positioned(
            left: 10,
            top: _paginaActual == _clases.length - 1
                ? MediaQuery.of(context).size.height / 2 + 40
                : MediaQuery.of(context).size.height / 2 - 40,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 60),
              onPressed: _paginaActual > 0
                  ? () => _cambiarPagina(_paginaActual - 1)
                  : null,
            ),
          ),
          Positioned(
            right: 10,
            top: _paginaActual == _clases.length - 1
                ? MediaQuery.of(context).size.height / 2 + 40
                : MediaQuery.of(context).size.height / 2 - 40,
            child: IconButton(
              icon: Icon(Icons.arrow_forward, size: 60),
              onPressed: _paginaActual < _clases.length - 1
                  ? () => _cambiarPagina(_paginaActual + 1)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
