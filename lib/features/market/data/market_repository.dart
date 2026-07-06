import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/app_exception.dart';
import '../domain/market_models.dart';

class MarketRepository {
  final Dio _dio;
  const MarketRepository(this._dio);

  /// GET /ads — browse listings with optional filters (spec §5.7).
  Future<List<AdListing>> browse({AdCategory? category, String? search, bool? featured}) async {
    try {
      final resp = await _dio.get('/ads', queryParameters: {
        if (category != null) 'category': category.name,
        if (search != null && search.isNotEmpty) 'search': search,
        if (featured == true) 'featured': true,
      });
      return (resp.data['data'] as List).map((j) => AdListing.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (_isOffline(e)) return AdListing.demoList();
      throw AppException.fromDio(e);
    }
  }

  /// POST /ads — submit a new listing for review (spec §5.7).
  Future<AdListing> post({required String title, required String description, required AdCategory category, required double price, required bool negotiable, required String location}) async {
    try {
      final resp = await _dio.post('/ads', data: {
        'title': title, 'description': description,
        'category': category.name, 'price': price,
        'negotiable': negotiable, 'location': location,
      });
      return AdListing.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (_isOffline(e)) return AdListing.demoList().first;
      throw AppException.fromDio(e);
    }
  }

  /// POST /ads/:id/pay-fee — pay listing fee via MoMo (spec §5.7).
  Future<void> payFee(String adId, {required String provider, required String phone}) async {
    try {
      await _dio.post('/ads/$adId/pay-fee', data: {'provider': provider, 'phone': phone});
    } on DioException catch (e) {
      if (_isOffline(e)) return; // demo: proceed
      throw AppException.fromDio(e);
    }
  }

  /// POST /ads/:id/favourite (spec §5.7).
  Future<void> favourite(String adId) async {
    try {
      await _dio.post('/ads/$adId/favourite');
    } catch (_) {}
  }

  bool _isOffline(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout;
}

final marketRepositoryProvider = Provider<MarketRepository>(
  (ref) => MarketRepository(ref.watch(dioProvider)),
);

// ── State providers ──────────────────────────────────────────────────

/// Browse listings — AsyncNotifier so UI gets loading/error/data states.
class MarketListingsNotifier extends AsyncNotifier<List<AdListing>> {
  AdCategory? _category;
  String _search = '';

  @override
  Future<List<AdListing>> build() =>
      ref.read(marketRepositoryProvider).browse();

  Future<void> filter({AdCategory? category, String search = ''}) async {
    _category = category;
    _search = search;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(marketRepositoryProvider).browse(category: _category, search: _search.isEmpty ? null : _search));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(marketRepositoryProvider).browse(category: _category, search: _search.isEmpty ? null : _search));
  }
}

final marketListingsProvider = AsyncNotifierProvider<MarketListingsNotifier, List<AdListing>>(
  MarketListingsNotifier.new,
);

/// My ads (agent's own listings).
final myAdsProvider = StateProvider<List<AdListing>>((_) => AdListing.myAds());

/// Saved/favourited ads.
final savedAdsProvider = StateProvider<List<AdListing>>((_) => [AdListing.demoList()[1], AdListing.demoList()[2]]);

/// Currently selected category filter (null = All).
final marketCategoryProvider = StateProvider<AdCategory?>((_) => null);
