import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../data/market_repository.dart';
import '../../domain/market_models.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final cat = ref.read(marketCategoryProvider);
    ref.read(marketListingsProvider.notifier).filter(category: cat, search: _search);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selectedCat = ref.watch(marketCategoryProvider);
    final listingsAsync = ref.watch(marketListingsProvider);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        title: 'Market Centre',
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, size: 22),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedAdsScreen())),
          ),
          FilledButton(
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SellScreen())),
            child: const Text('+ Sell', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 4),
        ]),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 6),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) { setState(() => _search = v); _applyFilter(); },
              decoration: InputDecoration(
                hintText: 'Search listings…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); _applyFilter(); })
                    : null,
              ),
            ),
          ),
          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(13, 0, 13, 8),
            child: Row(
              children: [null, ...AdCategory.values].map((cat) {
                final sel = selectedCat == cat;
                final label = cat == null ? '🏪 All' : '${cat.icon} ${cat.label}';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: sel,
                    onSelected: (_) {
                      ref.read(marketCategoryProvider.notifier).state = cat;
                      _applyFilter();
                    },
                    selectedColor: c.greenLight,
                    checkmarkColor: c.green,
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, color: sel ? c.green : c.slate, fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ),
          // Listings
          Expanded(
            child: listingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (listings) {
                final featured = listings.where((l) => l.featured).toList();
                final regular = listings.where((l) => !l.featured).toList();
                return RefreshIndicator(
                  onRefresh: () => ref.read(marketListingsProvider.notifier).refresh(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(13, 0, 13, 20),
                    children: [
                      if (featured.isNotEmpty && _search.isEmpty && selectedCat == null) ...[
                        _SectionHeader('⭐ Featured Listings'),
                        SizedBox(
                          height: 220,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: featured.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (_, i) => SizedBox(
                              width: 200,
                              child: _ListingCard(listing: featured[i], featured: true),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionHeader('All Listings (${regular.length})'),
                      ],
                      ...regular.map((l) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ListingCard(listing: l),
                          )),
                      if (listings.isEmpty)
                        Center(child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text('🔍', style: TextStyle(fontSize: 48, color: c.muted)),
                            const SizedBox(height: 12),
                            Text('No listings found', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: c.muted)),
                          ]),
                        )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: context.colors.charcoal)),
      );
}

class _ListingCard extends StatelessWidget {
  final AdListing listing;
  final bool featured;
  const _ListingCard({required this.listing, this.featured = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = listing;

    return AppCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: l))),
      child: featured
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: c.greenLight,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                alignment: Alignment.center,
                child: Text(l.images.isNotEmpty ? l.images.first : '🏷', style: const TextStyle(fontSize: 54)),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(l.priceLabel, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: c.green)),
                  const SizedBox(height: 2),
                  Text('📍 ${l.location}', style: TextStyle(fontSize: 10, color: c.muted)),
                ]),
              ),
            ])
          : Row(children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(color: c.greenLight, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(l.images.isNotEmpty ? l.images.first : '🏷', style: const TextStyle(fontSize: 36)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (l.featured) AppBadge(label: '⭐ Featured', color: c.gold),
                if (l.status == AdStatus.expiring) AppBadge(label: '⏰ Expiring', color: c.red),
                if (l.featured || l.status == AdStatus.expiring) const SizedBox(height: 4),
                Text(l.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(l.priceLabel + (l.negotiable ? ' · Negotiable' : ''), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: c.green)),
                const SizedBox(height: 3),
                Row(children: [
                  Text('📍 ${l.location}', style: TextStyle(fontSize: 11, color: c.muted)),
                  const SizedBox(width: 10),
                  Text('👁 ${l.viewsCount}', style: TextStyle(fontSize: 11, color: c.muted)),
                  if (l.sellerVerified) ...[const SizedBox(width: 10), AppBadge(label: '✓ Verified', color: c.green)],
                ]),
              ])),
            ]),
    );
  }
}

// ── Listing Detail screen ──────────────────────────────────────────────
class ListingDetailScreen extends ConsumerWidget {
  final AdListing listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = listing;
    final savedAds = ref.watch(savedAdsProvider);
    final isSaved = savedAds.any((a) => a.id == l.id);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        title: l.category.label,
        onBack: () => Navigator.of(context).pop(),
        trailing: IconButton(
          icon: Icon(isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? c.gold : null),
          onPressed: () {
            if (isSaved) {
              ref.read(savedAdsProvider.notifier).update((list) => list.where((a) => a.id != l.id).toList());
            } else {
              ref.read(savedAdsProvider.notifier).update((list) => [...list, l]);
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(13),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: c.greenLight,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(l.images.isNotEmpty ? l.images.first : '🏷', style: const TextStyle(fontSize: 90)),
          ),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(l.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20))),
            if (l.featured) AppBadge(label: '⭐ Featured', color: c.gold),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Text(l.priceLabel, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: c.green)),
            if (l.negotiable) ...[const SizedBox(width: 8), AppBadge(label: 'Negotiable', color: c.muted)],
          ]),
          const SizedBox(height: 6),
          Text('📍 ${l.location}  ·  👁 ${l.viewsCount} views  ·  ${l.category.icon} ${l.category.label}', style: TextStyle(fontSize: 12, color: c.muted)),
          const SizedBox(height: 14),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Description', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 8),
              Text(l.description, style: TextStyle(fontSize: 13, color: c.slate, height: 1.65)),
            ]),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SellerProfileScreen(listing: l))),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: c.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Text(l.sellerName.isNotEmpty ? l.sellerName[0] : '?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: c.goldDark)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Seller', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                Text(l.sellerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                if (l.sellerVerified) AppBadge(label: '✓ Verified Seller', color: c.green),
              ])),
              Icon(Icons.chevron_right, color: c.muted),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: AppButton(label: '📞 Call Seller', variant: AppButtonVariant.outline, onPressed: () {})),
            const SizedBox(width: 10),
            Expanded(child: AppButton(label: '💬 WhatsApp', variant: AppButtonVariant.gold, onPressed: () {})),
          ]),
          const SizedBox(height: 10),
          if (l.expiresAt != null)
            Center(child: Text('Listing expires in ${l.daysLeft} days', style: TextStyle(fontSize: 12, color: l.daysLeft < 7 ? c.red : c.muted))),
        ],
      ),
    );
  }
}

// ── Seller Profile screen ─────────────────────────────────────────────
class SellerProfileScreen extends StatelessWidget {
  final AdListing listing;
  const SellerProfileScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = listing;
    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(title: 'Seller Profile', onBack: () => Navigator.of(context).pop()),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [c.greenDark, c.green])),
            child: Column(children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: c.gold, borderRadius: BorderRadius.circular(20)),
                alignment: Alignment.center,
                child: Text(l.sellerName.isNotEmpty ? l.sellerName[0] : '?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: c.greenDark)),
              ),
              const SizedBox(height: 12),
              Text(l.sellerName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
              const SizedBox(height: 4),
              if (l.sellerVerified) AppBadge(label: '✓ Verified Seller', color: const Color(0xFF7EFFC5), backgroundColor: const Color(0xFF7EFFC5).withOpacity(0.15)),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _SellerStat('4.8', 'RATING'),
                _SellerStat('12', 'LISTINGS'),
                _SellerStat('38', 'SALES'),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(children: [
              Row(children: [
                Expanded(child: AppButton(label: '📞 Call', onPressed: () {})),
                const SizedBox(width: 10),
                Expanded(child: AppButton(label: '💬 WhatsApp', variant: AppButtonVariant.gold, onPressed: () {})),
              ]),
              const SizedBox(height: 12),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Active Listings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(height: 8),
                  ...[l, ...AdListing.demoList().take(2)].map((ad) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
                    child: Row(children: [
                      Text(ad.images.isNotEmpty ? ad.images.first : '🏷', style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(ad.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Text(ad.priceLabel, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: c.green)),
                    ]),
                  )),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SellerStat extends StatelessWidget {
  final String value;
  final String label;
  const _SellerStat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
      ]);
}

// ── Sell (post ad) screen ─────────────────────────────────────────────
class SellScreen extends ConsumerStatefulWidget {
  const SellScreen({super.key});

  @override
  ConsumerState<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends ConsumerState<SellScreen> {
  int _step = 1;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  AdCategory _category = AdCategory.vehicles;
  bool _negotiable = false;
  bool _submitted = false;

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose(); _locationCtrl.dispose(); super.dispose(); }

  double get _price => double.tryParse(_priceCtrl.text) ?? 0;
  double get _fee => _price * 0.01;
  bool get _step1Valid => _titleCtrl.text.isNotEmpty && _priceCtrl.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (_submitted) return _buildDone(context, c);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        title: 'Post a Listing',
        onBack: _step > 1 ? () => setState(() => _step--) : () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          // Step progress
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            color: c.white,
            child: Row(children: List.generate(3, (i) => Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(children: [
                Container(height: 4, decoration: BoxDecoration(color: _step > i ? c.green : c.border, borderRadius: BorderRadius.circular(100))),
                const SizedBox(height: 3),
                Text(['Details', 'Preview', 'Fee'][i], style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _step > i ? c.green : c.muted)),
              ]),
            )))),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                if (_step == 1) ...[
                  AppCard(child: Column(children: [
                    AppTextField(label: 'LISTING TITLE', controller: _titleCtrl, placeholder: 'e.g. Toyota Camry 2019', onChanged: (_) => setState(() {})),
                    const SizedBox(height: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.slate, letterSpacing: 0.5)),
                      const SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(11), border: Border.all(color: c.border, width: 1.5)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<AdCategory>(
                            value: _category,
                            isExpanded: true,
                            items: AdCategory.values.map((cat) => DropdownMenuItem(value: cat, child: Text('${cat.icon} ${cat.label}', style: const TextStyle(fontSize: 14)))).toList(),
                            onChanged: (v) => setState(() => _category = v!),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    AppTextField(label: 'PRICE (GH₵)', controller: _priceCtrl, placeholder: '0.00', keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Price is Negotiable', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Switch(value: _negotiable, onChanged: (v) => setState(() => _negotiable = v), activeColor: c.green),
                    ]),
                    const SizedBox(height: 12),
                    AppTextField(label: 'DESCRIPTION', controller: _descCtrl, placeholder: 'Describe your item in detail…', maxLines: 4),
                    const SizedBox(height: 12),
                    AppTextField(label: 'LOCATION', controller: _locationCtrl, placeholder: 'e.g. Accra, East Legon'),
                  ])),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('ADD PHOTOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.slate, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Row(children: [
                        _PhotoSlot(icon: '📷', onTap: () {}),
                        const SizedBox(width: 8),
                        _PhotoSlot(icon: '➕', onTap: () {}),
                        const SizedBox(width: 8),
                        _PhotoSlot(icon: '➕', onTap: () {}),
                      ]),
                      const SizedBox(height: 4),
                      Text('Up to 5 photos · First photo is the cover', style: TextStyle(fontSize: 11, color: c.muted)),
                    ]),
                  ),
                ],
                if (_step == 2) ...[
                  AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Preview Your Listing', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 14),
                      Container(height: 120, decoration: BoxDecoration(color: c.greenLight, borderRadius: BorderRadius.circular(12)), alignment: Alignment.center,
                        child: Text(_category.icon, style: const TextStyle(fontSize: 60))),
                      const SizedBox(height: 14),
                      Text(_titleCtrl.text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('GH₵ ${_price.toStringAsFixed(0)}${_negotiable ? ' · Negotiable' : ''}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: c.green)),
                      const SizedBox(height: 4),
                      Text('📍 ${_locationCtrl.text.isEmpty ? 'Location not set' : _locationCtrl.text}  ·  ${_category.icon} ${_category.label}', style: TextStyle(fontSize: 12, color: c.muted)),
                      if (_descCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(_descCtrl.text, style: TextStyle(fontSize: 13, color: c.slate, height: 1.5)),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    backgroundColor: c.goldLight,
                    borderColor: c.gold.withOpacity(0.4),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('📋 Listing Fee', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: c.goldDark)),
                      const SizedBox(height: 6),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('1% of listing price', style: TextStyle(fontSize: 13, color: c.slate)),
                        Text('GH₵ ${_fee.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: c.goldDark)),
                      ]),
                      const SizedBox(height: 4),
                      Text('Paid after Superuser approval. Listing goes live once fee is confirmed.', style: TextStyle(fontSize: 12, color: c.slate, height: 1.5)),
                    ]),
                  ),
                ],
                if (_step == 3) ...[
                  AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('What happens next?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 12),
                      ...[
                        ('1', '📋 Review', 'Superuser reviews your listing (24–48 hrs)'),
                        ('2', '💰 Pay Fee', 'Pay GH₵ ${_fee.toStringAsFixed(2)} listing fee via MoMo'),
                        ('3', '✅ Go Live', 'Listing published for 30 days'),
                      ].map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(children: [
                          Container(width: 28, height: 28, decoration: BoxDecoration(color: c.greenLight, shape: BoxShape.circle),
                            alignment: Alignment.center, child: Text(s.$1, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: c.green))),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            Text(s.$3, style: TextStyle(fontSize: 12, color: c.muted)),
                          ])),
                        ]),
                      )),
                    ]),
                  ),
                ],
                const SizedBox(height: 16),
                AppButton(
                  label: _step == 3 ? 'Submit Listing for Review →' : 'Continue →',
                  width: double.infinity,
                  onPressed: _step == 1 && !_step1Valid ? null : () {
                    if (_step < 3) {
                      setState(() => _step++);
                    } else {
                      ref.read(myAdsProvider.notifier).update((list) => [...list]);
                      setState(() => _submitted = true);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDone(BuildContext context, AppColors c) => Scaffold(
    backgroundColor: c.surface,
    body: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('🎉', style: TextStyle(fontSize: 80)),
      const SizedBox(height: 16),
      Text('Listing Submitted!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.green)),
      const SizedBox(height: 8),
      Text('"${_titleCtrl.text}" has been submitted for review.\nYou\'ll be notified once approved.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.muted, height: 1.6)),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: c.goldLight, borderRadius: BorderRadius.circular(20)),
        child: Text('Listing fee: GH₵ ${_fee.toStringAsFixed(2)} due after approval', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.goldDark))),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        AppButton(label: 'My Ads', variant: AppButtonVariant.outline, onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MyAdsScreen()))),
        const SizedBox(width: 10),
        AppButton(label: 'Browse Market', onPressed: () => Navigator.of(context).pop()),
      ]),
    ]))),
  );
}

class _PhotoSlot extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _PhotoSlot({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 72, height: 72,
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border, width: 1.5, style: BorderStyle.solid), borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Text(icon, style: const TextStyle(fontSize: 26)),
      ),
    );
  }
}

// ── My Ads screen ─────────────────────────────────────────────────────
class MyAdsScreen extends ConsumerStatefulWidget {
  const MyAdsScreen({super.key});

  @override
  ConsumerState<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends ConsumerState<MyAdsScreen> {
  String _tab = 'Active';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ads = ref.watch(myAdsProvider);
    final active = ads.where((a) => a.status == AdStatus.active || a.status == AdStatus.expiring).toList();
    final pending = ads.where((a) => a.status == AdStatus.pendingReview || a.status == AdStatus.feeDue).toList();
    final expired = ads.where((a) => a.status == AdStatus.expired).toList();
    final shown = _tab == 'Active' ? active : _tab == 'Pending' ? pending : expired;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        title: 'My Ads',
        trailing: FilledButton(
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SellScreen())),
          child: const Text('+ New', style: TextStyle(fontSize: 13)),
        ),
      ),
      body: Column(children: [
        AppTabs(
          tabs: ['Active (${active.length})', 'Pending (${pending.length})', 'Expired (${expired.length})'],
          active: _tab,
          onChanged: (t) => setState(() => _tab = t.split(' ').first),
        ),
        Expanded(
          child: shown.isEmpty
              ? Center(child: Text('No ${_tab.toLowerCase()} ads', style: TextStyle(color: c.muted, fontWeight: FontWeight.w700, fontSize: 15)))
              : ListView.separated(
                  padding: const EdgeInsets.all(13),
                  itemCount: shown.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final ad = shown[i];
                    return AppCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(ad.images.isNotEmpty ? ad.images.first : '🏷', style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(ad.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(ad.priceLabel, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c.green)),
                          ])),
                          AppBadge(
                            label: switch (ad.status) {
                              AdStatus.active => 'Active',
                              AdStatus.expiring => '⏰ Expiring',
                              AdStatus.feeDue => '💰 Fee Due',
                              AdStatus.pendingReview => '⏳ Pending',
                              AdStatus.expired => 'Expired',
                              _ => ad.status.name,
                            },
                            color: switch (ad.status) {
                              AdStatus.active => c.green,
                              AdStatus.expiring => c.red,
                              AdStatus.feeDue => c.gold,
                              AdStatus.pendingReview => c.blue,
                              _ => c.muted,
                            },
                          ),
                        ]),
                        if (ad.viewsCount > 0) ...[
                          const SizedBox(height: 6),
                          Text('👁 ${ad.viewsCount} views${ad.expiresAt != null ? "  ·  ⏳ ${ad.daysLeft} days left" : ""}', style: TextStyle(fontSize: 11, color: c.muted)),
                        ],
                        const SizedBox(height: 10),
                        Row(children: [
                          if (ad.status == AdStatus.active || ad.status == AdStatus.expiring)
                            Expanded(child: AppButton(label: '📊 Stats', variant: AppButtonVariant.ghost, onPressed: () {}, padding: const EdgeInsets.symmetric(vertical: 8))),
                          if (ad.status == AdStatus.active || ad.status == AdStatus.expiring) const SizedBox(width: 8),
                          if (ad.status == AdStatus.expiring || ad.status == AdStatus.expired)
                            Expanded(child: AppButton(label: '🔄 Renew', variant: AppButtonVariant.gold, onPressed: () {}, padding: const EdgeInsets.symmetric(vertical: 8))),
                          if (ad.status == AdStatus.feeDue)
                            Expanded(child: AppButton(label: '💰 Pay Fee', onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdFeePaymentScreen(listing: ad))), padding: const EdgeInsets.symmetric(vertical: 8))),
                          if (ad.status != AdStatus.feeDue) ...[
                            if (ad.status == AdStatus.active || ad.status == AdStatus.expiring) const SizedBox(width: 8),
                            Expanded(child: AppButton(label: '🗑 Delete', variant: AppButtonVariant.danger, onPressed: () => ref.read(myAdsProvider.notifier).update((list) => list.where((a) => a.id != ad.id).toList()), padding: const EdgeInsets.symmetric(vertical: 8))),
                          ],
                        ]),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

// ── Ad Fee Payment screen ─────────────────────────────────────────────
class AdFeePaymentScreen extends ConsumerStatefulWidget {
  final AdListing listing;
  const AdFeePaymentScreen({super.key, required this.listing});

  @override
  ConsumerState<AdFeePaymentScreen> createState() => _AdFeePaymentScreenState();
}

class _AdFeePaymentScreenState extends ConsumerState<AdFeePaymentScreen> {
  String _provider = 'MTN';
  final _phoneCtrl = TextEditingController(text: '0244 000 000');
  bool _paid = false;

  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = widget.listing;

    if (_paid) return Scaffold(
      backgroundColor: c.surface,
      body: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🛒', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 16),
        Text('Ad Published!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.green)),
        const SizedBox(height: 8),
        Text('"${l.title}" is now live on Market Centre for 30 days.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.muted, height: 1.6)),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          AppButton(label: 'My Ads', variant: AppButtonVariant.outline, onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst)),
          const SizedBox(width: 10),
          AppButton(label: 'Browse Market', onPressed: () => Navigator.of(context).pop()),
        ]),
      ]))),
    );

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(title: 'Pay Listing Fee', onBack: () => Navigator.of(context).pop()),
      body: ListView(padding: const EdgeInsets.all(14), children: [
        AppCard(
          backgroundColor: c.greenLight,
          borderColor: c.green.withOpacity(0.3),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            Text('${l.category.icon} ${l.category.label}  ·  ${l.priceLabel}', style: TextStyle(fontSize: 12, color: c.muted)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Listing fee (1%)', style: TextStyle(fontSize: 13, color: c.muted)),
              Text('GH₵ ${l.listingFee.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: c.green)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PAY VIA MOBILE MONEY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.slate, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Row(children: ['MTN', 'Telecel', 'AT Money'].map((p) => Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _provider = p),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _provider == p ? c.greenLight : c.white,
                  border: Border.all(color: _provider == p ? c.green : c.border, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(p, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _provider == p ? c.green : c.slate)),
              ),
            ),
          ))).toList()),
          const SizedBox(height: 12),
          AppTextField(label: 'MOBILE MONEY NUMBER', controller: _phoneCtrl, placeholder: '024 XXX XXXX', keyboardType: TextInputType.phone),
        ])),
        const SizedBox(height: 16),
        AppButton(
          label: 'Pay GH₵ ${l.listingFee.toStringAsFixed(2)} & Publish →',
          width: double.infinity,
          onPressed: () async {
            await ref.read(marketRepositoryProvider).payFee(l.id, provider: _provider, phone: _phoneCtrl.text);
            setState(() => _paid = true);
          },
        ),
      ]),
    );
  }
}

// ── Saved Ads screen ──────────────────────────────────────────────────
class SavedAdsScreen extends ConsumerWidget {
  const SavedAdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final saved = ref.watch(savedAdsProvider);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(title: 'Saved Items', onBack: () => Navigator.of(context).pop(),
        trailing: AppBadge(label: '${saved.length}', color: c.blue)),
      body: saved.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('🔖', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('No saved items', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: c.muted)),
              const SizedBox(height: 16),
              AppButton(label: 'Browse Market', onPressed: () => Navigator.of(context).pop()),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.all(13),
              itemCount: saved.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final ad = saved[i];
                return AppCard(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: ad))),
                  child: Row(children: [
                    Container(width: 64, height: 64, decoration: BoxDecoration(color: c.greenLight, borderRadius: BorderRadius.circular(14)),
                      alignment: Alignment.center, child: Text(ad.images.isNotEmpty ? ad.images.first : '🏷', style: const TextStyle(fontSize: 32))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(ad.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(ad.priceLabel, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: c.green)),
                      Text('📍 ${ad.location}  ·  ${ad.sellerName}', style: TextStyle(fontSize: 11, color: c.muted)),
                    ])),
                    IconButton(
                      icon: Icon(Icons.bookmark_remove_rounded, color: c.red),
                      onPressed: () => ref.read(savedAdsProvider.notifier).update((list) => list.where((a) => a.id != ad.id).toList()),
                    ),
                  ]),
                );
              },
            ),
    );
  }
}
