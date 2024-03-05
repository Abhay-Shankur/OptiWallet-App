import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  late String _authToken;
  final String baseUrl = 'https://api.entity.dashboard.hypersign.id';
  final String oauthEndpoint = '/api/v1/app/oauth';
  final String apiUrl = 'https://ent-27e3656.api.entity.hypersign.id';
  final String didCreateEndpoint = '/api/v1/did/create';
  final String didRegisterEndpoint = '/api/v1/did/register';
  final String presentationEndpoint = '/api/v1/presentation';
  final String verifyPresentationEndpoint = '/api/v1/presentation/verify';

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Successful response, parse and return the data
      return jsonDecode(response.body);
    } else {
      // Error response, return an error map
      print('API Error: ${response.statusCode} - ${response.reasonPhrase}');
      return {'error': 'API request failed with status code ${response.statusCode}'};
    }
  }

  Future<void> postOAuthApi() async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Api-Secret-Key': '137cbaf5df879c434cba0ea48402c.6abbad0bd95fe918a60e6540403d4f93b253bcd074137938f7f78ad00b3223774c070a01e99c6495013ec1397fdb63565',
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$oauthEndpoint'),
        headers: headers,
        // body: '',
      );

      Map<String, dynamic> res = _handleResponse(response);
      _authToken = "${res['tokenType'] as String} ${res['access_token'] as String}";

      // res['token'];

      // return _handleResponse(response);
    } catch (e) {
      print('Error during API call: $e');
      // return {'error': 'An error occurred during the API call.'};
    }
  }

  Future<Map<String, dynamic>> postCreateDid({String namespace = 'testnet'}) async {
    try {
      await postOAuthApi();

      final Map<String, String> headers = {
        'origin': '*',
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': _authToken
      };

      final Map<String, dynamic> requestBody = {'namespace': namespace};

      final response = await http.post(
        Uri.parse('$apiUrl$didCreateEndpoint'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      return _handleResponse(response);
    } catch (e) {
      print('Error during API call: $e');
      return {'error': 'An error occurred during the API call.'};
    }
  }

  Future<Map<String, dynamic>> postRegisterDid(Map<String, dynamic> requestBody) async {
    try {
      await postOAuthApi();

      final Map<String, String> headers = {
        'origin': '*',
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': _authToken
      };

      final response = await http.post(
        Uri.parse('$apiUrl$didRegisterEndpoint'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      return _handleResponse(response);
    } catch (e) {
      print('Error during API call: $e');
      return {'error': 'An error occurred during the API call.'};
    }
  }

  Future<Map<String, dynamic>> postSubmitPresentation(Map<String, dynamic> requestBody) async {
    try {
      await postOAuthApi();

      final Map<String, String> headers = {
        'origin': '*',
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': _authToken
      };

      Map<String,dynamic> presentation = {
        'credentialDocuments': [
          requestBody
        ],
        "holderDid": requestBody['credentialSubject']['id'] as String,
        "challenge": "OptiSecure",
        "domain": "optisync.com"
      };

      final response = await http.post(
        Uri.parse('$apiUrl$presentationEndpoint'),
        headers: headers,
        body: jsonEncode(presentation),
      );

      return _handleResponse(response);
    } catch (e) {
      print('Error during API call: $e');
      return {'error': 'An error occurred during the API call.'};
    }
  }

  Future<Map<String, dynamic>> postVerifyPresentation(Map<String, dynamic> requestBody) async {
    try {
      await postOAuthApi();

      final Map<String, String> headers = {
        'origin': '*',
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': _authToken
      };

      final response = await http.post(
        Uri.parse('$apiUrl$verifyPresentationEndpoint'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      return _handleResponse(response);
    } catch (e) {
      print('Error during API call: $e');
      return {'error': 'An error occurred during the API call.'};
    }
  }

  Future<Map<String, dynamic>> postRequest(String endPoint, Map<String, dynamic> requestBody) async {
    final Map<String, String> headers = {
      'origin': '*',
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': _authToken
    };

    try {
      // Call postOAuthApi() to get the necessary authentication
      // Map<String, dynamic> authResponse = await postOAuthApi();
      await postOAuthApi();

      // Check if authentication was successful
      if (_authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_authToken';

        // Now, proceed with the main request
        final response = await http.post(
          Uri.parse('$baseUrl$endPoint'),
          headers: headers,
          body: jsonEncode(requestBody),
        );

        return _handleResponse(response);
      } else {
        // Handle authentication failure
        return {'error': 'Authentication failed.'};
      }
    } catch (e) {
      print('Error during API call: $e');
      return {'error': 'An error occurred during the API call.'};
    }
  }

}
