import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/customer_models.dart';

/// Customers provider (demo data; replace with GET /customers in Phase 2 backend).
final customersProvider = StateProvider<List<Customer>>((_) => Customer.demoList());

/// Port of the prototype's CustomersScreen + CustomerDetailScreen.
class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _query = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final all = ref.watch(customersProvider);

    final filtered = all.where((cu) {
      final matchesQuery = _query.isEmpty ||
          cu.fullName.toLowerCase().contains(_query.toLowerCase()) ||
          cu.phone.contains(_query);
      final matchesFilter = switch (_filter) {
        'Verified' => cu.kycStatus == KycStatus.verified,
        'Unverified' => cu.kycStatus == KycStatus.unverified,
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        title: 'Customers',
        trailing: FilledButton.icon(
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddCustomerScreen())),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add', style: TextStyle(fontSize: 13)),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 6),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search by name or phone…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _query = ''))
                    : null,
              ),
            ),
          ),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
            child: Row(
              children: ['All', 'Verified', 'Unverified'].map((f) {
                final sel = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: sel,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: c.greenLight,
                    checkmarkColor: c.green,
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, color: sel ? c.green : c.slate, fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ),
          // Summary row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
            child: Row(children: [
              Text('${filtered.length} customers', style: TextStyle(fontSize: 12, color: c.muted, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${all.where((cu) => cu.isVerified).length} verified', style: TextStyle(fontSize: 12, color: c.green, fontWeight: FontWeight.w700)),
            ]),
          ),
          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('👤', style: TextStyle(fontSize: 48, color: c.muted)),
                    const SizedBox(height: 12),
                    Text('No customers found', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: c.muted)),
                  ]))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(13, 4, 13, 20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final cu = filtered[i];
                      return AppCard(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: cu))),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(color: c.greenLight, borderRadius: BorderRadius.circular(13)),
                              alignment: Alignment.center,
                              child: Text(cu.initials, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: c.green)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cu.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                  Text(cu.phone, style: TextStyle(fontSize: 12, color: c.muted)),
                                  const SizedBox(height: 3),
                                  AppBadge(
                                    label: switch (cu.kycStatus) {
                                      KycStatus.verified => '✓ KYC Verified',
                                      KycStatus.pending => '⏳ KYC Pending',
                                      KycStatus.unverified => 'Unverified',
                                    },
                                    color: switch (cu.kycStatus) {
                                      KycStatus.verified => c.green,
                                      KycStatus.pending => c.gold,
                                      KycStatus.unverified => c.muted,
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${cu.totalTransactions} txns', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.slate)),
                                Text('GH₵ ${(cu.totalVolume / 1000).toStringAsFixed(1)}k', style: TextStyle(fontSize: 11, color: c.muted)),
                              ],
                            ),
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

// ── Customer Detail screen ─────────────────────────────────────────────
class CustomerDetailScreen extends ConsumerStatefulWidget {
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  String _tab = 'Info';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cu = widget.customer;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        title: cu.fullName,
        onBack: () => Navigator.of(context).pop(),
        trailing: TextButton(onPressed: () {}, child: const Text('✏️ Edit')),
      ),
      body: Column(
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            color: c.white,
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: c.greenLight, borderRadius: BorderRadius.circular(18)),
                  alignment: Alignment.center,
                  child: Text(cu.initials, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: c.green)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cu.fullName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      Text(cu.phone, style: TextStyle(fontSize: 13, color: c.muted)),
                      const SizedBox(height: 6),
                      AppBadge(
                        label: switch (cu.kycStatus) {
                          KycStatus.verified => '✓ KYC Verified',
                          KycStatus.pending => '⏳ Pending',
                          KycStatus.unverified => 'Unverified',
                        },
                        color: switch (cu.kycStatus) {
                          KycStatus.verified => c.green,
                          KycStatus.pending => c.gold,
                          KycStatus.unverified => c.muted,
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Quick stats
          Container(
            color: c.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                _QuickStat(label: 'TRANSACTIONS', value: '${cu.totalTransactions}', color: c.green),
                _Divider(),
                _QuickStat(label: 'TOTAL VOLUME', value: 'GH₵ ${(cu.totalVolume / 1000).toStringAsFixed(1)}k', color: c.gold),
                _Divider(),
                _QuickStat(
                  label: 'LAST SEEN',
                  value: cu.lastTransactionAt != null ? DateFormat('MMM d').format(cu.lastTransactionAt!) : '—',
                  color: c.slate,
                ),
              ],
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 0),
            child: Row(children: [
              Expanded(child: AppButton(label: '📞 Call', variant: AppButtonVariant.outline, onPressed: () {})),
              const SizedBox(width: 8),
              Expanded(child: AppButton(label: '💸 Transact', onPressed: () => Navigator.of(context).pushNamed('/momo'))),
              const SizedBox(width: 8),
              Expanded(child: AppButton(label: '📋 History', variant: AppButtonVariant.ghost, onPressed: () => setState(() => _tab = 'History'))),
            ]),
          ),
          AppTabs(tabs: const ['Info', 'History'], active: _tab, onChanged: (t) => setState(() => _tab = t)),
          Expanded(
            child: _tab == 'History' ? _HistoryTab(customer: cu) : _InfoTab(customer: cu),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _QuickStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, color: context.colors.muted, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(height: 36, width: 1, color: context.colors.border);
}

class _InfoTab extends StatelessWidget {
  final Customer customer;
  const _InfoTab({required this.customer});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cu = customer;
    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Customer Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 10),
            ...[
              ('Full Name', cu.fullName),
              ('Phone Number', cu.phone),
              ('KYC Status', cu.kycStatus.name[0].toUpperCase() + cu.kycStatus.name.substring(1)),
              if (cu.idType != null) ('ID Type', cu.idType!.label),
              if (cu.idNumber != null) ('ID Number', cu.idNumber!),
              ('Customer Since', DateFormat('MMM d, yyyy').format(cu.createdAt)),
            ].map((row) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(row.$1, style: TextStyle(color: c.muted, fontSize: 13)),
                    Text(row.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ]),
                )),
          ]),
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final Customer customer;
  const _HistoryTab({required this.customer});

  static const _mockTxns = [
    (type: 'Cash In', amount: '+GH₵ 500', provider: 'MTN', date: 'Today 10:43 AM', ok: true),
    (type: 'Cash Out', amount: '-GH₵ 300', provider: 'MTN', date: 'Jun 24 3:15 PM', ok: true),
    (type: 'Send Money', amount: '-GH₵ 800', provider: 'Telecel', date: 'Jun 22 11:00 AM', ok: true),
    (type: 'Airtime', amount: '-GH₵ 20', provider: 'AT Money', date: 'Jun 20 8:00 AM', ok: false),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Transaction History (${_mockTxns.length})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 8),
            ..._mockTxns.asMap().entries.map((entry) {
              final t = entry.value;
              final isLast = entry.key == _mockTxns.length - 1;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: c.border))),
                child: Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: t.ok ? c.greenLight : c.redLight, borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Icon(t.type == 'Cash In' ? Icons.south_west : Icons.north_east, size: 16, color: t.ok ? c.green : c.red),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t.type, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('${t.provider} · ${t.date}', style: TextStyle(fontSize: 11, color: c.muted)),
                  ])),
                  Text(t.amount, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: t.amount.startsWith('+') ? c.green : c.charcoal)),
                ]),
              );
            }),
          ]),
        ),
      ],
    );
  }
}

// ── Add Customer screen ───────────────────────────────────────────────
class AddCustomerScreen extends ConsumerStatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _idNumCtrl = TextEditingController();
  IdType _idType = IdType.ghanaCard;
  bool _done = false;

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); _idNumCtrl.dispose(); super.dispose(); }

  bool get _valid => _nameCtrl.text.isNotEmpty && _phoneCtrl.text.isNotEmpty;

  void _save() {
    // TODO: POST /customers (spec §5.5 customers endpoint)
    final newCustomer = Customer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      businessId: 'b1',
      fullName: _nameCtrl.text,
      phone: _phoneCtrl.text,
      idType: _idType,
      idNumber: _idNumCtrl.text.isEmpty ? null : _idNumCtrl.text,
      kycStatus: _idNumCtrl.text.isNotEmpty ? KycStatus.pending : KycStatus.unverified,
      totalTransactions: 0,
      totalVolume: 0,
      createdAt: DateTime.now(),
    );
    ref.read(customersProvider.notifier).update((list) => [...list, newCustomer]);
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_done) return Scaffold(
      backgroundColor: c.surface,
      body: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('✅', style: TextStyle(fontSize: 72)),
        const SizedBox(height: 16),
        Text('Customer Added!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.green)),
        const SizedBox(height: 8),
        Text('${_nameCtrl.text} has been registered.', style: TextStyle(fontSize: 14, color: c.muted)),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          AppButton(label: 'Add Another', variant: AppButtonVariant.outline, onPressed: () => setState(() { _done = false; _nameCtrl.clear(); _phoneCtrl.clear(); _idNumCtrl.clear(); })),
          const SizedBox(width: 10),
          AppButton(label: 'View Customers', onPressed: () => Navigator.of(context).pop()),
        ]),
      ]))),
    );

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(title: 'Add Customer', onBack: () => Navigator.of(context).pop()),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📷 Add Photo (Optional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Center(child: Container(width: 72, height: 72, decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.border, width: 2, style: BorderStyle.solid)),
              child: Icon(Icons.camera_alt_outlined, size: 28, color: c.muted))),
          ])),
          const SizedBox(height: 12),
          AppCard(child: Column(children: [
            AppTextField(label: 'FULL NAME', controller: _nameCtrl, placeholder: "Customer's full name", onChanged: (_) => setState(() {})),
            const SizedBox(height: 12),
            AppTextField(label: 'PHONE NUMBER', controller: _phoneCtrl, placeholder: '024 XXX XXXX', keyboardType: TextInputType.phone, onChanged: (_) => setState(() {})),
          ])),
          const SizedBox(height: 12),
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ID TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.slate, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, children: IdType.values.map((t) {
              final sel = _idType == t;
              return ChoiceChip(label: Text(t.label, style: const TextStyle(fontSize: 12)), selected: sel,
                onSelected: (_) => setState(() => _idType = t),
                selectedColor: c.greenLight,
                labelStyle: TextStyle(color: sel ? c.green : c.slate, fontWeight: FontWeight.w700));
            }).toList()),
            const SizedBox(height: 12),
            AppTextField(label: 'ID NUMBER (Optional)', controller: _idNumCtrl, placeholder: 'GHA-XXXXXXXXX-X'),
          ])),
          const SizedBox(height: 16),
          AppButton(label: 'Register Customer ✓', width: double.infinity, onPressed: _valid ? _save : null),
        ],
      ),
    );
  }
}
