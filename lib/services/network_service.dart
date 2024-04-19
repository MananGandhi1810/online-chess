import 'package:dio/dio.dart';

class NetworkService {
  Future<Map<String, dynamic>> get(String url) async {
    final response = await Dio().get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }
    return response.data;
  }

  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> data) async {
    final response = await Dio().post(url, data: data);
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }
    return response.data;
  }
}
