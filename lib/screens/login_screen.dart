import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_rive_animation_26_3_tsw/screens/products_screen.dart';
import 'package:login_rive_animation_26_3_tsw/screens/signup_screen.dart';
import 'package:login_rive_animation_26_3_tsw/theme/app_theme.dart';
import 'package:login_rive_animation_26_3_tsw/theme/theme_controller.dart';
import 'package:login_rive_animation_26_3_tsw/widgets/forgot_password_dialog.dart';
import 'package:rive/rive.dart';

import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;

  StateMachineController? _controller;
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  SMINumber? _numLook;

  Timer? _typingDebounce;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // Variable para mostrar el CircularProgressIndicator mientras carga
  bool _isLoading = false;

  // OWASP A07:2021: un único mensaje genérico, sin revelar qué campo falló
  static const String _genericError =
      'Credenciales inválidas. Verifica tu correo y contraseña.';

  void _showGlobalError() {
    _trigFail?.fire();
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: scheme.onError),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _genericError,
                  style: TextStyle(color: scheme.onError),
                ),
              ),
            ],
          ),
          backgroundColor: scheme.error,
        ),
      );
  }

  Future<void> _onLogin() async {
    if (_isLoading) return;

    final email = emailCtrl.text.trim();
    final pass = passwordCtrl.text;

    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0;

    // Solo se valida que los campos no estén vacíos
    if (email.isEmpty || pass.isEmpty) {
      _showGlobalError();
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      _trigSuccess?.fire();
      // Esperar a que termine la animación de éxito antes de navegar
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProductsScreen()),
      );
    } catch (_) {
      // Cualquier fallo (credenciales, usuario inexistente, red) usa el mismo mensaje
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showGlobalError();
    }
  }

  Future<void> _onForgotPassword() async {
    FocusScope.of(context).unfocus();
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => ForgotPasswordDialog(initialEmail: emailCtrl.text.trim()),
    );
    if (sent != true || !mounted) return;

    // Mensaje genérico: no confirma si el correo está registrado (OWASP)
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            'Si el correo está registrado, recibirás un enlace para restablecer tu contraseña.',
          ),
          backgroundColor: AppTheme.success(context),
        ),
      );
  }

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        if (_isHandsUp != null) {
          _isHandsUp?.change(false);
          _numLook?.value = 50;
        }
      }
    });

    _passwordFocusNode.addListener(() {
      _isHandsUp?.change(_passwordFocusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Botón de modo día / noche
                  const Align(
                    alignment: Alignment.centerRight,
                    child: ThemeToggleButton(),
                  ),

                  // Oso dentro de una tarjeta redondeada azul pastel
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      height: 230,
                      color: isDark
                          ? AppTheme.pastelBlueDeep
                          : AppTheme.pastelBlue,
                      child: RiveAnimation.asset(
                        'assets/login-bear-animation.riv',
                        stateMachines: const ['Login Machine'],
                        fit: BoxFit.cover,
                        onInit: (artboard) {
                          _controller = StateMachineController.fromArtboard(
                            artboard,
                            'Login Machine',
                          );
                          if (_controller == null) return;
                          artboard.addController(_controller!);
                          _isChecking = _controller?.findSMI('isChecking');
                          _isHandsUp = _controller?.findSMI('isHandsUp');
                          _trigSuccess = _controller?.findSMI('trigSuccess');
                          _trigFail = _controller?.findSMI('trigFail');
                          _numLook = _controller?.findSMI('numLook');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    '¡Bienvenido de vuelta!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Inicia sesión para ver el catálogo',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: emailCtrl,
                    focusNode: _emailFocusNode,
                    onChanged: (value) {
                      if (_isChecking != null) {
                        _isChecking!.change(true);
                        final look = (value.length / 70.0 * 100).clamp(
                          0.0,
                          100.0,
                        );
                        _numLook?.value = look;
                        _typingDebounce?.cancel();
                        _typingDebounce = Timer(const Duration(seconds: 3), () {
                          if (!mounted) return;
                          _isChecking?.change(false);
                        });
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'correo@ejemplo.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordCtrl,
                    focusNode: _passwordFocusNode,
                    onChanged: (value) {
                      _isHandsUp?.change(true);
                    },
                    onSubmitted: (_) => _onLogin(),
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        tooltip: _isObscure
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        icon: Icon(
                          _isObscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _onForgotPassword,
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FilledButton(
                    onPressed: _isLoading ? null : _onLogin,
                    child: _isLoading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: scheme.primary,
                            ),
                          )
                        : const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Al iniciar sesión, aceptas nuestras políticas de privacidad y términos de servicio.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta?',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text('Regístrate'),
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
    emailCtrl.dispose();
    passwordCtrl.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }
}
