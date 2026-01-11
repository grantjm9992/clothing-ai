import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/wardrobe_item.dart';
import '../models/outfit_session.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.read(apiServiceProvider));
});

class AuthState {
  final bool isAuthenticated;
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    Map<String, dynamic>? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthStateNotifier(this._apiService) : super(AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final userData = await _apiService.getMe();
      state = state.copyWith(isAuthenticated: true, user: userData['user']);
    } catch (e) {
      state = state.copyWith(isAuthenticated: false);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _apiService.login(email, password);
      state = state.copyWith(
        isAuthenticated: true,
        user: data['user'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> register(String email, String password, String displayName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _apiService.register(email, password, displayName);
      state = state.copyWith(
        isAuthenticated: true,
        user: data['user'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    state = AuthState();
  }
}

// Wardrobe Provider
final wardrobeProvider = StateNotifierProvider<WardrobeNotifier, WardrobeState>((ref) {
  return WardrobeNotifier(ref.read(apiServiceProvider));
});

class WardrobeState {
  final List<WardrobeItem> items;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;

  WardrobeState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  WardrobeState copyWith({
    List<WardrobeItem>? items,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return WardrobeState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  List<WardrobeItem> get filteredItems {
    if (selectedCategory == null) return items;
    return items.where((item) => item.category == selectedCategory).toList();
  }
}

class WardrobeNotifier extends StateNotifier<WardrobeState> {
  final ApiService _apiService;

  WardrobeNotifier(this._apiService) : super(WardrobeState()) {
    fetchItems();
  }

  Future<void> fetchItems({String? category}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _apiService.getWardrobeItems(category: category);
      final items = data.map((json) => WardrobeItem.fromJson(json)).toList();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<void> addItem(String photoId) async {
    try {
      await _apiService.createWardrobeItem(photoId);
      await fetchItems();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _apiService.deleteWardrobeItem(id);
      await fetchItems();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

// Outfit Sessions Provider
final outfitSessionsProvider = StateNotifierProvider<OutfitSessionsNotifier, OutfitSessionsState>((ref) {
  return OutfitSessionsNotifier(ref.read(apiServiceProvider));
});

class OutfitSessionsState {
  final List<OutfitSession> sessions;
  final bool isLoading;
  final String? error;
  final OutfitSession? currentSession;

  OutfitSessionsState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
    this.currentSession,
  });

  OutfitSessionsState copyWith({
    List<OutfitSession>? sessions,
    bool? isLoading,
    String? error,
    OutfitSession? currentSession,
  }) {
    return OutfitSessionsState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentSession: currentSession ?? this.currentSession,
    );
  }
}

class OutfitSessionsNotifier extends StateNotifier<OutfitSessionsState> {
  final ApiService _apiService;

  OutfitSessionsNotifier(this._apiService) : super(OutfitSessionsState());

  Future<void> fetchSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _apiService.getOutfitSessions();
      final sessions = data.map((json) => OutfitSession.fromJson(json)).toList();
      state = state.copyWith(sessions: sessions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<OutfitSession> createSession(String photoId, Map<String, dynamic> context) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _apiService.createOutfitSession(photoId, context);
      final session = OutfitSession.fromJson(data);
      state = state.copyWith(currentSession: session, isLoading: false);
      return session;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> pollSession(String sessionId) async {
    try {
      final data = await _apiService.getOutfitSession(sessionId);
      final session = OutfitSession.fromJson(data);

      if (session.isComplete) {
        // Fetch feedback and recommendations
        final feedback = await _apiService.getOutfitFeedback(sessionId);
        final recommendations = await _apiService.getOutfitRecommendations(sessionId);

        final updatedSession = OutfitSession.fromJson({
          ...data,
          'feedback': feedback,
          'recommendations': recommendations,
        });

        state = state.copyWith(currentSession: updatedSession);
      } else {
        state = state.copyWith(currentSession: session);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Subscription Provider
final subscriptionProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getSubscriptionStatus();
});
