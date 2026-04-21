import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa la conexión con Google al arrancar [cite: 585]
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    home: AppInmobiliariaCloud(),
  ));
}

class AppInmobiliariaCloud extends StatefulWidget {
  @override
  _AppInmobiliariaCloudState createState() => _AppInmobiliariaCloudState();
}

class _AppInmobiliariaCloudState extends State<AppInmobiliariaCloud> {
  int _idx = 0;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final paginas = [
      _resumen(), 
      _moduloServicio("LUZ ⚡", Colors.amber[800]!), 
      _moduloServicio("AGUA 💧", Colors.blue), 
      _moduloSeguridad(),
      _moduloGastos(), 
      _moduloInquilinos()
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(child: paginas[_idx]),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Caja'),
          NavigationDestination(icon: Icon(Icons.bolt), label: 'Luz'),
          NavigationDestination(icon: Icon(Icons.water_drop), label: 'Agua'),
          NavigationDestination(icon: Icon(Icons.shield), label: 'Segu.'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Gastos'),
          NavigationDestination(icon: Icon(Icons.badge), label: 'Inq.'),
        ],
      ),
    );
  }

  // Resumen que suma los datos directamente desde la nube [cite: 512, 587]
  Widget _resumen() {
    return StreamBuilder(
      stream: _db.collection('inquilinos').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapInq) {
        return StreamBuilder(
          stream: _db.collection('gastos').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapGas) {
            double r = 0; double g = 0;
            if (snapInq.hasData) r = snapInq.data!.docs.fold(0, (s, d) => s + (d['renta'] ?? 0));
            if (snapGas.hasData) g = snapGas.data!.docs.fold(0, (s, d) => s + (d['monto'] ?? 0));
            return Padding(
              padding: EdgeInsets.all(20),
              child: Column(children: [
                Text("MI CAJA EN LA NUBE", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                _card("GANANCIA NETA", "S/ ${(r - g).toStringAsFixed(2)}", Colors.blue, true),
                _card("INGRESOS", "S/ $r", Colors.green, false),
                _card("GASTOS", "S/ $g", Colors.red, false),
              ]),
            );
          },
        );
      },
    );
  }

  // Lista de inquilinos sincronizada con Firebase [cite: 563, 585]
  Widget _moduloInquilinos() {
    return Column(children: [
      Padding(
        padding: EdgeInsets.all(20),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("INQUILINOS", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          IconButton.filled(onPressed: _addInquilino, icon: Icon(Icons.person_add)),
        ]),
      ),
      Expanded(
        child: StreamBuilder(
          stream: _db.collection('inquilinos').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
            if (!snap.hasData) return Center(child: CircularProgressIndicator());
            return ListView(
              children: snap.data!.docs.map((d) => Card(
                child: ListTile(
                  title: Text(d['nombre'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  subtitle: Text("Dpto: ${d['depto']} | DNI: ${d['dni']}"),
                  trailing: Text("S/ ${d['renta']}", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              )).toList(),
            );
          },
        ),
      ),
    ]);
  }

  // Función para guardar inquilinos en la nube [cite: 563, 585]
  _addInquilino() {
    final c1 = TextEditingController(); final c2 = TextEditingController(); 
    final c3 = TextEditingController(); final c4 = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("Nuevo Inquilino"),
      content: SingleChildScrollView(child: Column(children: [
        _in("Nombre", c1, false), _in("DNI / CE", c2, false), 
        _in("Dpto", c3, false), _in("Renta S/", c4, true),
      ])),
      actions: [TextButton(onPressed: () {
        _db.collection('inquilinos').add({
          'nombre': c1.text, 'dni': c2.text, 'depto': c3.text, 
          'renta': double.parse(c4.text)
        });
        Navigator.pop(context);
      }, child: Text("GUARDAR"))],
    ));
  }

  Widget _card(String t, String v, Color c, bool b) => Container(
    width: double.infinity, margin: EdgeInsets.only(top: 15), padding: EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
    child: Column(children: [Text(t), Text(v, style: TextStyle(fontSize: b?40:25, fontWeight: FontWeight.bold, color: c))]),
  );

  Widget _in(String l, TextEditingController c, bool n) => TextField(controller: c, decoration: InputDecoration(labelText: l), keyboardType: n ? TextInputType.number : TextInputType.text);

  Widget _moduloServicio(String t, Color c) => Center(child: Text("Calculadora de $t"));
  Widget _moduloSeguridad() => Center(child: Text("Módulo Seguridad"));
  Widget _moduloGastos() => Center(child: Text("Módulo Gastos"));
}