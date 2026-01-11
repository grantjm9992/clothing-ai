import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  late final Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
    ));

    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Auth endpoints
  Future<Map<String, dynamic>> register(String email, String password, String displayName) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'display_name': displayName,
    });
    final token = response.data['access_token'];
    await _saveToken(token);
    return response.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final token = response.data['access_token'];
    await _saveToken(token);
    return response.data;
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
    await clearToken();
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get('/auth/me');
    return response.data;
  }

  // Media endpoints
  Future<Map<String, dynamic>> getPresignedUrl(String type, String mimeType, String fileName) async {
    final response = await _dio.post('/media/presign', data: {
      'type': type,
      'mimeType': mimeType,
      'fileName': fileName,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> completeUpload(String mediaObjectId, int? width, int? height, String? sha256) async {
    final response = await _dio.post('/media/complete', data: {
      'mediaObjectId': mediaObjectId,
      'width': width,
      'height': height,
      'sha256': sha256,
    });
    return response.data;
  }

  // Wardrobe endpoints
  Future<List<dynamic>> getWardrobeItems({
    String? category,
    String? color,
    List<String>? seasonTags,
  }) async {
    final response = await _dio.get('/wardrobe/items', queryParameters: {
      if (category != null) 'category': category,
      if (color != null) 'color': color,
      if (seasonTags != null) 'season_tags': seasonTags.join(','),
    });
    return response.data['items'] ?? [];
  }

  Future<Map<String, dynamic>> createWardrobeItem(String primaryPhotoId) async {
    final response = await _dio.post('/wardrobe/items', data: {
      'primaryPhotoId': primaryPhotoId,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getWardrobeItem(String id) async {
    final response = await _dio.get('/wardrobe/items/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> updateWardrobeItem(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/wardrobe/items/$id', data: data);
    return response.data;
  }

  Future<void> deleteWardrobeItem(String id) async {
    await _dio.delete('/wardrobe/items/$id');
  }

  // Outfit session endpoints
  Future<Map<String, dynamic>> createOutfitSession(String outfitPhotoId, Map<String, dynamic> context) async {
    final response = await _dio.post('/outfits/sessions', data: {
      'outfitPhotoId': outfitPhotoId,
      'context': context,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getOutfitSession(String sessionId) async {
    final response = await _dio.get('/outfits/sessions/$sessionId');
    return response.data;
  }

  Future<Map<String, dynamic>> getOutfitFeedback(String sessionId) async {
    final response = await _dio.get('/outfits/sessions/$sessionId/feedback');
    return response.data;
  }

  Future<List<dynamic>> getOutfitRecommendations(String sessionId) async {
    final response = await _dio.get('/outfits/sessions/$sessionId/recommendations');
    return response.data['recommendations'] ?? [];
  }

  Future<List<dynamic>> getOutfitSessions() async {
    final response = await _dio.get('/outfits/sessions');
    return response.data['sessions'] ?? [];
  }

  // Saved outfits
  Future<List<dynamic>> getSavedOutfits() async {
    final response = await _dio.get('/saved-outfits');
    return response.data['outfits'] ?? [];
  }

  Future<Map<String, dynamic>> saveOutfit(String name, List<String> items, List<String> occasionTags) async {
    final response = await _dio.post('/saved-outfits', data: {
      'name': name,
      'items': items,
      'occasion_tags': occasionTags,
    });
    return response.data;
  }

  // Billing
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    final response = await _dio.get('/billing/status');
    return response.data;
  }

  Future<Map<String, dynamic>> verifyPurchase(String provider, String receipt) async {
    final response = await _dio.post('/billing/verify', data: {
      'provider': provider,
      'receipt': receipt,
    });
    return response.data;
  }
}
