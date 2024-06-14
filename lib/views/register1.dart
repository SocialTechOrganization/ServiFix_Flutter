import 'package:flutter/material.dart';
import 'package:servifix_flutter/api/dto/login_response.dart';
import 'package:servifix_flutter/api/dto/user_request.dart';
import 'package:servifix_flutter/api/service/accountservice.dart';
import 'package:servifix_flutter/api/service/userService.dart';
import 'package:servifix_flutter/views/login.dart';
import 'package:servifix_flutter/views/register2.dart';
import 'package:servifix_flutter/views/successful_registration.dart';

import '../api/service/authservice.dart';

TextEditingController nameController = TextEditingController();
TextEditingController lastNameController = TextEditingController();
TextEditingController dniController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController repeatPasswordController = TextEditingController();
TextEditingController phoneController = TextEditingController();

class Register1 extends StatefulWidget {
  const Register1({Key? key}) : super(key: key);

  @override
  State<Register1> createState() => _Register1State();
}

class _Register1State extends State<Register1> {
  String _selectedUser = 'technician';
  String  _selectedGender = 'Masculino';
  DateTime _selectedBirthday = DateTime.now();
  bool _accept = false;
  bool _isFormEmpty = true;

  void dropDownChanged(String? value) {
    setState(() {
      _selectedUser = value ?? 'technician';
    });
  }

  void isFormEmpty() {
    setState(() {
      _isFormEmpty = nameController.text.isEmpty ||
          lastNameController.text.isEmpty ||
          dniController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          repeatPasswordController.text.isEmpty ||
          !_accept;
    }
    );
  }

  clearFields() {
    nameController.clear();
    lastNameController.clear();
    dniController.clear();
    emailController.clear();
    passwordController.clear();
    repeatPasswordController.clear();
  }

  Future<void> _registerUser(BuildContext context) async {
    String originalDateTime = _selectedBirthday.toString();
    String dateWithoutTime = originalDateTime.substring(0, 10);
    int _role = (_selectedUser == 'client') ? 1 : 2;

    try {
      final registerResponse = await AuthService().register(
        nameController.text,
        lastNameController.text,
        _selectedGender,
        dateWithoutTime,
        emailController.text,
        passwordController.text,
        _role,
      );

      if (registerResponse != null) {
        final loginResponse = await _loginUser(emailController.text, passwordController.text);

        if (loginResponse != null && loginResponse.token != null && loginResponse.id != null) {
          String token = loginResponse.token!;
          int id = loginResponse.id!;
          await _createAccount(context, dateWithoutTime, _role, token, id);
        } else {
          print('No se pudo recuperar el token después del registro');
        }
      }
    } catch (e) {
      print('Error de registro: $e');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LogIn()),
      );
    }
  }

  Future<LoginResponse?> _loginUser(String email, String password) async {
    try {
      final loginResponse = await AuthService().login(email, password);
      return loginResponse;
    } catch (e) {
      print('Error de inicio de sesión: $e');
      return null;
    }
  }

  Future<void> _createAccount(BuildContext context, String dateWithoutTime, int role, String token, int id) async {
    try {
      await _createUser(context, token, id);

    } catch (e) {
      print('Error al crear la cuenta: $e');
    }
  }

  Future<void> _createUser(BuildContext context, String token, int accountId) async {
    final userRequest = UserRequest(
      address: 'file.pdf',
      description: 'No hay una descripción',
      image: 'https://i.pinimg.com/736x/d2/98/4e/d2984ec4b65a8568eab3dc2b640fc58e.jpg',
      number: '999999999',
      accountId: accountId,
    );

    print(userRequest.toString());

    try {
      final userResponse = await ClientService().createUser(userRequest, token);

      if (userResponse != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessfulRegistration(
              name: nameController.text,
              lastname: lastNameController.text,
              email: emailController.text,
              user: _selectedUser,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error al crear usuario: $e');
    }
  }


  @override
  Widget build(BuildContext context) {

    isFormEmpty();

    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 48.0, left: 48.0, top: 56.0, bottom: 48.0),
            child: Column(
              children: [
                Image(
                  image: AssetImage('lib/assets/tools.png'),
                  width: 40,
                  height: 40,
                ),

                SizedBox(height: 8),
                Text(
                  'Registro',
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 8),

                Container(
                  width: 152,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Color(0xFFF4F4F4), width: 1.0),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedUser,
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'technician',
                        child: Text('Trabajador'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'client',
                        child: Text('Cliente'),
                      ),
                    ],
                    onChanged: dropDownChanged,
                    style: TextStyle(
                      color: Color(0xFF4D4D4D),
                      fontSize: 14,
                    ),
                    underline: Container(),
                    itemHeight: 48,
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Color(0xFFF4F4F4), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1769FF), width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    labelText: 'Nombres',
                    labelStyle: TextStyle(color: Color(0xFFA0A0A0)),
                  ),
                  onChanged: (value) {
                    isFormEmpty();
                  },
                ),

                SizedBox(height: 16),

                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Color(0xFFF4F4F4), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1769FF), width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    labelText: 'Apellidos',
                    labelStyle: TextStyle(color: Color(0xFFA0A0A0)),
                  ),
                  onChanged: (value) {
                    isFormEmpty();
                  },
                ),

                SizedBox(height: 16),

            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: TextField(
                    controller: dniController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Color(0xFFF4F4F4), width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1769FF), width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'DNI',
                      labelStyle: TextStyle(color: Color(0xFFA0A0A0)),
                    ),
                    onChanged: (value) {
                      isFormEmpty();
                    },
                  ),
                ),
                SizedBox(width: 16),
                Flexible(
                  flex: 1,
                  child: TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Color(0xFFF4F4F4), width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1769FF), width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Celular',
                      labelStyle: TextStyle(color: Color(0xFFA0A0A0)),
                    ),
                    onChanged: (value) {
                      isFormEmpty();
                    },
                  ),
                ),
              ],
            ),

                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: 264,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Color(0xFFF4F4F4), width: 1.0),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          items: const <DropdownMenuItem<String>>[
                            DropdownMenuItem<String>(
                              value: 'Masculino',
                              child: Text('Masculino'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Femenino',
                              child: Text('Femenino'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'other',
                              child: Text('Otro'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value!;
                            });
                          },
                          style: TextStyle(
                            color: Color(0xFF4D4D4D),
                            fontSize: 14,
                          ),
                          underline: Container(),
                          itemHeight: 48,
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),

                    InkWell(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedBirthday,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null && pickedDate != _selectedBirthday) {
                          setState(() {
                            _selectedBirthday = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        width: 140,
                        height: 50,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Color(0xFFF4F4F4), width: 1.0),
                        ),

                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Color(0xFF4D4D4D),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${_selectedBirthday.day}/${_selectedBirthday.month}/${_selectedBirthday.year}',
                              style: TextStyle(
                                color: Color(0xFF4D4D4D),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Color(0xFFF4F4F4), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1769FF), width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: Color(0xFFA0A0A0)),
                  ),
                  onChanged: (value) {
                    isFormEmpty();
                  },
                ),

                SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Color(0xFFF4F4F4), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1769FF), width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Color(0xFFA0A0A0)),
                  ),
                  onChanged: (value) {
                    isFormEmpty();
                  },
                ),

                SizedBox(height: 16),

                TextField(
                  controller: repeatPasswordController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Color(0xFFF4F4F4), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1769FF), width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    labelText: 'Repetir contraseña',
                    labelStyle: TextStyle(color: Color(0xFFA0A0A0)),
                  ),
                  onChanged: (value) {
                    isFormEmpty();
                  },
                ),

                SizedBox(height: 24),

                Row(
                  children: [
                    Switch(
                        value: _accept ,
                        activeColor: Colors.white,
                        activeTrackColor: Color(0xFF67A1FF),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Color(0xFFDFDFDF),
                        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                        onChanged: (value) {
                        setState(() {
                          _accept = value;
                        });
                    }),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        'Acepto los términos y condiciones',
                        style: TextStyle(
                          color: Color(0xFF000000),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    if (_selectedUser == 'technician') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            Register2(
                                name: nameController.text,
                                lastname: lastNameController.text,
                                gender: _selectedGender,
                                birthday: _selectedBirthday,
                                dni: dniController.text,
                                email: emailController.text,
                                password: passwordController.text,
                                user: _selectedUser,
                                phone: phoneController.text
                            )),
                      );
                    } else {
                      _registerUser(context);
                    }
                  },
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    backgroundColor: _isFormEmpty ? Color(0xFFDFDFDF) : Color(0xFF1769FF),
                    elevation: 0,
                  ),
                ),

                TextButton(
                  child: Text(
                    'Ya tengo una cuenta',
                    style: TextStyle(
                      color: Color(0xFF67A1FF),
                      fontSize: 14,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LogIn()),
                    );
                  },
                ),

              ],
            ),
          ),
        ),
    );
  }
}
