import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_exception.dart';
import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class ApiService {
  final AuthService authService;

  ApiService(this.authService);

  String get baseUrl {
    final String envUrl = dotenv.env['API_BASE_URL'] ?? String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // Fallback if no environment variable is provided
    if (kIsWeb) return 'http://localhost:8080';
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8080'; // Android emulator localhost bridge
    }
    return 'http://localhost:8080'; // iOS Simulator / macOS
  }

  Future<String?> _getFreshToken() async {
    String? token = authService.token;
    if (token != null && token.startsWith('mock-token-')) {
      return token;
    }
    try {
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        token = await fbUser.getIdToken();
      }
    } catch (_) {}
    return token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getFreshToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getTransactions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/transactions'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<Map<String, dynamic>> uploadReceipt(Uint8List bytes, String filename, {String? fromAccountId}) async {
    final uri = Uri.parse('$baseUrl/api/transactions/upload');
    final request = http.MultipartRequest('POST', uri);
    
    final token = await _getFreshToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (fromAccountId != null) {
      request.fields['fromAccountId'] = fromAccountId;
    }

    // Detect MIME type based on extension
    String ext = filename.split('.').last.toLowerCase();
    String mimeType = 'image/jpeg';
    if (ext == 'png') mimeType = 'image/png';
    else if (ext == 'gif') mimeType = 'image/gif';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<List<Map<String, dynamic>>> uploadReceiptsBatch(List<Uint8List> fileBytesList, List<String> filenames, {String? fromAccountId}) async {
    final uri = Uri.parse('$baseUrl/api/transactions/upload-batch');
    final request = http.MultipartRequest('POST', uri);
    
    final token = await _getFreshToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (fromAccountId != null) {
      request.fields['fromAccountId'] = fromAccountId;
    }

    for (int i = 0; i < fileBytesList.length; i++) {
      final bytes = fileBytesList[i];
      final filename = filenames[i];

      // Detect MIME type based on extension
      String ext = filename.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      if (ext == 'png') mimeType = 'image/png';
      else if (ext == 'gif') mimeType = 'image/gif';

      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          bytes,
          filename: filename,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.cast<Map<String, dynamic>>();
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<Map<String, dynamic>> getTransaction(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/transactions/$id'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<Map<String, dynamic>> createManualTransaction(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/transactions/manual'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<Map<String, dynamic>> updateTransaction(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/transactions/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<void> deleteTransaction(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/transactions/$id'),
      headers: await _getHeaders(),
    );
    // Backend now returns 204 No Content on success
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<Map<String, dynamic>> keepBoth(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/transactions/$id/keep-both'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/categories'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<String> addCategory(String category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/categories'),
      headers: await _getHeaders(),
      body: jsonEncode(category),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<void> deleteCategory(String name) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/categories/$name'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<List<dynamic>> getAccounts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/accounts'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<List<dynamic>> getExchangeRates() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/currencies/rates'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<Map<String, dynamic>> createAccount(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/accounts'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<void> deleteAccount(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/accounts/$id'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<String> getGemmaSuggestions(int transactionId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/transactions/$transactionId/suggestions'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['suggestions'] ?? 'No suggestions returned.';
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/me'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/auth/me'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
  }
}

String getCurrencySymbol(String? currencyCode) {
  if (currencyCode == null) return '\$';
  switch (currencyCode.toUpperCase()) {
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'UZS':
      return 'so\'m ';
    case 'USD':
    default:
      return '\$';
  }
}
