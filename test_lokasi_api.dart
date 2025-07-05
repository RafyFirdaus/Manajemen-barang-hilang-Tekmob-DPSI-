import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'https://api-manajemen-barang-hilang.vercel.app/api';
  
  try {
    print('Testing lokasi API endpoint...');
    final response = await http.get(
      Uri.parse('$baseUrl/lokasi'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      print('Parsed Response Type: ${responseData.runtimeType}');
      
      if (responseData is List) {
        print('Response is List with ${responseData.length} items');
        for (int i = 0; i < responseData.length; i++) {
          print('Item $i: ${responseData[i]}');
        }
      } else if (responseData is Map) {
        print('Response is Map: $responseData');
      }
    } else {
      print('API Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}