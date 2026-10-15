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
                child: RiveAnimation.asset('/login-bear-animation.riv')),
                //Para separar
                const SizedBox(height: 10),
                //Email
                TextField(
                  //Para mostrar un tipo de teclado
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)
                    )
                  ),
                ),
                const SizedBox(height: 10),
                //Contraseña
                TextField(
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          //Para refrescar el icono
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        }),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)
                        )
                  ),
                )
            ],
          ),
        )),
    );
  }
}