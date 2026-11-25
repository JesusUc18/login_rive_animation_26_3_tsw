import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:login_rive_animation_26_3_tsw/screens/login_screen.dart';
import 'package:login_rive_animation_26_3_tsw/theme/theme_controller.dart';

// Pantalla de productos (consume la API de Spring Boot)
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  // 6.1 Parámetro clave: URL base de la API de Spring Boot (puerto 8090)
  // - Web / iOS Simulator / macOS: localhost apunta directo a la computadora
  // - Android (celular por USB o emulador): ejecutar antes en la laptop
  //     adb reverse tcp:8090 tcp:8090
  //   para que localhost:8090 del dispositivo se redirija a la laptop.
  //   Hay que repetirlo si se desconecta el cable o se reinicia adb.
  static const String baseUrl = 'http://localhost:8090';

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late Future<List<dynamic>> _futureProducts = fetchProducts();

  // 6.2 Función para pedir la lista de productos al endpoint GET /products
  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('${ProductsScreen.baseUrl}/products'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar productos de la API');
    }
  }

  Future<void> _reload() async {
    final future = fetchProducts();
    setState(() => _futureProducts = future);
    try {
      await future;
    } catch (_) {
      // El error se muestra en la vista de error del FutureBuilder
    }
  }

  // Cerrar sesión en Firebase y volver al Login sin permitir regresar con "atrás"
  Future<void> _onLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
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
        title: const Text('Catálogo'),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _onLogout,
          ),
        ],
      ),
      // 6.3 FutureBuilder: espera la respuesta de la API y dibuja el resultado
      body: FutureBuilder<List<dynamic>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          // Mientras responde el servidor, mostrar indicador de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si hubo un error de conexión
          if (snapshot.hasError) {
            return _MessageView(
              icon: Icons.cloud_off_rounded,
              title: 'No pudimos conectar con el servidor',
              message:
                  'Revisa que el backend esté encendido e inténtalo de nuevo.',
              onRetry: _reload,
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return _MessageView(
              icon: Icons.inventory_2_outlined,
              title: 'Aún no hay productos',
              message: 'Cuando se agreguen productos aparecerán aquí.',
              onRetry: _reload,
            );
          }

          // 6.4 Mostrar los elementos de la base de datos en tarjetas
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: products.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Text(
                    '${products.length} productos disponibles',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return _ProductCard(product: products[index - 1]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final dynamic product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // La categoría viene anidada: product['category']['category']
    final category =
        product['category']?['category']?.toString() ?? 'Sin categoría';
    final name = product['name']?.toString() ?? 'Sin nombre';
    final stock = product['stock'];
    final price = num.tryParse(product['price'].toString());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Tag(
                        icon: Icons.sell_outlined,
                        label: category,
                        background: scheme.secondaryContainer,
                        foreground: scheme.onSecondaryContainer,
                      ),
                      _Tag(
                        icon: Icons.inventory_2_outlined,
                        label: 'Stock: $stock',
                        background: scheme.surfaceContainerHighest,
                        foreground: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              price != null
                  ? '\$${price.toStringAsFixed(2)}'
                  : '\$${product['price']}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
