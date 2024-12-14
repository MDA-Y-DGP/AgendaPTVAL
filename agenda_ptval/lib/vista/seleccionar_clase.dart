import 'package:flutter/material.dart';
import 'package:agenda_ptval/controlador/clase_controller.dart';
import 'package:agenda_ptval/controlador/imagen_controller.dart';
import 'package:agenda_ptval/modelo/clase_modelo.dart';
import 'package:agenda_ptval/vista/realizar_comanda.dart'; // Importar la vista de realizar comanda

class SeleccionarClasePage extends StatefulWidget {
  @override
  _SeleccionarClasePageState createState() => _SeleccionarClasePageState();
}

class _SeleccionarClasePageState extends State<SeleccionarClasePage> {
  final ClaseController _controller = ClaseController();
  final ImagenController _imagenController = ImagenController();
  List<Clase> clases = [];

  @override
  void initState() {
    super.initState();
    _cargarClases();
  }

  Future<void> _cargarClases() async {
    try {
      List<Clase> lista = await _controller.obtenerClases();
      setState(() {
        clases = lista;
      });
    } catch (e) {
      // Manejo de errores
    }
  }

  Future<String?> _obtenerImagenClase(String nombreClase) async {
    return await _imagenController.obtenerImagenClase(nombreClase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Clase'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: clases.isEmpty
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150, // Tamaño máximo de cada cuadrado
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1, // Relación de aspecto 1:1 para cuadrados
                ),
                itemCount: clases.length,
                itemBuilder: (context, index) {
                  final clase = clases[index];
                  return FutureBuilder<String?>(
                    future: _obtenerImagenClase(clase.nombre),
                    builder: (context, snapshot) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RealizarComanda(nombreClase: clase.nombre),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 16), // Añade espacio arriba
                              if (snapshot.connectionState == ConnectionState.waiting)
                                Center(child: CircularProgressIndicator())
                              else if (snapshot.hasError || !snapshot.hasData)
                                Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                    color: Colors.grey[200],
                                  ),
                                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                )
                              else
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                  child: Image.network(snapshot.data!, width: 60, height: 60, fit: BoxFit.contain), // Ajusta el tamaño de la imagen
                                ),
                              SizedBox(height: 16), // Añade espacio entre la imagen y el texto
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  clase.nombre,
                                  style: TextStyle(
                                    fontSize: 14, // Ajusta el tamaño del texto
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // Color del texto
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}