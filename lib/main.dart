import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- CORRECCIÓN PARA PANTALLA ROJA
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // ESTA LÍNEA ES LA QUE QUITA LA PANTALLA ROJA DEFINITIVAMENTE
  await initializeDateFormatting('es_ES', null); 
  
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    home: PantallaCarga(),
  ));
}

class PantallaCarga extends StatefulWidget {
  @override
  _PantallaCargaState createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => SistemaPrincipal()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo_perro.gif', width: 220, 
              errorBuilder: (c, e, s) => const Icon(Icons.pets, size: 150, color: Colors.blue)),
            const SizedBox(height: 25),
            const Text("APLICATIVO ALQUILER V1", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            const Text("by MCASTRO", style: TextStyle(fontSize: 16, color: Colors.grey, letterSpacing: 2)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class SistemaPrincipal extends StatefulWidget {
  @override
  _SistemaPrincipalState createState() => _SistemaPrincipalState();
}

class _SistemaPrincipalState extends State<SistemaPrincipal> {
  int _idx = 0;
  String mesActual = toBeginningOfSentenceCase(DateFormat('MMMM', 'es_ES').format(DateTime.now()))!;
  final List<String> meses = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final paginas = [
      _pantallaGastosMensuales(),
      _moduloServicio("LUZ ⚡", "aplicaLuz", Colors.amber[800]!),
      _moduloServicio("AGUA 💧", "aplicaAgua", Colors.blue),
      _moduloServicio("SEGURIDAD 🛡️", "aplicaSeguridad", Colors.blueGrey),
      _moduloGastosLista(),
      _moduloInquilinosLista()
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: DropdownButton<String>(
          value: meses.contains(mesActual) ? mesActual : "Abril",
          items: meses.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))).toList(),
          onChanged: (v) => setState(() => mesActual = v!),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(child: paginas[_idx]),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Resumen'),
          NavigationDestination(icon: Icon(Icons.bolt), label: 'Luz'),
          NavigationDestination(icon: Icon(Icons.water_drop), label: 'Agua'),
          NavigationDestination(icon: Icon(Icons.shield), label: 'Segu.'),
          NavigationDestination(icon: Icon(Icons.receipt), label: 'Gastos'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Inq.'),
        ],
      ),
    );
  }

  Widget _pantallaGastosMensuales() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('inquilinos').snapshots(),
      builder: (context, inqSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: _db.collection('gastos').where('mes', isEqualTo: mesActual).snapshots(),
          builder: (context, gasSnap) {
            double rentas = 0; double egresos = 0;
            if (inqSnap.hasData) rentas = inqSnap.data!.docs.fold(0, (s, d) => s + (d['renta'] ?? 0));
            if (gasSnap.hasData) egresos = gasSnap.data!.docs.fold(0, (s, d) => s + (d['monto'] ?? 0));
            return Padding(
              padding: const EdgeInsets.all(25),
              child: ListView(children: [
                const Center(child: Text("GASTOS MENSUALES", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900))),
                _card("SALDO NETO ($mesActual)", "S/ ${(rentas - egresos).toStringAsFixed(2)}", Colors.blue, true),
                _card("INGRESOS POR RENTAS", "S/ $rentas", Colors.green, false),
                _card("EGRESOS / GASTOS", "S/ $egresos", Colors.red, false),
              ]),
            );
          },
        );
      },
    );
  }

  Widget _moduloServicio(String tipo, String campoCheck, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('inquilinos').where(campoCheck, isEqualTo: true).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) return _msgError("No hay inquilinos con $tipo habilitado");
        return _CalculadoraProUI(tipo: tipo, color: color, inquilinos: snap.data!.docs, mes: mesActual);
      },
    );
  }

  Widget _moduloGastosLista() {
    return Padding(padding: const EdgeInsets.all(25), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("GASTOS $mesActual", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          IconButton.filled(onPressed: _addGasto, icon: const Icon(Icons.add_shopping_cart)),
        ]),
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: _db.collection('gastos').where('mes', isEqualTo: mesActual).snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            return ListView(children: snap.data!.docs.map((d) => Card(child: ListTile(
                title: Text(d['titulo'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text("Día: ${d['fecha']}"),
                trailing: Text("-S/ ${d['monto']}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
              ))).toList());
          },
        )),
      ]));
  }

  Widget _moduloInquilinosLista() {
    return Padding(padding: const EdgeInsets.all(25), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("MIS INQUILINOS", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          IconButton.filled(onPressed: _addInquilino, icon: const Icon(Icons.person_add)),
        ]),
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: _db.collection('inquilinos').snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            return ListView(children: snap.data!.docs.map((d) => Card(child: ExpansionTile(
                title: Text("${d['nombre']} ${d['apellido']}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                subtitle: Text("Dpto: ${d['depto']} | DNI/CE: ${d['dni']}"),
                children: [
                  Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Servicios: ${d['aplicaLuz'] ? 'Luz ' : ''}${d['aplicaAgua'] ? 'Agua ' : ''}${d['aplicaSeguridad'] ? 'Seguridad' : ''}"),
                      if (d['garantia'] > 0) Text("🛡️ Garantía: S/ ${d['garantia']} (${d['fGarantia']})", style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                      if (d['garantia'] == 0) const Text("⚠️ Garantía: Pendiente", style: TextStyle(color: Colors.orange)),
                      Text("Teléfonos: ${d['telefonos']}"),
                    ]))
                ],
              ))).toList());
          },
        )),
      ]));
  }

  _addInquilino() {
    final cNom = TextEditingController(); final cApe = TextEditingController();
    final cDni = TextEditingController(); final cDpt = TextEditingController(); 
    final cRen = TextEditingController(); final cTel = TextEditingController();
    final cGar = TextEditingController();
    final cFecGar = TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
    bool bLuz = true; bool bAgua = true; bool bSeg = false;

    showDialog(context: context, builder: (c) => StatefulBuilder(builder: (c, setS) => AlertDialog(
      title: const Text("Nuevo Inquilino"),
      content: SingleChildScrollView(child: Column(children: [
        _in("Nombres", cNom, false), 
        _in("Apellidos", cApe, false),
        _in("DNI / CE (OBLIGATORIO)", cDni, false), 
        _in("Departamento", cDpt, false), 
        _in("Renta S/", cRen, true),
        _in("Teléfonos", cTel, false),
        _in("Monto Garantía (Opcional)", cGar, true),
        TextField(
          controller: cFecGar,
          readOnly: true,
          decoration: const InputDecoration(labelText: "Fecha Garantía", suffixIcon: Icon(Icons.calendar_today)),
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context, initialDate: DateTime.now(),
              firstDate: DateTime(2000), lastDate: DateTime(2100),
            );
            if(picked != null) setS(() => cFecGar.text = DateFormat('dd/MM/yyyy').format(picked));
          },
        ),
        CheckboxListTile(title: const Text("Aplica Luz"), value: bLuz, onChanged: (v) => setS(() => bLuz = v!)),
        CheckboxListTile(title: const Text("Aplica Agua"), value: bAgua, onChanged: (v) => setS(() => bAgua = v!)),
        CheckboxListTile(title: const Text("Aplica Seguridad"), value: bSeg, onChanged: (v) => setS(() => bSeg = v!)),
      ])),
      actions: [TextButton(onPressed: () {
        if (cDni.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: El DNI / CE es obligatorio")));
          return;
        }
        _db.collection('inquilinos').add({
          'nombre': cNom.text, 'apellido': cApe.text, 'dni': cDni.text, 'depto': cDpt.text, 
          'renta': double.tryParse(cRen.text) ?? 0, 'telefonos': cTel.text,
          'garantia': double.tryParse(cGar.text) ?? 0, 'fGarantia': cFecGar.text, 
          'aplicaLuz': bLuz, 'aplicaAgua': bAgua, 'aplicaSeguridad': bSeg, 'fPago': '05'
        });
        Navigator.pop(context);
      }, child: const Text("REGISTRAR"))],
    )));
  }

  _addGasto() {
    final c1 = TextEditingController(); final c2 = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("Gasto en $mesActual"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _in("Concepto", c1, false), _in("Monto S/", c2, true),
      ]),
      actions: [TextButton(onPressed: () {
        _db.collection('gastos').add({'titulo': c1.text, 'monto': double.tryParse(c2.text) ?? 0, 'mes': mesActual, 'fecha': DateTime.now().day.toString()});
        Navigator.pop(context);
      }, child: const Text("GUARDAR"))],
    ));
  }

  Widget _card(String t, String v, Color c, bool b) => Container(
    width: double.infinity, margin: const EdgeInsets.only(top: 15), padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
    child: Column(children: [Text(t), Text(v, style: TextStyle(fontSize: b?42:26, fontWeight: FontWeight.bold, color: c))]),
  );

  Widget _in(String l, TextEditingController c, bool n) => TextField(controller: c, decoration: InputDecoration(labelText: l), keyboardType: n ? TextInputType.number : TextInputType.text);
  Widget _msgError(String m) => Center(child: Text(m, style: const TextStyle(fontSize: 18, color: Colors.grey)));
}

class _CalculadoraProUI extends StatefulWidget {
  final String tipo; final Color color; final List<QueryDocumentSnapshot> inquilinos; final String mes;
  const _CalculadoraProUI({required this.tipo, required this.color, required this.inquilinos, required this.mes});
  @override __CalculadoraProUIState createState() => __CalculadoraProUIState();
}

class __CalculadoraProUIState extends State<_CalculadoraProUI> {
  String? inq; final cR = TextEditingController(); final cC = TextEditingController();
  final c1 = TextEditingController(); final c2 = TextEditingController(); double res = 0;
  @override Widget build(BuildContext context) {
    bool esSeguridad = widget.tipo.contains("SEGURIDAD");
    return SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(children: [
      Text(widget.tipo, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: widget.color)),
      DropdownButton<String>(isExpanded: true, value: inq, hint: const Text("Elegir Inquilino"), items: widget.inquilinos.map((d) => DropdownMenuItem(value: "${d['nombre']} ${d['apellido']}", child: Text("${d['nombre']} ${d['apellido']}"))).toList(), onChanged: (v) => setState(() => inq = v)),
      if (!esSeguridad) ...[
        TextField(controller: cR, decoration: const InputDecoration(labelText: "Total Recibo S/")),
        TextField(controller: cC, decoration: const InputDecoration(labelText: "Consumo Recibo")),
        TextField(controller: c1, decoration: const InputDecoration(labelText: "Lectura Anterior")),
        TextField(controller: c2, decoration: const InputDecoration(labelText: "Lectura Actual")),
      ] else ...[
        TextField(controller: cR, decoration: const InputDecoration(labelText: "Monto de Seguridad S/")),
      ],
      const SizedBox(height: 20),
      ElevatedButton(onPressed: () => setState(() {
          if (esSeguridad) res = double.tryParse(cR.text) ?? 0;
          else {
            double r = double.tryParse(cR.text) ?? 0;
            double c = double.tryParse(cC.text) ?? 1;
            res = (double.tryParse(c2.text)! - double.tryParse(c1.text)!) * (r / c);
          }
        }),
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 65), backgroundColor: widget.color),
        child: const Text("CALCULAR COBRO", style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      if(res > 0) ...[
        Text("S/ ${res.toStringAsFixed(2)}", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: widget.color)),
        ElevatedButton.icon(onPressed: () => launchUrl(Uri.parse("https://wa.me/?text=Hola $inq! Tu pago de ${widget.tipo} de ${widget.mes} es S/ ${res.toStringAsFixed(2)}")), icon: const Icon(Icons.send, color: Colors.white), label: const Text("ENVIAR WHATSAPP", style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green)),
      ]
    ]));
  }
}