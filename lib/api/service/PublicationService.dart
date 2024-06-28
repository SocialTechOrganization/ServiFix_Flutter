import 'package:http/http.dart' as http;
import 'dart:convert';
//import '../model/publication.dart';
import 'package:servifix_flutter/api/dto/publication_response.dart';
import './config.dart';

class PublicationService {

  static const String apiBase = Config.apiBase;
/*
* /api/v1/servifix/publications/user/{id}
Get all publications by user

Parameters
* */
  Future<List<PublicationResponse> > getPublications(String id,String TokenModel) async {
    String token = TokenModel;

    final response = await http.get(
      Uri.parse(apiBase + "servifix/publications/user/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Incluye el token de autenticación en el encabezado
      },
    );
    if (response.statusCode == 200) {
      final res = json.decode(utf8.decode(response.bodyBytes));
      print( "respuesta json:" + res.toString());

      if (res['data'] != null) {
        List<PublicationResponse> publicationResponse = (res['data'] as List).map((i) => PublicationResponse.fromJson(i)).toList();
        return publicationResponse;
      } else {
        throw Exception('The response does not contain a "data" field');
      }
    } else {
      throw Exception('Failed to load backend: ${response.statusCode}');
    }
  }

  Future<List<PublicationResponse>> getAllPublications(String TokenModel) async {
    String token = TokenModel;

    final response = await http.get(
      Uri.parse(apiBase + "servifix/publications"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Incluye el token de autenticación en el encabezado
      },
    );
    if (response.statusCode == 200) {
      final res = json.decode(utf8.decode(response.bodyBytes));
      print( "respuesta json:" + res.toString());

      if (res['data'] != null) {
        List<PublicationResponse> publicationResponse = (res['data'] as List).map((i) => PublicationResponse.fromJson(i)).toList();
        return publicationResponse;
      } else {
        throw Exception('The response does not contain a "data" field');
      }
    } else {
      throw Exception('Failed to load backend: ${response.statusCode}');
    }
  }
}
