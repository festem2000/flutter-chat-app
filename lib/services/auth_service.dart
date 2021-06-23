import 'dart:convert';

import 'package:chat/models/login_response.dart';
import 'package:chat/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:chat/global/environment.dart';

class AuthService with ChangeNotifier {
  // Create storage
  final _storage = new FlutterSecureStorage();

  Usuario usuario;
  bool _autenticando = false;

  /// Metodo que se conecta al backend y envia la informacion necesaria para poder acceder al backend
  Future<bool> login(String email, String password) async {
    this.autenticando = true;

    //INFORMACION QUE SE ENVIA AL BACKEND
    final data = {
      'email': email,
      'password': password,
    };

    // Se crea la peticion POST para enviar al Backend
    final resp = await http.post(
      '${Environment.apiUrl}/login/',
      // Informacion para acceder al login
      body: jsonEncode(data),
      // Notifica que la informacion enviada al backend es a traves de JSON
      headers: {'Content-Type': 'application/json'},
    );
    // Verificar si la informacion que viene del Backend es correcta y el status es 200
    if (resp.statusCode == 200) {
      // Se transforma el JSON de respuesta a una modelo dentro de Flutter
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;

      // Termina de autenticar una vez halla traido la informacion del backend
      this.autenticando = false;

      //Guardar token en lugar seguro
      await this._guardarToken(loginResponse.token);

      return true;
    } else {
      // Termina de autenticar una vez halla traido la informacion del backend
      this.autenticando = false;
      return false;
    }
  }

  /// Metodo que se conecta al backend y envia la informacion para el registro de un usuario
  Future register(String nombre, String email, String password) async {
    //INFORMACION QUE SE ENVIA AL BACKEND
    final data = {"nombre": nombre, "email": email, "password": password};

    // Se crea la peticion POST para enviar al Backend
    final response = await http.post('${Environment.apiUrl}/login/new',
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));

    if (response.statusCode == 200) {
      final loginResponse = loginResponseFromJson(response.body);
      this.usuario = loginResponse.usuario;

      // Termina de autenticar una vez halla traido la informacion del backend
      this.autenticando = false;

      //Guardar token en lugar seguro
      await this._guardarToken(loginResponse.token);
      return true;
    } else {
      // Termina de autenticar una vez halla traido la informacion del backend
      this.autenticando = false;
      final respBody = jsonDecode(response.body);
      return respBody['msg'];
    }
  }

  ///
  Future<bool> isLoggedIn() async {
    final token = await this._storage.read(key: 'token');

    // Se crea la peticion GET para enviar al Backend
    final resp = await http.get(
      '${Environment.apiUrl}/login/renew',
      headers: {
        'Content-Type': 'application/json',
        'x-token': token,
      },
    );
    // Verificar si la informacion que viene del Backend es correcta y el status es 200
    if (resp.statusCode == 200) {
      // Se transforma el JSON de respuesta a una modelo dentro de Flutter
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;

      await this._guardarToken(loginResponse.token);

      return true;
    } else {
      this._logout();
      return false;
    }
  }

  ///  Guardar el token
  Future _guardarToken(String token) async {
    // Write value
    return await _storage.write(key: 'token', value: token);
  }

  /// Borrar el token
  Future _logout() async {
    // Delete value
    return await _storage.delete(key: 'token');
  }

  /// Meotodo delete del token de manera estatica
  static Future<void> deleteToken() async {
    // Como es estatico el metodo yo no tengo acceso a los atributos de la clase
    final _storage = new FlutterSecureStorage();
    // Elimina el token
    await _storage.delete(key: 'token');
  }

  ///==========================================================================
  /// METODOS GET AND SET

  /// Get del token de manera estatica
  static Future<String> getToken() async {
    // Como es estatico el metodo yo no tengo acceso a los atributos de la clase
    final _storage = new FlutterSecureStorage();

    // Lee el token y lo retorna
    final token = await _storage.read(key: 'token');

    return token;
  }

  /// Get devuelve el valor de la variable
  bool get autenticando => this._autenticando;

  /// Set cambia el valor de la variable
  set autenticando(bool valor) {
    this._autenticando = valor;
    notifyListeners();
  }
}
