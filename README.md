# 🏠 App Gastos - Gestión Inmobiliaria Minimalista

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

[cite_start]**App Gastos** es una solución de gestión inmobiliaria móvil diseñada específicamente para simplificar la administración de departamentos alquilados[cite: 1, 386, 429]. [cite_start]Con un enfoque minimalista, funcional y ultra-legible, permite llevar un control total de las finanzas y la comunicación con los inquilinos desde un solo lugar[cite: 4, 26, 343, 430].

## 🚀 Características Principales

* [cite_start]**📊 Dashboard de Control**: Visualización instantánea del saldo neto mensual (Ingresos - Gastos) con una interfaz de "letras grandes" diseñada para facilitar la lectura[cite: 54, 179, 225, 431].
* **👤 Ficha Técnica de Inquilinos**: Registro detallado que incluye:
    * [cite_start]Nombre completo y número de documento (DNI/CE)[cite: 389, 396, 432].
    * [cite_start]Múltiples números de teléfono de contacto[cite: 389, 395, 432].
    * [cite_start]Fecha de ingreso y día de pago mensual[cite: 344, 348, 432].
    * [cite_start]Repositorio visual para cargar fotos del inquilino y fotos/PDF de contratos[cite: 390, 396, 432].
* [cite_start]**⚡ Calculadoras de Servicios Inteligentes**: Módulos independientes para el cobro de **Luz (⚡)**, **Agua (💧)** y **Seguridad (🛡️)**[cite: 354, 356, 360, 433].
    * [cite_start]Cada cálculo se asocia automáticamente a un inquilino específico[cite: 370, 375, 433].
    * [cite_start]El sistema calcula el costo unitario real basado en el recibo global para evitar desfases tarifarios[cite: 63, 64, 103].
* [cite_start]**📲 Integración Directa con WhatsApp**: Generación automática de mensajes personalizados (con nombre y detalle del consumo) para enviar recibos de pago al instante[cite: 39, 71, 221, 246, 377, 434].
* [cite_start]**🛠️ Módulo de Gastos Mensuales**: Registro centralizado de reparaciones, mantenimiento de bomba, limpieza e impuestos[cite: 12, 13, 14, 205, 435]. [cite_start]Los montos se restan automáticamente de la ganancia bruta[cite: 208, 209, 349, 435].
* [cite_start]**💾 Persistencia de Datos Local**: Implementación de `shared_preferences` para asegurar que la información no se pierda al cerrar la aplicación o el navegador[cite: 236, 237, 350, 364, 436].

## 🛠️ Tecnologías Usadas

* [cite_start]**Framework**: [Flutter](https://flutter.dev) para una interfaz moderna y fluida[cite: 37, 106, 437].
* [cite_start]**Lenguaje**: [Dart](https://dart.dev)[cite: 119, 437].
* [cite_start]**Almacenamiento**: `shared_preferences` (Persistencia local)[cite: 236, 438].
* [cite_start]**Servicios Externos**: `url_launcher` para la integración nativa con WhatsApp[cite: 239, 246, 438].

## 📦 Instalación y Desarrollo Local

1.  **Clonar el repositorio**:
    ```bash
    git clone [https://github.com/TU_USUARIO/app_gastos.git](https://github.com/TU_USUARIO/app_gastos.git)
    ```
2.  **Instalar las dependencias de Flutter**:
    ```bash
    flutter pub get
    ```
3.  **Ejecutar en modo Web (Chrome)**:
    ```bash
    flutter run -d chrome
    ```
4.  **Ejecutar en Emulador o Dispositivo Android**:
    ```bash
    flutter run
    ```

## 🎨 Estilo Visual
[cite_start]La aplicación utiliza un diseño **"Light Neumorphic/Glass"** basado en el sistema **Material 3** de Google[cite: 69, 206]. [cite_start]Se prioriza el uso de fondos blancos limpios, sombras suaves y fuentes XL para garantizar que sea "a prueba de errores" para el usuario final[cite: 52, 210, 351, 393].

---
[cite_start]*Este proyecto fue desarrollado como una herramienta personalizada para facilitar la administración de alquileres familiares[cite: 24, 261, 313].*