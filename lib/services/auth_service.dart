import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:http/http.dart' as http;
import '../services/pref_service.dart';

class InvalidCredentialsException implements Exception {
  final String message;

  InvalidCredentialsException(this.message);

  @override
  String toString() => message;
}

class NetworkException {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static const String _signInUrl =
      'https://api.staging.vscrawl.com/auth/v1/signin';
  static const String _profileUrl =
      'https://api.staging.vscrawl.com/user/v1/settings/profile';
  static const String _dashboardUrl =
      'https://api.staging.vscrawl.com/document/v1/count/documents-status';
  static const String _documentUrl =
      'https://api.staging.vscrawl.com/document/v1?page=0&size=10&sort=id%2Cdesc';
  static const String _organizationUrl =
      'https://api.staging.vscrawl.com/organization/v1';
  static const String _businessAppsUrl =
      'https://api.staging.vscrawl.com/organization/v1/apps';
  static const String _organizationStatsUrl =
      'https://api.staging.vscrawl.com/organization/v1/count/organization';
  static const String _usersUrl =
      'https://api.staging.vscrawl.com/organization/v1/users';
  static const String _rolesUrl =
      'https://api.staging.vscrawl.com/user/v1/roles/available';
  static const String _inviteUserUrl =
      'https://api.staging.vscrawl.com/organization/v1/user';

  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_signInUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "grant_type": "PASSWORD",
          "username": email,
          "password": password,
        }),
      );
      debugPrintApiResponse(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        try {
          final error = jsonDecode(response.body);
          if (error['errorCode'] == 4000) {
            throw InvalidCredentialsException('Wrong Email or Password');
          }
          throw Exception(
            error['errorDescription'] ?? error['message'] ?? 'Sign in failed',
          );
        } catch (e) {
          if (e is InvalidCredentialsException) rethrow;
          throw Exception('Sign in failed (status ${response.statusCode})');
        }
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }
  }

  static Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final userData = await PrefService.getUserData();

      String? token =
          userData?['access_token'] ??
          userData?['token'] ??
          userData?['accessToken'];

      final response = await http.get(
        Uri.parse(_profileUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrintApiResponse(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (userData != null) {
        return userData;
      } else {
        throw Exception(
          'Failed to load profile (status ${response.statusCode})',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to fetch user profile');
    }
  }

  static Future<Map<String, dynamic>> fetchDashboardData() async {
    try {
      final userData = await PrefService.getUserData();

      String? token =
          userData?['access_token'] ??
          userData?['token'] ??
          userData?['accessToken'];

      final response = await http.get(
        Uri.parse(_dashboardUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to load Dashboard data (status ${response.statusCode})',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw Exception('Failed to fetch dashboard data');
    }
  }

  static Future<Map<String, dynamic>> fetchDocuments({
    int page = 0,
    int size = 10,
    String? status,
    String? query,
  }) async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final uri = Uri.parse(_documentUrl).replace(
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
          if (status != null) 'status': status,
          if (query != null && query.isNotEmpty) 'searchValue': query,
          'sort': 'id,desc',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrintApiResponse(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to load documents (status ${response.statusCode})',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to fetch documents');
    }
  }

  static Future<void> deleteDocument(int workflowId) async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final response = await http.delete(
        Uri.parse('https://api.staging.vscrawl.com/document/v1/workflows'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'workflowIds': workflowId.toString()}),
      );

      debugPrintApiResponse(response);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete document (status ${response.statusCode})',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to delete document');
    }
  }

  static Future<void> renameDocument(int workflowId, String newName) async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String;

      final response = await http.put(
        Uri.parse(
          'https://api.staging.vscrawl.com/workflow/v1/rename/$workflowId',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': newName}),
      );

      debugPrintApiResponse(response);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to rename document (status ${response.statusCode})',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to rename document');
    }
  }

  static Future<List<int>> downloadDocument(int workflowId) async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final response = await http.get(
        Uri.parse(
          'https://api.staging.vscrawl.com/document/v1/download/$workflowId?selectedOption=downloadDocument',
        ),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      debugPrintApiResponse(response);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception(
          'Failed to download document (status ${response.statusCode})',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to download document');
    }
  }

  static Future<Map<String, dynamic>> fetchOrganization() async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final response = await http.get(
        Uri.parse(_organizationUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrintApiResponse(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to load organization (staus ${response.statusCode})',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to fetch organization');
    }
  }

  static Future<void> updateOrganization({
    required int organizationId,
    required String name,
  }) async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final response = await http.put(
        Uri.parse('$_organizationUrl/$organizationId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name}),
      );

      debugPrintApiResponse(response);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update organization (status ${(response.statusCode)}',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to update organization');
    }
  }

  static Future<void> updateOrganizationLogo(String base64Image) async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final settingsJson = jsonEncode({
        'APP_BRANDING': {
          'favicon': '',
          'faviconFileName': '',
          'logo': 'data:image/png;base64,$base64Image',
        },
      });

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('https://api.staging.vscrawl.com/organization/v1/branding'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['settingsJson'] = settingsJson;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrintApiResponse(response);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to update logo (status ${response.statusCode})',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to update logo');
    }
  }

  static Future<Map<String, dynamic>> fetchBusinessApps({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final uri = Uri.parse(_businessAppsUrl).replace(
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
          'sort': 'createdAt,desc',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrintApiResponse(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to load business apps (status ${response.statusCode})',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to fetch business apps');
    }
  }

  static Future<void> createBusinessApp({
    required String clientId,
    required String appName,
    String? description,
    required String callbackUrl,
    required bool status,
  }) async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final response = await http.post(
        Uri.parse(_businessAppsUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'clientId': clientId,
          'appName': appName,
          'description': description ?? '',
          'callbackUrl': callbackUrl,
          'status': status,
        }),
      );

      debugPrintApiResponse(response);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add app (status ${response.statusCode})');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to add app');
    }
  }

  static Future<void> updateBusinessApp({
    required String clientId,
    required String appName,
    String? appDescription,
    required String callbackUrl,
    required bool status,
    bool webhookActive = false,
    String webhookEvents = '',
    String webhookUrl = '',
  }) async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final response = await http.put(
        Uri.parse('$_businessAppsUrl/$clientId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'appName': appName,
          'appDescription': appDescription ?? '',
          'callbackUrl': callbackUrl,
          'status': status,
          'webhookActive': webhookActive,
          'webhookEvents': webhookEvents,
          'webhookUrl': webhookUrl,
        }),
      );

      debugPrintApiResponse(response);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update app (status ${response.statusCode})');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to update app');
    }
  }

  static Future<String> generateBusinessAppSecret(String clientId) async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final response = await http.get(
        Uri.parse('$_businessAppsUrl/$clientId/secret'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrintApiResponse(response);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['secret'] ?? body['clientSecret'] ?? response.body;
      } else {
        throw Exception(
          'Failed to generate secret (status ${response.statusCode})',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to generate secret');
    }
  }

  static Future<void> deleteBusinessApp(String clientId) async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final uri = Uri.parse(
        _businessAppsUrl,
      ).replace(queryParameters: {'clientIds': clientId});

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrintApiResponse(response);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete app (status ${response.statusCode})');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to delete app');
    }
  }

  static Future<Map<String, dynamic>> fetchOrganizationStats() async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final response = await http.get(
        Uri.parse(_organizationStatsUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrintApiResponse(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to load organization stats (status ${response.statusCode})',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to fetch organization stats');
    }
  }

  static Future<Map<String, dynamic>> fetchOrganizationUsers({
    int page = 0,
    int size = 10,
    String? searchValue,
  }) async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final Map<String, String> queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        'sort': 'isOwner,desc',
      };

      if (searchValue != null && searchValue.trim().isNotEmpty) {
        queryParams['multiSearchValue'] = searchValue.trim();
      }

      final uri = Uri.parse(_usersUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrintApiResponse(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load users (status ${response.statusCode})');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to fetch users');
    }
  }

  static Future<List<dynamic>> fetchAvailableRoles() async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final response = await http.get(
        Uri.parse(_rolesUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrintApiResponse(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load roles (status ${response.statusCode})',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to fetch roles');
    }
  }

  static Future<void> inviteUser ({
    required String name,
    required String emailAddress,
    required int roleId,
}) async {
    try {
      final userData = await PrefService.getUserData();
      final token = userData?['accessToken'] as String?;

      final response = await http.post(
        Uri.parse(_inviteUserUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'emailAddress': emailAddress,
          'roleId': roleId,
        }),
      );
      
      debugPrintApiResponse(response);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to invite user (status ${response.statusCode})',
        );
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NetworkException || e is Exception) rethrow;
      throw Exception('Failed to invite user');
    }
  }

  static void debugPrintApiResponse(http.Response response) {
    print('API status: ${response.statusCode}');
    print('API body: ${response.body}');
  }
}
