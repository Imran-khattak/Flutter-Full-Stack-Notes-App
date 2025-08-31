import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:notes_app/features/models/notes_model.dart';
import 'package:notes_app/features/models/user_model.dart';

class NetworkRepositories {
  final http.Client httpClient = http.Client();
  final emulator = "http://10.0.2.2:5001/v1/";
  final phyicalDevice = "http://192.168.43.198:5001/v1/";

  String _endPoind(String endpoint) {
    return "http://192.168.0.102:5001/v1/$endpoint";
  }

  final Map<String, String> _headers = {
    "Content-Type": "application/json; charset=utf-8",
  };

  Future<UserModel> signUp(UserModel user) async {
    final encodedParams = json.encode(user.toJson());

    final response = await httpClient.post(
      Uri.parse(_endPoind("users/signup")),
      body: encodedParams,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final body = response.body;
      final userInfo = UserModel.fromJson(json.decode(body)['response']);
      return userInfo;
    } else {
      // Check if response is HTML or JSON
      if (response.headers['content-type']?.contains('text/html') == true) {
        throw ServerExceptions(
          errorMessage:
              'Server returned HTML instead of JSON. Check if the API endpoint exists.',
        );
      }
      print(" Sinup Api Error: ${json.decode(response.body)['response']}");
      throw ServerExceptions(
        errorMessage: json.decode(response.body)['response'],
      );
    }
  }

  Future<UserModel> signIn(UserModel user) async {
    final encodedParams = json.encode(user.toJson());

    final response = await httpClient.post(
      Uri.parse(_endPoind("users/login")),
      body: encodedParams,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final body = response.body;
      final userInfo = UserModel.fromJson(json.decode(body)['response']);
      return userInfo;
    } else {
      throw ServerExceptions(
        errorMessage: json.decode(response.body)['response'],
      );
    }
  }

  Future<UserModel> getUser(String id) async {
    final response = await httpClient.get(
      Uri.parse(_endPoind("users/getProfile?uid=${id}")),

      headers: _headers,
    );

    if (response.statusCode == 200) {
      final body = response.body;
      final userInfo = UserModel.fromJson(json.decode(body)['response']);
      return userInfo;
    } else {
      throw ServerExceptions(
        errorMessage: json.decode(response.body)['response'],
      );
    }
  }

  Future<UserModel> updateProfile(UserModel user) async {
    final encodedParams = json.encode(user.toJson());

    final response = await httpClient.put(
      Uri.parse(_endPoind("users/updateProfile")),
      body: encodedParams,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final body = response.body;
      final userInfo = UserModel.fromJson(json.decode(body)['response']);
      return userInfo;
    } else {
      throw ServerExceptions(
        errorMessage: json.decode(response.body)['response'],
      );
    }
  }

  Future<NotesModel> addNotes(NotesModel note) async {
    final encodedParams = json.encode(note.toJson());

    final response = await httpClient.post(
      Uri.parse(_endPoind("notes/addNotes")),
      body: encodedParams,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final body = response.body;
      final note = NotesModel.fromJson(json.decode(body)['response']);
      return note;
    } else {
      throw ServerExceptions(
        errorMessage: json.decode(response.body)['response'],
      );
    }
  }

  Future<List<NotesModel>> getNotes(String id) async {
    final response = await httpClient.get(
      Uri.parse(_endPoind("notes/getNotes?uid=${id}")),

      headers: _headers,
    );

    if (response.statusCode == 200) {
      final body = response.body;
      List<dynamic> notes = json.decode(body)['response'];
      final notesList = notes.map((item) => NotesModel.fromJson(item)).toList();
      return notesList;
    } else {
      throw ServerExceptions(
        errorMessage: json.decode(response.body)['response'],
      );
    }
  }

  Future<void> updateNotes(NotesModel note) async {
    final encodedParams = json.encode(note.toJson());

    final response = await httpClient.put(
      Uri.parse(_endPoind("notes/updateNotes")),
      body: encodedParams,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final body = response.body;
      debugPrint(body);
    } else {
      throw ServerExceptions(
        errorMessage: json.decode(response.body)['response'],
      );
    }
  }

  Future<void> deleteNotes(NotesModel note) async {
    final encodedParams = json.encode(note.toJson());

    final response = await httpClient.delete(
      Uri.parse(_endPoind("notes/deleteNotes")),
      body: encodedParams,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final body = response.body;
      debugPrint(body);
    } else {
      throw ServerExceptions(
        errorMessage: json.decode(response.body)['response'],
      );
    }
  }
}

class ServerExceptions implements Exception {
  final String errorMessage;

  ServerExceptions({required this.errorMessage});
  // Add this method to return the actual error message
  @override
  String toString() {
    return errorMessage;
  }
}
