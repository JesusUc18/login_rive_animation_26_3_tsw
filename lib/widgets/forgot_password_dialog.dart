import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Diálogo para solicitar el correo y enviar el enlace de recuperación.
/// Devuelve `true` si la solicitud se envió correctamente.
class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  late final TextEditingController _emailCtrl = TextEditingController(
    text: widget.initialEmail,
  );

  bool _isLoading = false;
  String? _error;

  Future<void> _onSend() async {
    if (_isLoading) return;

    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Ingresa tu correo');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      // OWASP: no revelar si el correo existe; 'user-not-found' se trata como éxito
      if (e.code == 'user-not-found') {
        Navigator.pop(context, true);
        return;
      }
      setState(() {
        _isLoading = false;
        _error = e.code == 'invalid-email'
            ? 'El formato del correo no es válido'
            : 'No se pudo enviar el correo. Intenta de nuevo.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'No se pudo enviar el correo. Intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recuperar contraseña'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtrl,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _onSend(),
            decoration: InputDecoration(
              hintText: 'email@ejemplo.com',
              errorText: _error,
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _onSend,
          child: _isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }
}
