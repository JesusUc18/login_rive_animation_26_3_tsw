import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

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
                  stateMachines: ['LoginMachine'],
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
                onChanged: (value) {
                  // 1.5 Vicular a campos de texto
                  if (_isHandsUp != null) {
                    // No tapes los ojos
                    _isHandsUp!.change(false);
                  }
                  // Si isChecking no es nulo
                  if (_isChecking != null) {
                    // Activar el modo chismoso
                    _isChecking!.change(true);
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
                onChanged: (value) {
                  // 1.5 Vicular a campos de texto
                  if (_isChecking != null) {
                    // No tapes los ojos
                    _isChecking!.change(false);
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
}
