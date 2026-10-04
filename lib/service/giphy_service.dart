import 'package:http/http.dart' as http;
import 'dart:convert';

const String _key = "tgltPxGTnCUC2WPhT2SL6ImRSDT8ryiB";

class GiphyService {
  Future<Map> getGifs(String search, int offset) async {
    final Uri uri;
    if (search.isEmpty) {
      uri = Uri.https('api.giphy.com', '/v1/gifs/trending', {
        'api_key': _key,
        'limit': '25',
        'offset': '$offset',
        'lang': 'en',
        'bundle': 'messaging_non_clips',
      });
    } else {
      uri = Uri.https('api.giphy.com', '/v1/gifs/search', {
        'api_key': _key,
        'q': search,
        'limit': '25',
        'offset': '$offset',
        'lang': 'en',
        'bundle': 'messaging_non_clips',
      });
    }

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Erro do Giphy (${response.statusCode})');
    }
    return json.decode(response.body);
  }
}
