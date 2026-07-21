import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/generic_response.dart';
import '../models/species.dart';

/// Fetches breeds from TheDogAPI and TheCatAPI.
/// No API key required for basic read access.
class BreedApiService {
  static const _dogApiUrl = 'https://api.thedogapi.com/v1/breeds?limit=200';
  static const _catApiUrl = 'https://api.thecatapi.com/v1/breeds';

  Future<GenericResponse<List<Breed>>> fetchDogBreeds(int speciesId) async {
    return _fetchFrom(_dogApiUrl, speciesId);
  }

  Future<GenericResponse<List<Breed>>> fetchCatBreeds(int speciesId) async {
    return _fetchFrom(_catApiUrl, speciesId);
  }

  Future<GenericResponse<List<Breed>>> _fetchFrom(
      String url, int speciesId) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return GenericResponse(
          success: false,
          message: 'API error ${response.statusCode}',
        );
      }

      final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
      final breeds = json
          .map((item) {
            final name = (item['name'] as String?)?.trim() ?? '';
            if (name.isEmpty) return null;
            return Breed(
              id: -(item['id'] as int), // negative = from API (not in DB yet)
              name: name,
              speciesId: speciesId,
            );
          })
          .whereType<Breed>()
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      return GenericResponse(success: true, data: breeds, message: '');
    } catch (e) {
      return GenericResponse(
        success: false,
        message: 'Could not load breeds from API.',
        error: e.toString(),
      );
    }
  }
}
