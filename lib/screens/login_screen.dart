import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'dart:async'; //3.1 Importar el timer

class LoginScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Control paaara mostrar/ocultar la contraseña
  bool _isObscure = true;

  //1.1 Crear el cerebro de la animacion
  StateMachineController? _controller;

  //1.2 SMI: StateMachineInput / Entrada de máquina de estado
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  SMINumber? _numLook;

  //3.2 Timer para detener la mirada al dejar de escribir
  Timer? _typingDebounce;

  //2.1 Crear variables para focusNode
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  //2.2 Crear los listeners (Oyentes/Chismosos)
  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        // Verificar que no sea nulo
        if (_isHandsUp != null) {
          //Ojos sin cerrar en email
          _isHandsUp?.change(false);
          _numLook?.value = 50; //3.3 Mirada neutral
        }
      }
    });

    _passwordFocusNode.addListener(() {
      //Manos arriba en password
      _isHandsUp?.change(_passwordFocusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              //Contiene la animacion
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/login-bear-animation.riv',
                  stateMachines: ['Login Machine'],
                  //1.3 Vincular la animación
                  onInit: (artboart) {
                    _controller = StateMachineController.fromArtboard(
                      artboart,
                      'Login Machine',
                    );
                    //1.4 Verificar que inició bien
                    if (_controller == null) return;

                    //Agregar controllador al tablero
                    artboart.addController(_controller!);
                    //Viculamos las variables
                    _isChecking = _controller!.findSMI('isChecking');
                    _isHandsUp = _controller!.findSMI('isHandsUp');
                    _trigSuccess = _controller!.findSMI('trigSuccess');
                    _trigFail = _controller!.findSMI('trigFail');
                    _numLook = _controller!.findSMI('numLook');
                  },
                ),
              ),
              //Para separar
              const SizedBox(height: 10),
              //Email
              TextField(
                //2.3 Asignar foco al campo de texto
                focusNode: _emailFocusNode,
                // 1.5 Vicular a campos de texto
                onChanged: (value) {
                  if (_isHandsUp != null) {
                    // No tapes los ojos
                    //_isHandsUp!.change(false);
                  }
                  // Si isChecking no es nulo
                  if (_isChecking != null) {
                    // Activar el modo chismoso
                    _isChecking!.change(true);
                    //3.4 Implementar numLook
                    //Ajustes del 0 al 100
                    // 80 es medida de calibración. Clamp es el rango (abrazadera)
                    final look = (value.length / 80.0 * 100).clamp(0.0, 100.0);
                    _numLook?.value = look;

                    //3.5 Debounce: si vuelve a teclear se reinicia el contador
                    _typingDebounce
                        ?.cancel(); // Cancelamos cualquier timer existente
                    //Crear nuevo timer
                    _typingDebounce = Timer(const Duration(seconds: 3), () {
                      //Si se cierra la pantalla (!mounted)
                      if (!mounted) return;
                      _isChecking?.change(false);
                    });
                  }
                },
                //Para mostrar un tipo de teclado
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //Contraseña
              TextField(
                //2.3 Asignar foco al campo de texto
                focusNode: _passwordFocusNode,
                // 1.5 Vicular a campos de texto
                onChanged: (value) {
                  if (_isChecking != null) {
                    // No tapes los ojos
                    //_isChecking!.change(false);
                  }
                  // Si isChecking no es nulo
                  if (_isHandsUp != null) {
                    // Activar el modo chismoso
                    _isHandsUp!.change(true);
                  }
                },
                obscureText: _isObscure,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      //Para refrescar el icono
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
    //2.4 Liberar recursos de los focusNode
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    //3.5 Liberar el timer
    _typingDebounce?.cancel();
    super.dispose();
  }
}
