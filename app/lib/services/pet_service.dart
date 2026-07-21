import 'dart:io';
import 'package:flutter/foundation.dart';
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
      debugPrint('fetchPets failed: ${e.runtimeType}');
      return const GenericResponse(
          success: false, message: 'No se pudieron cargar las mascotas.');
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
      return GenericResponse(
          success: true, data: Pet.fromJson(res), message: 'Pet added.');
    } catch (e) {
      debugPrint('addPet failed: ${e.runtimeType}');
      return const GenericResponse(
          success: false, message: 'No se pudo registrar la mascota.');
    }
  }

  Future<GenericResponse<Pet>> updatePet(
      int petId, Map<String, dynamic> updates,
      {File? photo}) async {
    try {
      if (photo != null) {
        final uid = Supabase.instance.client.auth.currentUser!.id;
        updates['photo_url'] = await _uploadPhoto(photo, uid);
      }
      final res = await _sb
          .from('pets')
          .update(updates)
          .eq('id', petId)
          .select()
          .single();
      return GenericResponse(
          success: true, data: Pet.fromJson(res), message: 'Pet updated.');
    } catch (e) {
      debugPrint('updatePet failed: ${e.runtimeType}');
      return const GenericResponse(
          success: false, message: 'No se pudo actualizar la mascota.');
    }
  }

  Future<GenericResponse<void>> deletePet(int petId) async {
    try {
      await _sb.from('pets').delete().eq('id', petId);
      return const GenericResponse(success: true, message: 'Pet deleted.');
    } catch (e) {
      debugPrint('deletePet failed: ${e.runtimeType}');
      return const GenericResponse(
          success: false, message: 'No se pudo eliminar la mascota.');
    }
  }

  Future<GenericResponse<List<Species>>> fetchSpecies() async {
    try {
      final data = await _sb.from('species').select().order('name');
      final list = (data as List).map((e) => Species.fromJson(e)).toList();
      return GenericResponse(success: true, data: list);
    } catch (e) {
      debugPrint('fetchSpecies failed: ${e.runtimeType}');
      return const GenericResponse(
          success: false, message: 'No se pudieron cargar las especies.');
    }
  }

  Future<GenericResponse<List<Breed>>> fetchBreedsBySpecies(
      int speciesId) async {
    try {
      final data = await _sb
          .from('breeds')
          .select()
          .eq('species_id', speciesId)
          .order('name');
      final list = (data as List).map((e) => Breed.fromJson(e)).toList();
      return GenericResponse(success: true, data: list);
    } catch (e) {
      debugPrint('fetchBreedsBySpecies failed: ${e.runtimeType}');
      return const GenericResponse(
          success: false, message: 'No se pudieron cargar las razas.');
    }
  }

  Future<GenericResponse<Breed>> createBreed(String name, int speciesId) async {
    try {
      final data = await _sb
          .from('breeds')
          .upsert({'name': name, 'species_id': speciesId},
              onConflict: 'name,species_id')
          .select()
          .single();
      return GenericResponse(
          success: true, data: Breed.fromJson(data), message: '');
    } catch (e) {
      debugPrint('createBreed failed: ${e.runtimeType}');
      return const GenericResponse(
          success: false, message: 'No se pudo registrar la raza.');
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
