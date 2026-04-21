# 🏠 App Gastos - Gestión Inmobiliaria Pro

**App Gastos** es una solución integral diseñada para simplificar la administración de propiedades en alquiler. Enfocada en la facilidad de uso para el propietario, permite un control riguroso de ingresos, gastos y servicios básicos con una interfaz ultra-legible y minimalista.

## 🚀 Funcionalidades Completas

### 👤 Gestión Avanzada de Inquilinos
* **Ficha Técnica**: Registro detallado que incluye Nombre, Documento de Identidad (DNI/CE), y múltiples números de contacto.
* **Control de Fechas**: Seguimiento preciso de la fecha de ingreso y el día acordado para el pago mensual.
* **Repositorio de Documentos**: Espacio listo para vincular fotos del inquilino y archivos de contratos (Imagen/PDF).

### ⚡ Calculadoras de Servicios Asociadas
* **Módulos Independientes**: Secciones separadas para **Luz (⚡)**, **Agua (💧)** y **Seguridad (🛡️)**.
* **Lógica Proporcional**: Calcula el cobro exacto para cada inquilino basado en el recibo global y el consumo individual de sus medidores internos.
* **Asociación Directa**: Cada cálculo se vincula a un inquilino de la lista para personalizar el cobro.

### 📲 Automatización de Cobros (WhatsApp)
* Generación instantánea de mensajes personalizados que incluyen el detalle del consumo y el monto total, listos para ser enviados por WhatsApp al inquilino con un solo toque.

### 🛠️ Control Financiero y Gastos
* **Módulo de Egresos**: Registro de gastos de mantenimiento, reparaciones y limpieza con fecha y descripción.
* **Balance de Caja**: Cálculo automático de la Ganancia Neta restando todos los gastos registrados de los ingresos por rentas.

### 💾 Seguridad y Persistencia
* **Almacenamiento Local**: Los datos se guardan permanentemente en el dispositivo, permitiendo el uso de la app sin pérdida de información al cerrar el proceso.

## 🛠️ Tecnologías
* **Motor**: [Flutter](https://flutter.dev) (Material 3).
* **Persistencia**: `shared_preferences` para guardado local.
* **Integración**: `url_launcher` para servicios de mensajería externos.

## 📦 Instalación
1. Clonar: `git clone https://github.com/TU_USUARIO/app_gastos.git`
2. Dependencias: `flutter pub get`
3. Ejecutar: `flutter run`

## 🔮 Próximos Pasos (Roadmap)
- [ ] Migración de base de datos a **Firebase Cloud Firestore** para sincronización en la nube.
- [ ] Generación automática de recibos en formato PDF.
- [ ] Sistema de autenticación para múltiples administradores.