import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
  home: AppInmobiliariaMaster(),
));

class AppInmobiliariaMaster extends StatefulWidget {
  @override
  _AppInmobiliariaMasterState createState() => _AppInmobiliariaMasterState();
}

class _AppInmobiliariaMasterState extends State<AppInmobiliariaMaster> {
  int _idx = 0;
  List inquilinos = [];
  List gastos = [];

  @override
  void initState() { super.initState(); _cargar(); }

  _cargar() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      inquilinos = json.decode(p.getString('inq_v5') ?? '[]');
      gastos = json.decode(p.getString('gas_v5') ?? '[]');
    });
  }

  _guardar() async {
    final p = await SharedPreferences.getInstance();
    p.setString('inq_v5', json.encode(inquilinos));
    p.setString('gas_v5', json.encode(gastos));
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      _resumen(), 
      _moduloCalculadoraServicio("LUZ ⚡", Colors.amber[800]!), 
      _moduloCalculadoraServicio("AGUA 💧", Colors.blue), 
      _moduloSeguridad(),
      _moduloGastos(), 
      _moduloInquilinos()
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      body: SafeArea(child: paginas[_idx]),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Caja'),
          NavigationDestination(icon: Icon(Icons.bolt), label: 'Luz'),
          NavigationDestination(icon: Icon(Icons.water_drop), label: 'Agua'),
          NavigationDestination(icon: Icon(Icons.shield), label: 'Segu.'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Gastos'),
          NavigationDestination(icon: Icon(Icons.badge), label: 'Inq.'),
        ],
      ),
    );
  }

  // --- 1. RESUMEN ---
  Widget _resumen() {
    double r = inquilinos.fold(0, (s, i) => s + (i['renta'] ?? 0));
    double g = gastos.fold(0, (s, i) => s + (i['monto'] ?? 0));
    return Padding(
      padding: EdgeInsets.all(20),
      child: ListView(children: [
        Center(child: Text("CONTROL DE PROPIEDADES", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.blueGrey[800]))),
        _card("SALDO NETO", "S/ ${(r - g).toStringAsFixed(2)}", Colors.blue, true),
        _card("RENTAS TOTALES", "S/ $r", Colors.green, false),
        _card("GASTOS MENSUALES", "S/ $g", Colors.red, false),
      ]),
    );
  }

  // --- 2. CALCULADORAS ASOCIADAS ---
  Widget _moduloCalculadoraServicio(String tipo, Color color) {
    if (inquilinos.isEmpty) return _errorNoInquilinos();
    return _CalculadoraConInquilino(titulo: tipo, color: color, inquilinos: inquilinos);
  }

  Widget _moduloSeguridad() {
    if (inquilinos.isEmpty) return _errorNoInquilinos();
    return _CalculadoraSeguridad(inquilinos: inquilinos);
  }

  // --- 3. GASTOS ---
  Widget _moduloGastos() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("GASTOS", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          IconButton.filled(onPressed: _addGasto, icon: Icon(Icons.add, size: 30)),
        ]),
        Expanded(child: ListView.builder(itemCount: gastos.length, itemBuilder: (context, i) => _itemGasto(gastos[i]))),
      ]),
    );
  }

  // --- 4. INQUILINOS (EL MÓDULO NUEVO PRO) ---
  Widget _moduloInquilinos() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("MIS INQUILINOS", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          IconButton.filled(onPressed: _addInquilino, icon: Icon(Icons.person_add, size: 30)),
        ]),
        Expanded(child: ListView.builder(itemCount: inquilinos.length, itemBuilder: (context, i) => _itemInquilino(inquilinos[i]))),
      ]),
    );
  }

  // --- WIDGETS DE LISTA ---
  Widget _itemGasto(dynamic g) => Card(
    margin: EdgeInsets.only(top: 10),
    color: Colors.white,
    child: ListTile(
      title: Text(g['titulo'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      subtitle: Text("Fecha: ${g['fecha']}"),
      trailing: Text("-S/ ${g['monto']}", style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _itemInquilino(dynamic inq) => Card(
    margin: EdgeInsets.only(top: 10),
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.black12)),
    child: ExpansionTile(
      leading: CircleAvatar(backgroundColor: Colors.blue[50], child: Icon(Icons.person, color: Colors.blue)),
      title: Text(inq['nombre'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      subtitle: Text("Dpto: ${inq['depto']} | Doc: ${inq['dni']}"),
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("📞 Contactos: ${inq['telefonos']}", style: TextStyle(fontSize: 18)),
            Text("🗓️ Ingreso: ${inq['fIngreso']}", style: TextStyle(fontSize: 18)),
            Text("💰 Renta: S/ ${inq['renta']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Row(children: [
              _btnMini("VER CONTRATO", Icons.description, Colors.blueGrey),
              SizedBox(width: 10),
              _btnMini("VER FOTO", Icons.image, Colors.indigo),
            ])
          ]),
        )
      ],
    ),
  );

  Widget _btnMini(String t, IconData i, Color c) => ElevatedButton.icon(
    onPressed: () {}, // Aquí se abriría el archivo
    icon: Icon(i, size: 18), label: Text(t),
    style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white),
  );

  // --- DIÁLOGOS ---
  _addInquilino() {
    final c1 = TextEditingController(); final c2 = TextEditingController(); final c3 = TextEditingController();
    final c4 = TextEditingController(); final c5 = TextEditingController(); final c6 = TextEditingController();
    final c7 = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("Nuevo Registro Maestro"),
      content: SingleChildScrollView(child: Column(children: [
        _in("Nombre Completo", c1, num: false),
        _in("DNI / CE", c6, num: false),
        _in("N° Departamento", c2, num: false),
        _in("Teléfonos (ej: 999..., 988...)", c7, num: false),
        _in("Monto Renta S/", c3),
        _in("Fecha Ingreso", c4, num: false),
        _in("Día que paga", c5, num: false),
        SizedBox(height: 10),
        Text("Archivos: Podrás subirlos al guardar.", style: TextStyle(fontSize: 12, color: Colors.grey)),
      ])),
      actions: [TextButton(onPressed: () {
        setState(() { inquilinos.add({
          'nombre': c1.text, 'depto': c2.text, 'renta': double.parse(c3.text), 
          'fIngreso': c4.text, 'fPago': c5.text, 'dni': c6.text, 'telefonos': c7.text
        }); _guardar(); });
        Navigator.pop(context);
      }, child: Text("REGISTRAR INQUILINO"))],
    ));
  }

  _addGasto() {
    final c1 = TextEditingController(); final c2 = TextEditingController(); final c3 = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("Nuevo Gasto"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _in("Concepto", c1, num: false), _in("Monto S/", c2), _in("Fecha", c3, num: false),
      ]),
      actions: [TextButton(onPressed: () {
        setState(() { gastos.add({'titulo': c1.text, 'monto': double.parse(c2.text), 'fecha': c3.text}); _guardar(); });
        Navigator.pop(context);
      }, child: Text("GUARDAR"))],
    ));
  }

  // --- ESTILOS ---
  Widget _errorNoInquilinos() => Center(child: Text("Registra un inquilino primero", style: TextStyle(fontSize: 20)));
  
  Widget _card(String t, String v, Color c, bool b) => Container(
    width: double.infinity, margin: EdgeInsets.only(top: 15), padding: EdgeInsets.all(25),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
    child: Column(children: [Text(t), Text(v, style: TextStyle(fontSize: b?45:28, fontWeight: FontWeight.bold, color: c))]),
  );

  Widget _in(String l, TextEditingController c, {bool num = true}) => TextField(controller: c, decoration: InputDecoration(labelText: l), style: TextStyle(fontSize: 18), keyboardType: num ? TextInputType.number : TextInputType.text);
}

// --- CALCULADORAS ---
class _CalculadoraConInquilino extends StatefulWidget {
  final String titulo; final Color color; final List inquilinos;
  _CalculadoraConInquilino({required this.titulo, required this.color, required this.inquilinos});
  @override __CalculadoraConInquilinoState createState() => __CalculadoraConInquilinoState();
}

class __CalculadoraConInquilinoState extends State<_CalculadoraConInquilino> {
  String? inq; final cR = TextEditingController(); final cC = TextEditingController();
  final c1 = TextEditingController(); final c2 = TextEditingController(); double res = 0;
  @override Widget build(BuildContext context) {
    return SingleChildScrollView(padding: EdgeInsets.all(25), child: Column(children: [
      Text(widget.titulo, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: widget.color)),
      DropdownButton<String>(isExpanded: true, value: inq, hint: Text("Seleccionar Inquilino"), items: widget.inquilinos.map((i) => DropdownMenuItem<String>(value: i['nombre'], child: Text("${i['nombre']} (Dpto ${i['depto']})"))).toList(), onChanged: (v) => setState(() => inq = v)),
      TextField(controller: cR, decoration: InputDecoration(labelText: "Total Recibo S/")),
      TextField(controller: cC, decoration: InputDecoration(labelText: "Consumo Recibo")),
      Divider(height: 30),
      TextField(controller: c1, decoration: InputDecoration(labelText: "Lectura Anterior")),
      TextField(controller: c2, decoration: InputDecoration(labelText: "Lectura Actual")),
      SizedBox(height: 20),
      ElevatedButton(onPressed: () => setState(() => res = (double.parse(c2.text)-double.parse(c1.text))*(double.parse(cR.text)/double.parse(cC.text))), child: Text("CALCULAR", style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: widget.color, minimumSize: Size(double.infinity, 60))),
      if(res > 0) ...[
        Text("S/ ${res.toStringAsFixed(2)}", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: widget.color)),
        ElevatedButton.icon(onPressed: () => launchUrl(Uri.parse("https://wa.me/?text=Hola $inq! El cobro de ${widget.titulo} es S/ ${res.toStringAsFixed(2)}")), icon: Icon(Icons.send), label: Text("ENVIAR WHATSAPP"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white)),
      ]
    ]));
  }
}

class _CalculadoraSeguridad extends StatefulWidget {
  final List inquilinos; _CalculadoraSeguridad({required this.inquilinos});
  @override __CalculadoraSeguridadState createState() => __CalculadoraSeguridadState();
}

class __CalculadoraSeguridadState extends State<_CalculadoraSeguridad> {
  String? inq; final cM = TextEditingController();
  @override Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(25), child: Column(children: [
      Text("SEGURIDAD 🛡️", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      DropdownButton<String>(isExpanded: true, value: inq, hint: Text("Seleccionar Inquilino"), items: widget.inquilinos.map((i) => DropdownMenuItem<String>(value: i['nombre'], child: Text(i['nombre'] as String))).toList(), onChanged: (v) => setState(() => inq = v)),
      TextField(controller: cM, decoration: InputDecoration(labelText: "Monto Fijo S/")),
      SizedBox(height: 20),
      ElevatedButton(onPressed: () => launchUrl(Uri.parse("https://wa.me/?text=Hola $inq! El cobro de seguridad es S/ ${cM.text}")), child: Text("ENVIAR COBRO", style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, minimumSize: Size(double.infinity, 60))),
    ]));
  }
}