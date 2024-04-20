import 'package:dio/dio.dart';

class NetworkService {
  Future<Map<String, dynamic>> get(String url, {String? token}) async {
    final response = await Dio().get(
      url,
      options: Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }
    return response.data;
  }

  Future<Map<String, dynamic>> post(
      String url, Map<String, dynamic> data) async {
    final response = await Dio().post(url, data: data);
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }
    return response.data;
  }
}
