import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';

String usuarioActual = "";
String rolUsuario = "";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es_ES', null);
  runApp(const AppGastos());
}

class AppGastos extends StatelessWidget {
  const AppGastos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MCASTRO GESTIÓN',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();

  void _login() {
    String user = usuarioController.text.trim();
    String pass = passwordController.text.trim();

    if (user == 'admin' && pass == 'admin123') {
      usuarioActual = 'Administrador';
      rolUsuario = 'admin';
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardMenu()));
    } else if (user == 'usuario' && pass == 'user123') {
      usuarioActual = 'Usuario';
      rolUsuario = 'normal';
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardMenu()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciales incorrectas'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(20),
            elevation: 8,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.apartment, size: 64, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text('MCASTRO GESTIÓN', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                  const SizedBox(height: 24),
                  TextField(
                    controller: usuarioController,
                    decoration: InputDecoration(
                      labelText: 'Usuario',
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4F46E5)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4F46E5)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Ingresar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardMenu extends StatelessWidget {
  const DashboardMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.apartment, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text('MCS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(usuarioActual, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(rolUsuario == 'admin' ? 'Administrador' : 'Usuario', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¡Bienvenido!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            Text('Panel Principal', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _DashboardCard(icon: Icons.people, title: 'Inquilinos', subtitle: 'Gestionar contratos', color: const Color(0xFF4F46E5), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ModuloInquilinos()))),
                _DashboardCard(icon: Icons.account_balance_wallet, title: 'Gastos', subtitle: 'Control de egresos', color: const Color(0xFF10B981), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ModuloGastos()))),
                _DashboardCard(icon: Icons.bolt, title: 'Calcular Luz', subtitle: 'Consumo eléctrico', color: const Color(0xFFF59E0B), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CalculadoraLuz(mes: DateFormat('MMMM', 'es_ES').format(DateTime.now()))))),
                _DashboardCard(icon: Icons.water_drop, title: 'Calcular Agua', subtitle: 'Consumo de agua', color: const Color(0xFF3B82F6), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CalculadoraServicio(tipo: 'agua', mes: DateFormat('MMMM', 'es_ES').format(DateTime.now()), icon: Icons.water_drop, color: const Color(0xFF3B82F6))))),
                _DashboardCard(icon: Icons.shield, title: 'Calcular Seguridad', subtitle: 'Costo seguridad', color: const Color(0xFF8B5CF6), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CalculadoraServicio(tipo: 'seguridad', mes: DateFormat('MMMM', 'es_ES').format(DateTime.now()), icon: Icons.shield, color: const Color(0xFF8B5CF6))))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.05), color.withValues(alpha: 0.02)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }
}

class ModuloInquilinos extends StatefulWidget {
  const ModuloInquilinos({super.key});

  @override
  State<ModuloInquilinos> createState() => _ModuloInquilinosState();
}

class _ModuloInquilinosState extends State<ModuloInquilinos> {
  final ImagePicker _picker = ImagePicker();
  String mesSeleccionado = DateFormat('MMMM', 'es_ES').format(DateTime.now());
  int anioSeleccionado = DateTime.now().year;

  void _mostrarSnackbar(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFF4F46E5)));

  @override
  Widget build(BuildContext context) {
    String mesDisplay = mesSeleccionado.isEmpty ? "" : mesSeleccionado[0].toUpperCase() + mesSeleccionado.substring(1);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Inquilinos'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              DateTime? fecha = await showDatePicker(
                context: context,
                initialDate: DateTime(anioSeleccionado, _mesANumero(mesSeleccionado), 1),
                firstDate: DateTime(2023),
                lastDate: DateTime(2030),
              );
              if (fecha != null) {
                setState(() {
                  mesSeleccionado = DateFormat('MMMM', 'es_ES').format(fecha);
                  anioSeleccionado = fecha.year;
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month, color: Colors.white),
                const SizedBox(width: 8),
                Text("Mes: $mesDisplay $anioSeleccionado", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('inquilinos').where('estado', isEqualTo: 'Activo').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                var inquilinos = snap.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: inquilinos.length,
                  itemBuilder: (context, index) {
                    var doc = inquilinos[index];
                    var data = doc.data() as Map;
                    String nombre = "${data['nombre']} ${data['apellido']}";
                    String depto = data['depto'] ?? 'N/A';
                    double renta = double.tryParse(data['renta'].toString()) ?? 0;
                    String? urlDni = data['urlFotoDni'];
                    String? urlContrato = data['urlContrato'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey[200]!)),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF4F46E5),
                          child: Text(data['nombre']?[0]?.toUpperCase() ?? "?", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                        title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: Text("Dpto $depto • Renta: S/ $renta", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        trailing: const Icon(Icons.keyboard_arrow_down),
                        onExpansionChanged: (expandido) {
                          if (expandido) {
                            _mostrarDetalleInquilino(doc, data);
                          }
                        },
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (urlDni != null || urlContrato != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("📎 Documentos", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            if (urlDni != null) GestureDetector(onTap: () => _verImagen(urlDni, "DNI"), child: Container(height: 60, width: 60, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!), image: DecorationImage(image: NetworkImage(urlDni), fit: BoxFit.cover)))),
                                            if (urlContrato != null) GestureDetector(onTap: () => _verImagen(urlContrato, "Contrato"), child: Container(height: 60, width: 60, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!), image: DecorationImage(image: NetworkImage(urlContrato), fit: BoxFit.cover)))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                _buildPagoSection(doc.id, renta),
                                const SizedBox(height: 12),
                                SizedBox(height: 42, child: ElevatedButton.icon(onPressed: () => _registrarPago(doc, nombre, renta), icon: const Icon(Icons.payment, size: 18), label: const Text("Registrar Pago"), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0))),
                                const SizedBox(height: 8),
                                SizedBox(height: 42, child: OutlinedButton.icon(onPressed: () => _showInquilinoDialog(doc: doc,  data: data), icon: const Icon(Icons.edit, size: 18), label: const Text("Editar Inquilino"), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF4F46E5), side: const BorderSide(color: Color(0xFF4F46E5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: rolUsuario == 'admin' 
          ? FloatingActionButton.extended(
              onPressed: () => _showInquilinoDialog(),
              icon: const Icon(Icons.person_add),
              label: const Text("Nuevo"),
              backgroundColor: const Color(0xFF4F46E5),
            )
          : null,
    );
  }

  void _mostrarDetalleInquilino(DocumentSnapshot doc, Map data) {
    String? urlDni = data['urlFotoDni'];
    String? urlContrato = data['urlContrato'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(backgroundColor: const Color(0xFF4F46E5), radius: 30, child: Text(data['nombre']?[0]?.toUpperCase() ?? "?", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${data['nombre']} ${data['apellido']}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                            Text("DNI: ${data['dni']}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow("📍 Departamento", data['depto'] ?? 'N/A'),
                  _buildInfoRow("💰 Renta Mensual", "S/ ${data['renta']}"),
                  _buildInfoRow("🔐 Garantía", "S/ ${data['garantia']}"),
                  _buildInfoRow("📞 Teléfonos", data['telefonos'] ?? 'N/A'),
                  _buildInfoRow("📅 Día de Pago", data['fPago'] ?? 'N/A'),
                  const Divider(height: 24),
                  const Text("🔧 Servicios", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (data['aplicaLuz'] == true) Chip(label: const Text("⚡ Luz"), backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.1), avatar: const Icon(Icons.bolt, size: 16, color: Color(0xFFF59E0B))),
                      if (data['aplicaAgua'] == true) Chip(label: const Text("💧 Agua"), backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1), avatar: const Icon(Icons.water_drop, size: 16, color: Color(0xFF3B82F6))),
                      if (data['aplicaSeguridad'] == true) Chip(label: const Text("🛡️ Seguridad"), backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1), avatar: const Icon(Icons.shield, size: 16, color: Color(0xFF10B981))),
                    ],
                  ),
                  if (urlDni != null || urlContrato != null) ...[
                    const Divider(height: 24),
                    const Text("📎 Documentos", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (urlDni != null) Expanded(child: GestureDetector(onTap: () => _verImagen(urlDni, "DNI"), child: Container(height: 100, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!), image: DecorationImage(image: NetworkImage(urlDni), fit: BoxFit.cover)), child: const Center(child: Icon(Icons.visibility, color: Colors.white, size: 40)))),),
                        if (urlDni != null && urlContrato != null) const SizedBox(width: 8),
                        if (urlContrato != null) Expanded(child: GestureDetector(onTap: () => _verImagen(urlContrato, "Contrato"), child: Container(height: 100, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!), image: DecorationImage(image: NetworkImage(urlContrato), fit: BoxFit.cover)), child: const Center(child: Icon(Icons.visibility, color: Colors.white, size: 40)))),),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF6B7280)))),
          Expanded(child: Text(": $value", style: TextStyle(color: Colors.grey[700], fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildPagoSection(String docId, double renta) {
    var pagosRef = FirebaseFirestore.instance.collection('inquilinos').doc(docId).collection('pagos').where('mes', isEqualTo: mesSeleccionado).where('anio', isEqualTo: anioSeleccionado).snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: pagosRef,
      builder: (context, pagosSnap) {
        double totalPagado = 0;
        if (pagosSnap.hasData) {
          for (var pago in pagosSnap.data!.docs) {
            totalPagado += double.tryParse(pago['monto']?.toString() ?? '0') ?? 0;
          }
        }
        double saldoPendiente = renta - totalPagado;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: saldoPendiente > 0 ? [Colors.red.shade50, Colors.red.shade100] : [Colors.green.shade50, Colors.green.shade100],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: saldoPendiente > 0 ? Colors.red.shade200 : Colors.green.shade200),
          ),
          child: Column(
            children: [
              _buildRow("Renta:", "S/ $renta"),
              const SizedBox(height: 4),
              _buildRow("Pagado:", "S/ ${totalPagado.toStringAsFixed(2)}", color: Colors.green),
              const SizedBox(height: 4),
              _buildRow("Pendiente:", "S/ ${saldoPendiente.toStringAsFixed(2)}", color: saldoPendiente > 0 ? Colors.red : Colors.green, bold: true, fontSize: 15),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value, {Color? color, bool bold = false, double fontSize = 13}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontSize: fontSize, fontWeight: bold ? FontWeight.bold : FontWeight.w500)), Text(value, style: TextStyle(fontSize: fontSize, fontWeight: bold ? FontWeight.bold : FontWeight.w600, color: color))]);
  }

  void _registrarPago(DocumentSnapshot doc, String nombre, double rentaTotal) {
    final montoController = TextEditingController();
    final observacionController = TextEditingController();
    DateTime fechaPago = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Registrar Pago", style: TextStyle(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Inquilino: $nombre", style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  DateTime? picked = await showDatePicker(context: context, initialDate: fechaPago, firstDate: DateTime(2023), lastDate: DateTime(2030));
                  if (picked != null) setState(() => fechaPago = picked);
                },
                child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.calendar_today, color: Color(0xFF4F46E5)), const SizedBox(width: 8), Text("Fecha: ${DateFormat('dd/MM/yyyy').format(fechaPago)}", style: const TextStyle(fontSize: 14))])),
              ),
              const SizedBox(height: 12),
              TextField(controller: montoController, decoration: InputDecoration(labelText: "Monto del Pago (S/)", prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF4F46E5)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: observacionController, decoration: InputDecoration(labelText: "Observación", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (montoController.text.isEmpty) {
                _mostrarSnackbar("Ingrese el monto");
                return;
              }
              double monto = double.tryParse(montoController.text) ?? 0;
              if (monto <= 0) {
                _mostrarSnackbar("Monto inválido");
                return;
              }
              await FirebaseFirestore.instance.collection('inquilinos').doc(doc.id).collection('pagos').add({'monto': monto, 'fecha': Timestamp.fromDate(fechaPago), 'fechaRegistro': FieldValue.serverTimestamp(), 'mes': mesSeleccionado, 'anio': anioSeleccionado, 'observacion': observacionController.text});
              Navigator.pop(ctx);
              _mostrarSnackbar("Pago registrado");
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _showInquilinoDialog({DocumentSnapshot? doc, Map? data}) {
    final cNombre = TextEditingController(text: data?['nombre'] ?? '');
    final cApellido = TextEditingController(text: data?['apellido'] ?? '');
    final cDni = TextEditingController(text: data?['dni'] ?? '');
    final cDepto = TextEditingController(text: data?['depto'] ?? '');
    final cTelefonos = TextEditingController(text: data?['telefonos'] ?? '');
    final cRenta = TextEditingController(text: data?['renta']?.toString() ?? '');
    final cGarantia = TextEditingController(text: data?['garantia']?.toString() ?? '');
    String estado = data?['estado'] ?? 'Activo';
    bool aplicaLuz = data?['aplicaLuz'] ?? true;
    bool aplicaAgua = data?['aplicaAgua'] ?? true;
    bool aplicaSeguridad = data?['aplicaSeguridad'] ?? true;
    String? urlDni = data?['urlFotoDni'];
    String? urlContrato = data?['urlContrato'];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(maxWidth: 700),
          height: MediaQuery.of(context).size.height * 0.85,
          child: StatefulBuilder(
            builder: (context, setStateDialog) => Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(children: [const Icon(Icons.person, color: Colors.white, size: 24), const SizedBox(width: 8), Text(doc == null ? "Nuevo Inquilino" : "Editar Inquilino", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), const Spacer(), IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx))]),
                ),
                Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [Row(children: [Expanded(child: _buildTextField(cNombre, "Nombres *", Icons.person)), const SizedBox(width: 8), Expanded(child: _buildTextField(cApellido, "Apellidos *", Icons.person_outline))]), const SizedBox(height: 8), Row(children: [Expanded(child: _buildTextField(cDni, "DNI *", Icons.credit_card, keyboardType: TextInputType.number)), const SizedBox(width: 8), Expanded(child: _buildTextField(cDepto, "Dpto *", Icons.home, keyboardType: TextInputType.number))]), const SizedBox(height: 8), _buildTextField(cTelefonos, "Teléfonos", Icons.phone, keyboardType: TextInputType.phone), const SizedBox(height: 8), Row(children: [Expanded(child: _buildTextField(cRenta, "Renta (S/)", Icons.attach_money, keyboardType: TextInputType.number)), const SizedBox(width: 8), Expanded(child: _buildTextField(cGarantia, "Garantía (S/)", Icons.security, keyboardType: TextInputType.number))]), const SizedBox(height: 16), const Align(alignment: Alignment.centerLeft, child: Text("🔧 Servicios", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))), const SizedBox(height: 8), Row(children: [Expanded(child: CheckboxListTile(title: const Text("Luz ⚡"), value: aplicaLuz, onChanged: (v) => setStateDialog(() => aplicaLuz = v!))), Expanded(child: CheckboxListTile(title: const Text("Agua 💧"), value: aplicaAgua, onChanged: (v) => setStateDialog(() => aplicaAgua = v!))), Expanded(child: CheckboxListTile(title: const Text("Seguridad 🛡️"), value: aplicaSeguridad, onChanged: (v) => setStateDialog(() => aplicaSeguridad = v!)))]), const SizedBox(height: 16), const Align(alignment: Alignment.centerLeft, child: Text("📎 Documentos", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))), const SizedBox(height: 8), Row(children: [Expanded(child: _buildUploadSection("DNI", urlDni, () => _uploadFile('dni', (url) => setStateDialog(() => urlDni = url)))), const SizedBox(width: 16), Expanded(child: _buildUploadSection("Contrato", urlContrato, () => _uploadFile('contrato', (url) => setStateDialog(() => urlContrato = url))))])]))),
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))), child: Row(children: [Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar"), style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))), const SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: () async { if (cNombre.text.isEmpty || cApellido.text.isEmpty || cDni.text.isEmpty || cDepto.text.isEmpty) { _mostrarSnackbar("Complete campos obligatorios"); return; } var newData = {'nombre': cNombre.text, 'apellido': cApellido.text, 'dni': cDni.text, 'depto': cDepto.text, 'telefonos': cTelefonos.text, 'renta': double.tryParse(cRenta.text) ?? 0, 'garantia': double.tryParse(cGarantia.text) ?? 0, 'estado': estado, 'aplicaLuz': aplicaLuz, 'aplicaAgua': aplicaAgua, 'aplicaSeguridad': aplicaSeguridad, 'urlFotoDni': urlDni, 'urlContrato': urlContrato, 'fechaModificacion': FieldValue.serverTimestamp()}; if (doc == null) { await FirebaseFirestore.instance.collection('inquilinos').add(newData); _mostrarSnackbar("Inquilino registrado"); } else { await doc.reference.update(newData); _mostrarSnackbar("Inquilino actualizado"); } Navigator.pop(ctx); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), padding: EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0), child: const Text("Guardar")))])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextField(controller: controller, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: const Color(0xFF4F46E5)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.grey[50]), keyboardType: keyboardType);
  }

  Widget _buildUploadSection(String title, String? url, Function() onUpload) {
    return Column(children: [Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)), const SizedBox(height: 6), if (url != null) GestureDetector(onTap: () => _verImagen(url, title), child: Container(height: 80, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!), image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)), child: Stack(children: [Container(color: Colors.black.withValues(alpha: 0.3)), const Center(child: Icon(Icons.visibility, color: Colors.white, size: 32))]))) else Container(height: 80, decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8), color: Colors.grey[50]), child: IconButton(icon: const Icon(Icons.upload_file, size: 32, color: Color(0xFF4F46E5)), onPressed: onUpload))]);
  }

  Future<void> _uploadFile(String tipo, Function(String) onSuccess) async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1080, imageQuality: 85);
      if (file == null) return;
      
      String fileName = '${tipo}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('documentos/$tipo/$fileName');
      
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        await ref.putData(bytes);
      } else {
        await ref.putFile(File(file.path));
      }
      
      String downloadUrl = await ref.getDownloadURL();
      onSuccess(downloadUrl);
      _mostrarSnackbar("Archivo subido correctamente");
    } catch (e) {
      _mostrarSnackbar("Error al subir: $e");
    }
  }

  void _verImagen(String url, String titulo) {
    showDialog(context: context, builder: (ctx) => Dialog(child: Column(mainAxisSize: MainAxisSize.min, children: [AppBar(title: Text(titulo), automaticallyImplyLeading: false, flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]))), foregroundColor: Colors.white, actions: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx))]), SizedBox(width: double.maxFinite, height: MediaQuery.of(context).size.height * 0.7, child: InteractiveViewer(child: Image.network(url, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.error, size: 100)))), TextButton.icon(onPressed: () async { final urlLaunch = Uri.parse(url); if (await canLaunchUrl(urlLaunch)) await launchUrl(urlLaunch, mode: LaunchMode.externalApplication); }, icon: const Icon(Icons.download), label: const Text("Descargar"))])));
  }

  int _mesANumero(String mes) { const meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre']; return meses.indexOf(mes.toLowerCase()) + 1; }
}

class CalculadoraLuz extends StatefulWidget {
  final String mes;
  const CalculadoraLuz({super.key, required this.mes});

  @override
  State<CalculadoraLuz> createState() => _CalculadoraLuzState();
}

class _CalculadoraLuzState extends State<CalculadoraLuz> {
  final _formKey = GlobalKey<FormState>();
  final _montoTotalController = TextEditingController();
  final _consumoTotalController = TextEditingController();
  List<Map<String, dynamic>> _inquilinos = [];
  Map<String, TextEditingController> _consumoActualControllers = {};
  Map<String, TextEditingController> _consumoAnteriorControllers = {};

  @override
  void initState() {
    super.initState();
    _cargarInquilinos();
  }

  Future<void> _cargarInquilinos() async {
    final snapshot = await FirebaseFirestore.instance.collection('inquilinos').where('estado', isEqualTo: 'Activo').where('aplicaLuz', isEqualTo: true).get();
    setState(() {
      _inquilinos = snapshot.docs.map((doc) {
        final data = doc.data();
        _consumoActualControllers[doc.id] = TextEditingController();
        _consumoAnteriorControllers[doc.id] = TextEditingController();
        return {'id': doc.id, 'data': data};
      }).toList();
    });
  }

  void _calcularYPresentar() {
    if (_formKey.currentState!.validate()) {
      double montoTotal = double.tryParse(_montoTotalController.text) ?? 0;
      double consumoTotalKWh = double.tryParse(_consumoTotalController.text) ?? 1;
      double costoPorKWh = montoTotal / consumoTotalKWh;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text("Resumen Luz - ${widget.mes}", style: const TextStyle(fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _inquilinos.length,
              itemBuilder: (context, index) {
                var inquilino = _inquilinos[index];
                var data = inquilino['data'] as Map<String, dynamic>;
                String consumoActualStr = _consumoActualControllers[inquilino['id']]?.text ?? '0';
                String consumoAnteriorStr = _consumoAnteriorControllers[inquilino['id']]?.text ?? '0';
                double consumoActual = double.tryParse(consumoActualStr) ?? 0;
                double consumoAnterior = double.tryParse(consumoAnteriorStr) ?? 0;
                double consumoMes = consumoActual - consumoAnterior;
                double monto = consumoMes * costoPorKWh;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ExpansionTile(
                    title: Text("${data['nombre']} ${data['apellido']} - Dpto ${data['depto']}", style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text("Consumo: $consumoMes kWh"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCalculoRow("Lectura Actual:", "$consumoActual kWh"),
                            _buildCalculoRow("Lectura Anterior:", "$consumoAnterior kWh"),
                            _buildCalculoRow("Consumo del Mes:", "$consumoMes kWh", bold: true, color: const Color(0xFFF59E0B)),
                            _buildCalculoRow("Costo por kWh:", "S/ ${costoPorKWh.toStringAsFixed(4)}"),
                            const Divider(),
                            _buildCalculoRow("TOTAL A PAGAR:", "S/ ${monto.toStringAsFixed(2)}", bold: true, color: const Color(0xFF10B981), fontSize: 16),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _enviarWhatsApp(data, consumoMes, monto, consumoActual, consumoAnterior, costoPorKWh),
                                icon: const Icon(Icons.message),
                                label: const Text("Enviar WhatsApp"),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cerrar"))],
        ),
      );
    }
  }

  Widget _buildCalculoRow(String label, String value, {bool bold = false, Color? color, double fontSize = 13}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500, fontSize: fontSize)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500, color: color, fontSize: fontSize)),
        ],
      ),
    );
  }

  void _enviarWhatsApp(Map data, double consumoMes, double monto, double consumoActual, double consumoAnterior, double costoPorKWh) {
    String mensaje = '''
Hola ${data['nombre']},

CONSUMO DE LUZ - ${widget.mes.toUpperCase()}

📊 Lectura Actual: $consumoActual kWh
📊 Lectura Anterior: $consumoAnterior kWh
⚡ Consumo: $consumoMes kWh
💰 Costo kWh: S/ ${costoPorKWh.toStringAsFixed(4)}

💵 TOTAL: S/ ${monto.toStringAsFixed(2)}

Fecha pago: ${data['fPago'] ?? '5'} del mes
''';

    String telefono = data['telefonos'] ?? '';
    if (telefono.isNotEmpty) {
      telefono = telefono.replaceAll(RegExp(r'\D'), '');
      if (!telefono.startsWith('51')) telefono = '51$telefono';
      final url = Uri.parse("https://wa.me/$telefono?text=${Uri.encodeComponent(mensaje)}");
      launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sin teléfono registrado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calcular Luz ⚡"),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]))),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [TextFormField(controller: _montoTotalController, decoration: InputDecoration(labelText: 'Monto Total (S/)', prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFF59E0B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.white), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Ingrese monto' : null), const SizedBox(height: 12), TextFormField(controller: _consumoTotalController, decoration: InputDecoration(labelText: 'Consumo Total (kWh)', prefixIcon: const Icon(Icons.bolt, color: Color(0xFFF59E0B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.white), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Ingrese consumo' : null)])),
            ),
            const SizedBox(height: 20),
            const Text("Lecturas por Departamento", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._inquilinos.map((inq) {
              var data = inq['data'] as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${data['nombre']} ${data['apellido']} - Dpto ${data['depto']}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _consumoAnteriorControllers[inq['id']], decoration: InputDecoration(labelText: 'Lectura Anterior', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), keyboardType: TextInputType.number)),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: _consumoActualControllers[inq['id']], decoration: InputDecoration(labelText: 'Lectura Actual', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), keyboardType: TextInputType.number)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton.icon(onPressed: _calcularYPresentar, icon: const Icon(Icons.calculate, size: 20), label: const Text("CALCULAR", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), padding: const EdgeInsets.all(16), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _montoTotalController.dispose();
    _consumoTotalController.dispose();
    _consumoActualControllers.values.forEach((c) => c.dispose());
    _consumoAnteriorControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }
}

class CalculadoraServicio extends StatefulWidget {
  final String tipo;
  final String mes;
  final IconData icon;
  final Color color;

  const CalculadoraServicio({super.key, required this.tipo, required this.mes, required this.icon, required this.color});

  @override
  State<CalculadoraServicio> createState() => _CalculadoraServicioState();
}

class _CalculadoraServicioState extends State<CalculadoraServicio> {
  final _formKey = GlobalKey<FormState>();
  final _montoTotalController = TextEditingController();
  final _consumoTotalController = TextEditingController();
  List<Map<String, dynamic>> _inquilinos = [];
  Map<String, TextEditingController> _consumosControllers = {};

  @override
  void initState() {
    super.initState();
    _cargarInquilinos();
  }

  Future<void> _cargarInquilinos() async {
    final snapshot = await FirebaseFirestore.instance.collection('inquilinos').where('estado', isEqualTo: 'Activo').get();
    setState(() {
      _inquilinos = snapshot.docs.map((doc) {
        final data = doc.data();
        bool aplicaServicio = false;
        if (widget.tipo == 'agua') aplicaServicio = data['aplicaAgua'] ?? false;
        else if (widget.tipo == 'seguridad') aplicaServicio = data['aplicaSeguridad'] ?? false;
        if (aplicaServicio) _consumosControllers[doc.id] = TextEditingController();
        return {'id': doc.id, 'data': data, 'aplica': aplicaServicio};
      }).where((inq) => inq['aplica'] == true).toList();
    });
  }

  void _calcularYPresentar() {
    if (_formKey.currentState!.validate()) {
      double montoTotal = double.tryParse(_montoTotalController.text) ?? 0;
      double consumoTotal = double.tryParse(_consumoTotalController.text) ?? 1;
      double costoPorUnidad = montoTotal / consumoTotal;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text("${widget.tipo.toUpperCase()} - ${widget.mes}", style: const TextStyle(fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _inquilinos.length,
              itemBuilder: (context, index) {
                var inquilino = _inquilinos[index];
                var data = inquilino['data'] as Map<String, dynamic>;
                String consumoStr = _consumosControllers[inquilino['id']]?.text ?? '0';
                double consumo = double.tryParse(consumoStr) ?? 0;
                double monto = consumo * costoPorUnidad;
                return Card(margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), child: ListTile(title: Text("${data['nombre']} ${data['apellido']}", style: const TextStyle(fontWeight: FontWeight.w500)), subtitle: Text("Dpto ${data['depto']} - Consumo: $consumo"), trailing: Text("S/ ${monto.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF10B981)))));
              },
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cerrar"))],
        ),
      );
    }
  }

  String _getLabelConsumo() {
    switch (widget.tipo) {
      case 'agua': return 'Consumo Total (m³)';
      case 'seguridad': return 'N° Departamentos';
      default: return 'Consumo';
    }
  }

  @override
  Widget build(BuildContext context) {
    String titulo = widget.tipo.toUpperCase();
    String icono = widget.tipo == 'agua' ? '💧' : '🛡️';

    return Scaffold(
      appBar: AppBar(
        title: Text("Calcular $titulo $icono"),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.color, widget.color.withValues(alpha: 0.8)]))),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: widget.color.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [TextFormField(controller: _montoTotalController, decoration: InputDecoration(labelText: 'Monto Total (S/)', prefixIcon: Icon(Icons.attach_money, color: widget.color), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.white), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Ingrese monto' : null), const SizedBox(height: 12), TextFormField(controller: _consumoTotalController, decoration: InputDecoration(labelText: _getLabelConsumo(), prefixIcon: Icon(Icons.bar_chart, color: widget.color), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.white), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Ingrese consumo' : null)])),
            ),
            const SizedBox(height: 20),
            const Text("Consumos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._inquilinos.map((inq) {
              var data = inq['data'] as Map<String, dynamic>;
              return Card(margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), child: ListTile(title: Text("${data['nombre']} ${data['apellido']}", style: const TextStyle(fontWeight: FontWeight.w500)), subtitle: Text("Dpto ${data['depto']}"), trailing: SizedBox(width: 100, child: TextField(controller: _consumosControllers[inq['id']], decoration: InputDecoration(labelText: 'Consumo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), keyboardType: TextInputType.number))));
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton.icon(onPressed: _calcularYPresentar, icon: const Icon(Icons.calculate, size: 20), label: const Text("CALCULAR", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)), style: ElevatedButton.styleFrom(backgroundColor: widget.color, padding: const EdgeInsets.all(16), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _montoTotalController.dispose();
    _consumoTotalController.dispose();
    _consumosControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }
}

class ModuloGastos extends StatefulWidget {
  const ModuloGastos({super.key});

  @override
  State<ModuloGastos> createState() => _ModuloGastosState();
}

class _ModuloGastosState extends State<ModuloGastos> {
  String mesSeleccionado = DateFormat('MMMM', 'es_ES').format(DateTime.now());
  int anioSeleccionado = DateTime.now().year;

  void _mostrarSnackbar(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFF10B981)));

  @override
  Widget build(BuildContext context) {
    String mesDisplay = mesSeleccionado.isEmpty ? "" : mesSeleccionado[0].toUpperCase() + mesSeleccionado.substring(1);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Gastos"),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]))),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              DateTime? fecha = await showDatePicker(
                context: context,
                initialDate: DateTime(anioSeleccionado, _mesANumero(mesSeleccionado), 1),
                firstDate: DateTime(2023),
                lastDate: DateTime(2030),
              );
              if (fecha != null) {
                setState(() {
                  mesSeleccionado = DateFormat('MMMM', 'es_ES').format(fecha);
                  anioSeleccionado = fecha.year;
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month, color: Colors.white),
                const SizedBox(width: 8),
                Text("Mes: $mesDisplay $anioSeleccionado", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('gastos').where('mes', isEqualTo: mesSeleccionado).where('anio', isEqualTo: anioSeleccionado).snapshots(),
            builder: (context, snap) {
              double total = 0;
              if (snap.hasData) {
                for (var d in snap.data!.docs) {
                  total += double.tryParse(d['monto'].toString()) ?? 0;
                }
              }
              return Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text("S/ ${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('gastos').where('mes', isEqualTo: mesSeleccionado).where('anio', isEqualTo: anioSeleccionado).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                if (snap.data!.docs.isEmpty) return Center(child: Text("No hay gastos", style: TextStyle(color: Colors.grey[600])));
                return ListView.builder(
                  itemCount: snap.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snap.data!.docs[index];
                    var data = doc.data() as Map;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.receipt_long, color: Color(0xFF10B981)),
                        ),
                        title: Text(data['titulo'] ?? "Sin título", style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text("${data['fecha'] ?? ''}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("S/ ${data['monto']}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF10B981))),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () { doc.reference.delete(); _mostrarSnackbar("Eliminado"); }),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: rolUsuario == 'admin' 
          ? FloatingActionButton(
              onPressed: () => _showGastoDialog(),
              backgroundColor: const Color(0xFF10B981),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showGastoDialog() {
    final cTitulo = TextEditingController();
    final cMonto = TextEditingController();
    DateTime fechaGasto = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Registrar Gasto", style: TextStyle(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () async {
                  DateTime? picked = await showDatePicker(context: context, initialDate: fechaGasto, firstDate: DateTime(2023), lastDate: DateTime(2030));
                  if (picked != null) setState(() => fechaGasto = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: const Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      Text("Fecha: ${DateFormat('dd/MM/yyyy').format(fechaGasto)}", style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(controller: cTitulo, decoration: InputDecoration(labelText: "Concepto", prefixIcon: const Icon(Icons.description, color: Color(0xFF10B981)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(controller: cMonto, decoration: InputDecoration(labelText: "Monto S/", prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF10B981)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (cTitulo.text.isEmpty || cMonto.text.isEmpty) {
                _mostrarSnackbar("Complete campos");
                return;
              }
              await FirebaseFirestore.instance.collection('gastos').add({
                'titulo': cTitulo.text,
                'monto': cMonto.text,
                'fecha': DateFormat('dd/MM/yyyy').format(fechaGasto),
                'fechaRegistro': FieldValue.serverTimestamp(),
                'mes': mesSeleccionado,
                'anio': anioSeleccionado,
              });
              Navigator.pop(ctx);
              _mostrarSnackbar("Gasto registrado");
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  int _mesANumero(String mes) { const meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre']; return meses.indexOf(mes.toLowerCase()) + 1; }
}