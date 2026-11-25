import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_rive_animation_26_3_tsw/theme/app_theme.dart';
import 'package:login_rive_animation_26_3_tsw/theme/theme_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const String _domain = '@tecdesoftware.edu.mx';

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String? _emailError;
  String? _passError;
  String? _confirmError;

  // Reglas de contraseña (se muestran en pantalla y se validan con ellas)
  bool _hasMinLength(String p) => p.length >= 8;
  bool _hasUpper(String p) => RegExp(r'[A-Z]').hasMatch(p);
  bool _hasLower(String p) => RegExp(r'[a-z]').hasMatch(p);
  bool _hasNumber(String p) => RegExp(r'\d').hasMatch(p);
  bool _hasSymbol(String p) => RegExp(r'[^A-Za-z0-9]').hasMatch(p);

  bool _isValidEmail(String email) {
    final re = RegExp(
      r'^[^\s@]+@tecdesoftware\.edu\.mx$',
      caseSensitive: false,
    );
    return re.hasMatch(email);
  }

  bool _passwordIsValid(String p) =>
      _hasMinLength(p) &&
      _hasUpper(p) &&
      _hasLower(p) &&
      _hasNumber(p) &&
      _hasSymbol(p);

  Future<void> _onSignUp() async {
    if (_isLoading) return;

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    final emailErr = email.isEmpty
        ? 'Ingresa tu correo'
        : (_isValidEmail(email) ? null : 'El correo debe terminar en $_domain');
    final passErr = pass.isEmpty
        ? 'Ingresa una contraseña'
        : (_passwordIsValid(pass)
              ? null
              : 'La contraseña no cumple las reglas');
    final confirmErr = confirm.isEmpty
        ? 'Confirma tu contraseña'
        : (confirm == pass ? null : 'Las contraseñas no coinciden');

    setState(() {
      _emailError = emailErr;
      _passError = passErr;
      _confirmError = confirmErr;
    });

    if (emailErr != null || passErr != null || confirmErr != null) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      // createUser deja la sesión abierta; se cierra para que el usuario inicie sesión
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cuenta creada correctamente. Inicia sesión.'),
          backgroundColor: AppTheme.success(context),
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        switch (e.code) {
          case 'email-already-in-use':
            _emailError = 'Este correo ya está registrado';
            break;
          case 'invalid-email':
            _emailError = 'El correo no es válido';
            break;
          case 'weak-password':
            _passError = 'La contraseña es demasiado débil';
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'No se pudo crear la cuenta. Intenta de nuevo.',
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error inesperado. Intenta de nuevo.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _rule(String text, bool ok) {
    final scheme = Theme.of(context).colorScheme;
    final color = ok ? AppTheme.success(context) : scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              key: ValueKey(ok),
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pass = _passCtrl.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 40,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Únete con tu correo institucional',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Solo se aceptan cuentas $_domain',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Correo institucional',
                      hintText: 'usuario$_domain',
                      errorText: _emailError,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      errorText: _passError,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        tooltip: _obscurePass
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    onSubmitted: (_) => _onSignUp(),
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      errorText: _confirmError,
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                      suffixIcon: IconButton(
                        tooltip: _obscureConfirm
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Reglas de la contraseña en una tarjeta suave
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.45),
                      borderRadius: AppTheme.radius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu contraseña debe tener:',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _rule('Mínimo 8 caracteres', _hasMinLength(pass)),
                        _rule('Una letra mayúscula', _hasUpper(pass)),
                        _rule('Una letra minúscula', _hasLower(pass)),
                        _rule('Un número', _hasNumber(pass)),
                        _rule('Un símbolo (!@#\$%...)', _hasSymbol(pass)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _isLoading ? null : _onSignUp,
                    child: _isLoading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: scheme.primary,
                            ),
                          )
                        : const Text('Registrarme'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes cuenta?',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Inicia sesión'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }
}
