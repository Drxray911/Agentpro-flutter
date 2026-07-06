import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/ecash_models.dart';

// State providers
final ecashBalanceProvider = StateProvider<ECashBalance>((_) => const ECashBalance(walletId: 'APG-KA-00421', balance: 1250.00));
final ecashHistoryProvider = StateProvider<List<ECashTransaction>>((_) => ECashTransaction.demoList());
final ecashRequestsProvider = StateProvider<List<ECashRequest>>((_) => ECashRequest.demoPending());

class EcashScreen extends ConsumerStatefulWidget {
  const EcashScreen({super.key});

  @override
  ConsumerState<EcashScreen> createState() => _EcashScreenState();
}

class _EcashScreenState extends ConsumerState<EcashScreen> {
  String _tab = 'Send';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final balance = ref.watch(ecashBalanceProvider);
    final pendingCount = ref.watch(ecashRequestsProvider.select((list) => list.where((r) => r.status == ECashRequestStatus.pending).length));

    return Scaffold(
      backgroundColor: c.surface,
      appBar: const AppTopBar(title: 'eCash Wallet'),
      body: Column(
        children: [
          // Wallet card
          Container(
            margin: const EdgeInsets.all(13),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c.purple, const Color(0xFF5B21B6)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ECASH WALLET', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 4),
              Text('GH₵ ${balance.balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 4),
              Text('ID: ${balance.walletId}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
            ]),
          ),
          // Tabs
          AppTabs(
            tabs: ['Send', 'Receive', 'Request', 'History', 'Approvals${pendingCount > 0 ? " ($pendingCount)" : ""}'],
            active: _tab,
            onChanged: (t) => setState(() => _tab = t.split(' ').first),
          ),
          Expanded(
            child: switch (_tab) {
              'Receive' => const _ReceiveTab(),
              'Request' => const _RequestTab(),
              'History' => const _HistoryTab(),
              'Approvals' => const _ApprovalsTab(),
              _ => const _SendTab(),
            },
          ),
        ],
      ),
    );
  }
}

// ── Send tab ──────────────────────────────────────────────────────────
class _SendTab extends ConsumerStatefulWidget {
  const _SendTab();

  @override
  ConsumerState<_SendTab> createState() => _SendTabState();
}

class _SendTabState extends ConsumerState<_SendTab> {
  final _idCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _done = false;
  late String _ref;

  @override
  void dispose() { _idCtrl.dispose(); _amountCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }

  double get _amount => double.tryParse(_amountCtrl.text) ?? 0;
  bool get _valid => _idCtrl.text.isNotEmpty && _amount > 0;

  void _send() {
    _ref = 'ECH-${Random().nextInt(90000000) + 10000000}';
    final balance = ref.read(ecashBalanceProvider);
    ref.read(ecashBalanceProvider.notifier).state = ECashBalance(walletId: balance.walletId, balance: balance.balance - _amount);
    final newTxn = ECashTransaction(id: DateTime.now().millisecondsSinceEpoch.toString(), reference: _ref, type: ECashTransactionType.sent, counterpartyName: _idCtrl.text, counterpartyId: _idCtrl.text, amount: _amount, note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text, createdAt: DateTime.now());
    ref.read(ecashHistoryProvider.notifier).update((list) => [newTxn, ...list]);
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (_done) return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('📤', style: TextStyle(fontSize: 72)),
      const SizedBox(height: 16),
      Text('eCash Sent!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.green)),
      const SizedBox(height: 8),
      Text('GH₵ ${_amount.toStringAsFixed(2)} sent to ${_idCtrl.text}', style: TextStyle(fontSize: 14, color: c.muted)),
      const SizedBox(height: 4),
      Text('Ref: $_ref', style: TextStyle(fontSize: 12, color: c.muted)),
      const SizedBox(height: 24),
      AppButton(label: 'Send Another', onPressed: () => setState(() { _done = false; _idCtrl.clear(); _amountCtrl.clear(); _noteCtrl.clear(); })),
    ])));

    return ListView(padding: const EdgeInsets.all(14), children: [
      AppCard(child: Column(children: [
        AppTextField(label: 'RECIPIENT WALLET ID OR PHONE', controller: _idCtrl, placeholder: 'APG-XX-XXXXX or 024 XXX XXXX', onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        AppTextField(label: 'AMOUNT (GH₵)', controller: _amountCtrl, placeholder: '0.00', keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
        const SizedBox(height: 10),
        Wrap(spacing: 6, children: [100, 200, 500, 1000].map((v) => ActionChip(label: Text('+$v'), onPressed: () => setState(() => _amountCtrl.text = v.toString()))).toList()),
        const SizedBox(height: 12),
        AppTextField(label: 'NOTE (OPTIONAL)', controller: _noteCtrl, placeholder: 'e.g. Float assistance'),
      ])),
      if (_amount > 0) ...[
        const SizedBox(height: 12),
        AppCard(backgroundColor: c.greenLight, borderColor: c.green.withOpacity(0.3), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Sending', style: TextStyle(fontSize: 13, color: c.muted)),
          Text('GH₵ ${_amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: c.green)),
        ])),
      ],
      const SizedBox(height: 16),
      AppButton(label: 'Send eCash →', width: double.infinity, onPressed: _valid ? _send : null),
    ]);
  }
}

// ── Receive tab ───────────────────────────────────────────────────────
class _ReceiveTab extends ConsumerWidget {
  const _ReceiveTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final balance = ref.watch(ecashBalanceProvider);
    return Center(
      child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 160, height: 160, decoration: BoxDecoration(color: c.greenLight, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.green, width: 2)),
          alignment: Alignment.center, child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('📱', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(balance.walletId, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: c.green)),
            Text('eCash QR', style: TextStyle(fontSize: 10, color: c.muted)),
          ])),
        const SizedBox(height: 20),
        Text('Your Wallet ID', style: TextStyle(fontSize: 13, color: c.muted)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(color: c.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.border)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(balance.walletId, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: c.charcoal, letterSpacing: 0.5)),
            const SizedBox(width: 10),
            Icon(Icons.copy, size: 18, color: c.muted),
          ]),
        ),
        const SizedBox(height: 20),
        Text('Share this ID or QR code to receive eCash from other Agent Pro Ghana users.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.muted, height: 1.6)),
        const SizedBox(height: 20),
        AppButton(label: '📤 Share Wallet ID', variant: AppButtonVariant.outline, onPressed: () {}),
      ])),
    );
  }
}

// ── Request tab ───────────────────────────────────────────────────────
class _RequestTab extends ConsumerStatefulWidget {
  const _RequestTab();

  @override
  ConsumerState<_RequestTab> createState() => _RequestTabState();
}

class _RequestTabState extends ConsumerState<_RequestTab> {
  final _idCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() { _idCtrl.dispose(); _amountCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (_sent) return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('📨', style: TextStyle(fontSize: 72)),
      const SizedBox(height: 16),
      Text('Request Sent!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.green)),
      const SizedBox(height: 8),
      Text('Your manager has been notified.', style: TextStyle(fontSize: 14, color: c.muted)),
      const SizedBox(height: 24),
      AppButton(label: 'New Request', onPressed: () => setState(() { _sent = false; _idCtrl.clear(); _amountCtrl.clear(); _noteCtrl.clear(); })),
    ])));

    return ListView(padding: const EdgeInsets.all(14), children: [
      AppCard(child: Column(children: [
        AppTextField(label: 'REQUEST FROM (WALLET ID OR PHONE)', controller: _idCtrl, placeholder: 'Manager / Wallet ID', onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        AppTextField(label: 'AMOUNT NEEDED (GH₵)', controller: _amountCtrl, placeholder: '0.00', keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        AppTextField(label: 'REASON', controller: _noteCtrl, placeholder: 'e.g. Float top-up for weekend'),
      ])),
      const SizedBox(height: 16),
      AppButton(
        label: 'Send Request →',
        width: double.infinity,
        onPressed: _idCtrl.text.isNotEmpty && _amountCtrl.text.isNotEmpty ? () => setState(() => _sent = true) : null,
      ),
    ]);
  }
}

// ── History tab ───────────────────────────────────────────────────────
class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final txns = ref.watch(ecashHistoryProvider);
    return ListView.separated(
      padding: const EdgeInsets.all(13),
      itemCount: txns.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final t = txns[i];
        return AppCard(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ECashDetailScreen(transaction: t))),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: t.isCredit ? c.greenLight : c.purpleLight, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Icon(t.isCredit ? Icons.south_west_rounded : Icons.north_east_rounded, size: 20, color: t.isCredit ? c.green : c.purple),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.type == ECashTransactionType.sent ? 'Sent to ${t.counterpartyName}' : 'Received from ${t.counterpartyName}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              if (t.note != null) Text(t.note!, style: TextStyle(fontSize: 11, color: c.muted)),
              Text(DateFormat('MMM d, h:mm a').format(t.createdAt), style: TextStyle(fontSize: 11, color: c.muted)),
            ])),
            Text('${t.isCredit ? '+' : '-'}GH₵ ${t.amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: t.isCredit ? c.green : c.charcoal)),
          ]),
        );
      },
    );
  }
}

// ── Approvals tab (manager) ───────────────────────────────────────────
class _ApprovalsTab extends ConsumerWidget {
  const _ApprovalsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final requests = ref.watch(ecashRequestsProvider);
    final pending = requests.where((r) => r.status == ECashRequestStatus.pending).toList();
    final done = requests.where((r) => r.status != ECashRequestStatus.pending).toList();

    void act(ECashRequest req, ECashRequestStatus status) {
      ref.read(ecashRequestsProvider.notifier).update((list) => list.map((r) => r.id == req.id ? (r..status = status) : r).toList());
      if (status == ECashRequestStatus.approved) {
        final bal = ref.read(ecashBalanceProvider);
        ref.read(ecashBalanceProvider.notifier).state = ECashBalance(walletId: bal.walletId, balance: bal.balance + req.amount);
      }
    }

    return ListView(padding: const EdgeInsets.all(13), children: [
      if (pending.isEmpty) AppCard(
        child: Column(children: [
          Icon(Icons.check_circle, color: c.green, size: 36),
          const SizedBox(height: 8),
          const Text('All caught up!', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('No pending eCash requests', style: TextStyle(fontSize: 13, color: c.muted)),
        ]),
      ),
      if (pending.isNotEmpty) ...[
        Text('PENDING APPROVAL', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.muted)),
        const SizedBox(height: 8),
        ...pending.map((req) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AccentCard(accentColor: c.gold, backgroundColor: c.goldLight, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(req.fromName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                Text(DateFormat('MMM d · h:mm a').format(req.createdAt), style: TextStyle(fontSize: 11, color: context.colors.muted)),
              ]),
              Text('GH₵ ${req.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: c.green)),
            ]),
            if (req.note != null) ...[
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(8)), child: Text('💬 "${req.note}"', style: TextStyle(fontSize: 12, color: c.slate))),
            ],
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: AppButton(label: '✓ Approve', onPressed: () => act(req, ECashRequestStatus.approved))),
              const SizedBox(width: 10),
              Expanded(child: AppButton(label: '✕ Reject', variant: AppButtonVariant.danger, onPressed: () => act(req, ECashRequestStatus.rejected))),
            ]),
          ])),
        )),
      ],
      if (done.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text('RECENT DECISIONS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.muted)),
        const SizedBox(height: 8),
        ...done.map((req) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(req.fromName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text('GH₵ ${req.amount.toStringAsFixed(0)} · ${DateFormat('MMM d').format(req.createdAt)}', style: TextStyle(fontSize: 11, color: c.muted)),
            ])),
            AppBadge(label: req.status == ECashRequestStatus.approved ? 'Approved' : 'Rejected', color: req.status == ECashRequestStatus.approved ? c.green : c.red),
          ])),
        )),
      ],
    ]);
  }
}

// ── eCash Transaction Detail screen ──────────────────────────────────
class ECashDetailScreen extends StatelessWidget {
  final ECashTransaction transaction;
  const ECashDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = transaction;
    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(title: 'eCash Transaction', onBack: () => Navigator.of(context).pop()),
      body: ListView(padding: const EdgeInsets.all(13), children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c.purple, const Color(0xFF5B21B6)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Icon(t.isCredit ? Icons.south_west_rounded : Icons.north_east_rounded, size: 44, color: Colors.white),
            const SizedBox(height: 12),
            Text('GH₵ ${t.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 4),
            Text('eCash ${t.type.name[0].toUpperCase()}${t.type.name.substring(1)}', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85))),
          ]),
        ),
        const SizedBox(height: 14),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Transfer Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 10),
          ...[
            ['From', t.isCredit ? t.counterpartyName : 'You'],
            ['To', t.isCredit ? 'You' : t.counterpartyName],
            ['Amount', 'GH₵ ${t.amount.toStringAsFixed(2)}'],
            if (t.note != null) ['Note', t.note!],
            ['Reference', t.reference],
            ['Date & Time', DateFormat('MMM d, yyyy · h:mm a').format(t.createdAt)],
            ['Status', 'Completed'],
          ].asMap().entries.map((entry) {
            final isLast = entry.key == (t.note != null ? 6 : 5);
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: c.border))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(entry.value[0], style: TextStyle(color: c.muted, fontSize: 13)),
                Text(entry.value[1], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ]),
            );
          }),
        ])),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: AppButton(label: '📤 Share Receipt', variant: AppButtonVariant.outline, onPressed: () {})),
          const SizedBox(width: 10),
          Expanded(child: AppButton(label: '↩ Refund', variant: AppButtonVariant.ghost, onPressed: () {})),
        ]),
      ]),
    );
  }
}
