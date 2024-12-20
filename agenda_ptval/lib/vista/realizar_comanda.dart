import 'package:flutter/material.dart';
import '../controlador/comanda_controller.dart';
import '../controlador/imagen_controller.dart';
import 'seleccionar_clase.dart'; // Asegúrate de importar la página de selección de clase

class RealizarComanda extends StatefulWidget {
  final String nombreClase;

  RealizarComanda({required this.nombreClase});

  @override
  _RealizarComandaState createState() => _RealizarComandaState();
}

class _RealizarComandaState extends State<RealizarComanda> {
  final ComandaController _controller = ComandaController();
  final ImagenController _imageController = ImagenController();
  late String nombreClase;

  @override
  void initState() {
    super.initState();
    nombreClase = widget.nombreClase;
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
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _controller.clases.isEmpty || _controller.tiposMenu.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SeleccionarClasePage(),
                            ),
                          ).then((selectedClass) {
                            if (selectedClass != null) {
                              setState(() {
                                nombreClase = selectedClass;
                              });
                            }
                          });
                        },
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Center(child: _buildClassInfo(nombreClase)),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 200,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _buildMenuItems(nombreClase),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 200,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _buildNotaField(nombreClase),
                        ),
                      ),
                      if (_controller.nota == null) ...[
                        SizedBox(width: 10),
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Center(child: _buildAgregarNotaButton(nombreClase)),
                        ),
                      ],
                    ],
                  ),
                                                                                      SizedBox(height: 10),
                                                                                      Center(
                                                                                        child: ElevatedButton(
                                                                                          style: ElevatedButton.styleFrom(
                                                                                            backgroundColor: Colors.orangeAccent, // Fondo del botón
                                                                                            foregroundColor: Colors.white, // Color del texto
                                                                                            shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius.circular(10),
                                                                                            ),
                                                                                            padding: EdgeInsets.all(10),
                                                                                            minimumSize: Size(200, 200), // Tamaño mínimo del botón
                                                                                          ),
                                                                                          onPressed: () async {
                                                                                            try {
                                                                                              await _controller.confirmarComandaPorClase(nombreClase);
                                                                                              Navigator.pushReplacement(
                                                                                                context,
                                                                                                MaterialPageRoute(
                                                                                                  builder: (context) => SeleccionarClasePage(),
                                                                                                ),
                                                                                              );
                                                                                            } catch (e) {
                                                                                              print('Error al confirmar comanda: $e');
                                                                                            }
                                                                                          },
                                                                                          child: Column(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              Image.asset(
                                                                                                'assets/pictograma_completado.png',
                                                                                                height: 100,
                                                                                                fit: BoxFit.cover,
                                                                                              ),
                                                                                              SizedBox(height: 10),
                                                                                              Text(
                                                                                                'Confirmar Comanda',
                                                                                                style: TextStyle(
                                                                                                  color: Colors.white,
                                                                                                  fontSize: 16,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),                                                                                      
                ],
              ),
            ),
    );
  }
  
  
  Widget _buildClassInfo(String clase) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildClassImage(),
        SizedBox(height: 10),
        Text(
          clase,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  Widget _buildClassImage() {
    return FutureBuilder<String?>(
      future: _imageController.obtenerImagenClase(nombreClase),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            height: 100,
            color: Colors.grey[200],
            child: Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
          );
        } else {
          return Image.network(snapshot.data!, height: 100, fit: BoxFit.cover);
        }
      },
    );
  }

  Widget _buildMenuItems(String clase) {
    PageController _pageController = PageController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left, size: 30, color: Colors.white),
              onPressed: () {
                _pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            Expanded(
              child: SizedBox(
                height: 150, // Adjust height as needed
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
                          return _buildMenuItem(clase, tipoMenu, null);
                        } else {
                          return _buildMenuItem(clase, tipoMenu, snapshot.data);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_right, size: 30, color: Colors.white),
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
    );
  }

  Widget _buildMenuItem(String clase, String tipoMenu, String? imageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageUrl == null)
              Container(
                height: 100,
                color: Colors.grey[200],
                child: Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
              )
            else
              Image.network(
                imageUrl,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                  );
                },
              ),
            Text(
              tipoMenu,
              style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
            ),
          ],
        ),
        SizedBox(width: 10),
        MenuItemQuantity(
          clase: clase,
          tipoMenu: tipoMenu,
          controller: _controller,
        ),
      ],
    );
  }

  Widget _buildNotaField(String clase) {
    return _controller.nota == null
        ? Container(
            height: double.infinity,
            child: TextField(
              controller: _controller.notaController,
              maxLines: null,
              expands: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribe una nota',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: Colors.blueAccent,
              ),
            ),
          )
        : Container(
            height: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Nota: ${_controller.nota}',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          );
  }

  Widget _buildAgregarNotaButton(String clase) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_controller.nota == null) {
            _controller.agregarNota(_controller.notaController.text);
          }
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/pictograma_notas.png',
            height: 100,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 10),
          Text(
            'Añadir Nota',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

        Widget _buildConfirmButton(String clase) {
      return InkWell(
        onTap: () async {
          await _controller.confirmarComandaPorClase(clase);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Comanda confirmada para la clase $clase'),
            ),
          );
          Navigator.pop(context);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/pictograma_completado.png',
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text(
              'Confirmar Comanda',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
}

class MenuItemQuantity extends StatefulWidget {
  final String clase;
  final String tipoMenu;
  final ComandaController controller;

  MenuItemQuantity({
    required this.clase,
    required this.tipoMenu,
    required this.controller,
  });

  @override
  _MenuItemQuantityState createState() => _MenuItemQuantityState();
}

class _MenuItemQuantityState extends State<MenuItemQuantity> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.add, size: 30, color: Colors.white),
          onPressed: () {
            setState(() {
              widget.controller.incrementarCantidad(widget.clase, widget.tipoMenu);
            });
          },
        ),
        Text(
          widget.controller.comandas[widget.clase]![widget.tipoMenu].toString(),
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        IconButton(
          icon: Icon(Icons.remove, size: 30, color: Colors.white),
          onPressed: () {
            setState(() {
              widget.controller.decrementarCantidad(widget.clase, widget.tipoMenu);
            });
          },
        ),
      ],
    );
  }
}