import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../configs/generic_response.dart';
import '../configs/supabase_config.dart';
import '../models/pet.dart';
import '../models/species.dart';

class PetService {
  final _sb = Supabase.instance.client;

  Future<GenericResponse<List<Pet>>> fetchPets(String clientId) async {
    try {
      final data = await _sb
          .from('pets')
          .select('*, species(name, is_exotic), breeds(name)')
          .eq('client_id', clientId)
          .order('name');
      final pets = (data as List).map((e) => Pet.fromJson(e)).toList();
      return GenericResponse(success: true, data: pets, message: '');
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not load pets.', error: e.toString());
    }
  }

  Future<GenericResponse<Pet>> addPet(Pet pet, {File? photo}) async {
    try {
      String? photoUrl;
      if (photo != null) {
        photoUrl = await _uploadPhoto(photo, pet.clientId);
      }
      final insertData = {
        ...pet.toInsertJson(),
        if (photoUrl != null) 'photo_url': photoUrl,
      };
      final res = await _sb.from('pets').insert(insertData).select().single();
      return GenericResponse(success: true, data: Pet.fromJson(res), message: 'Pet added.');
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not add pet.', error: e.toString());
    }
  }

  Future<GenericResponse<Pet>> updatePet(int petId, Map<String, dynamic> updates, {File? photo}) async {
    try {
      if (photo != null) {
        final uid = Supabase.instance.client.auth.currentUser!.id;
        updates['photo_url'] = await _uploadPhoto(photo, uid);
      }
      final res = await _sb.from('pets').update(updates).eq('id', petId).select().single();
      return GenericResponse(success: true, data: Pet.fromJson(res), message: 'Pet updated.');
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not update pet.', error: e.toString());
    }
  }

  Future<GenericResponse<List<Species>>> fetchSpecies() async {
    try {
      final data = await _sb.from('species').select().order('name');
      final list = (data as List).map((e) => Species.fromJson(e)).toList();
      return GenericResponse(success: true, data: list);
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not load species.', error: e.toString());
    }
  }

  Future<GenericResponse<List<Breed>>> fetchBreedsBySpecies(int speciesId) async {
    try {
      final data = await _sb.from('breeds').select().eq('species_id', speciesId).order('name');
      final list = (data as List).map((e) => Breed.fromJson(e)).toList();
      return GenericResponse(success: true, data: list);
    } catch (e) {
      return GenericResponse(success: false, message: 'Could not load breeds.', error: e.toString());
    }
  }

  Future<String> _uploadPhoto(File file, String userId) async {
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _sb.storage
        .from(SupabaseConfig.petImagesBucket)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));
    return _sb.storage.from(SupabaseConfig.petImagesBucket).getPublicUrl(path);
  }
}
