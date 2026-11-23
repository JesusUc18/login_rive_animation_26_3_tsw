import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:login_rive_animation_26_3_tsw/screens/login_screen.dart';

// Pantalla de productos (consume la API de Spring Boot)
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  // 6.1 Parámetro clave: URL base de la API de Spring Boot (puerto 8090)
  // - Web / iOS Simulator / macOS: usar http://localhost:8090
  // - Emulador Android: cambiar localhost por 10.0.2.2 (http://10.0.2.2:8090)
  // - Celular físico: usar la IP de tu computadora (ej. http://192.168.1.X:8090)
  static const String baseUrl = 'http://10.0.2.2:8090';

  // 6.2 Función para pedir la lista de productos al endpoint GET /products
  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar productos de la API');
    }
  }

  // Cerrar sesión en Firebase y volver al Login sin permitir regresar con "atrás"
  Future<void> _onLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos de Spring Boot'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => _onLogout(context),
          ),
        ],
      ),
      // 6.3 FutureBuilder: espera la respuesta de la API y dibuja el resultado
      body: FutureBuilder<List<dynamic>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          // Mientras responde el servidor, mostrar indicador de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si hubo un error de conexión
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];

          // 6.4 Mostrar los elementos de la base de datos en una lista sencilla
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              // La categoría viene anidada: product['category']['category']
              final category =
                  product['category']?['category']?.toString() ??
                  'Sin categoría';
              return ListTile(
                title: Text(product['name'].toString()),
                subtitle: Text(
                  'Categoría: $category\nStock: ${product['stock']}',
                ),
                isThreeLine: true,
                trailing: Text('\$${product['price']}'),
              );
            },
          );
        },
      ),
    );
  }
}
