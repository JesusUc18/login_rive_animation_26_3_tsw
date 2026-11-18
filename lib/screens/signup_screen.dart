import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        const SnackBar(
          content: Text('Cuenta creada correctamente. Inicia sesión.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
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
                content: Text(e.message ?? 'No se pudo crear la cuenta'),
                backgroundColor: Colors.red,
              ),
            );
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error inesperado. Intenta de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _rule(String text, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: ok ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: ok ? Colors.green : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pass = _passCtrl.text;
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'usuario$_domain',
                  errorText: _emailError,
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  errorText: _passError,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePass ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Confirmar contraseña',
                  errorText: _confirmError,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _rule('Mínimo 8 caracteres', _hasMinLength(pass)),
              _rule('Una letra mayúscula', _hasUpper(pass)),
              _rule('Una letra minúscula', _hasLower(pass)),
              _rule('Un número', _hasNumber(pass)),
              _rule('Un símbolo (!@#\$%...)', _hasSymbol(pass)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  height: 50,
                  color: Colors.blue,
                  disabledColor: Colors.blue.shade300,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: _isLoading ? null : _onSignUp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Registrarme'),
                ),
              ),
            ],
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
