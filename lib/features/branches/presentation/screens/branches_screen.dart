import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../data/branch_repository.dart';
import '../../domain/branch_models.dart';

class BranchesScreen extends ConsumerStatefulWidget {
  const BranchesScreen({super.key});

  @override
  ConsumerState<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends ConsumerState<BranchesScreen> {
  String _tab = 'Branches';
  bool _showAddBranch = false;
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _region = 'Greater Accra';

  static const _regions = ['Greater Accra','Ashanti','Western','Central','Eastern','Volta','Northern','Upper East','Upper West','Bono'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        title: 'Branches & Staff',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StaffInviteScreen())),
              child: const Text('📨 Invite'),
            ),
            const SizedBox(width: 4),
            FilledButton(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
              onPressed: () => setState(() => _showAddBranch = true),
              child: const Text('+ Add', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          AppTabs(
            tabs: const ['Branches', 'Agents', 'Managers'],
            active: _tab,
            onChanged: (t) => setState(() => _tab = t),
          ),
          if (_showAddBranch) _AddBranchSheet(
            nameCtrl: _nameCtrl,
            locationCtrl: _locationCtrl,
            region: _region,
            regions: _regions,
            onRegionChanged: (r) => setState(() => _region = r),
            onCancel: () => setState(() { _showAddBranch = false; _nameCtrl.clear(); _locationCtrl.clear(); }),
            onSubmit: () async {
              if (_nameCtrl.text.isEmpty) return;
              await ref.read(branchRepositoryProvider).createBranch(
                name: _nameCtrl.text,
                location: _locationCtrl.text,
                region: _region,
              );
              ref.invalidate(branchListProvider);
              setState(() { _showAddBranch = false; _nameCtrl.clear(); _locationCtrl.clear(); });
            },
          ),
          Expanded(
            child: switch (_tab) {
              'Agents' => _StaffTab(role: 'agent'),
              'Managers' => _StaffTab(role: 'manager'),
              _ => const _BranchesTab(),
            },
          ),
        ],
      ),
    );
  }
}

// ── Add Branch inline form ────────────────────────────────────────────
class _AddBranchSheet extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController locationCtrl;
  final String region;
  final List<String> regions;
  final ValueChanged<String> onRegionChanged;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _AddBranchSheet({required this.nameCtrl, required this.locationCtrl, required this.region, required this.regions, required this.onRegionChanged, required this.onCancel, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.all(13),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: c.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Branch', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: c.charcoal)),
          const SizedBox(height: 12),
          AppTextField(label: 'BRANCH NAME', controller: nameCtrl, placeholder: 'e.g. Accra Central'),
          const SizedBox(height: 10),
          AppTextField(label: 'ADDRESS', controller: locationCtrl, placeholder: 'Street, City'),
          const SizedBox(height: 10),
          Text('REGION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.slate, letterSpacing: 0.5)),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(11), border: Border.all(color: c.border, width: 1.5)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: region,
                isExpanded: true,
                items: regions.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 14)))).toList(),
                onChanged: (r) => r != null ? onRegionChanged(r) : null,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: AppButton(label: 'Cancel', variant: AppButtonVariant.ghost, onPressed: onCancel)),
              const SizedBox(width: 10),
              Expanded(child: AppButton(label: 'Create Branch', onPressed: onSubmit)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Branches list tab ─────────────────────────────────────────────────
class _BranchesTab extends ConsumerWidget {
  const _BranchesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final branchAsync = ref.watch(branchListProvider);

    return branchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e', style: TextStyle(color: c.red))),
      data: (branches) => RefreshIndicator(
        onRefresh: () => ref.read(branchListProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(13),
          children: [
            // Summary row
            Row(children: [
              _MiniStatCard(label: 'Total Branches', value: '${branches.length}', color: c.green),
              const SizedBox(width: 10),
              _MiniStatCard(label: 'Active', value: '${branches.where((b) => b.isActive).length}', color: c.gold),
              const SizedBox(width: 10),
              _MiniStatCard(label: 'Inactive', value: '${branches.where((b) => !b.isActive).length}', color: c.muted),
            ]),
            const SizedBox(height: 12),
            ...branches.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BranchDetailScreen(branch: b))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                  if (b.location != null) Text(b.location!, style: TextStyle(fontSize: 12, color: c.muted)),
                                ],
                              ),
                            ),
                            AppBadge(label: b.isActive ? 'Active' : 'Inactive', color: b.isActive ? c.green : c.muted),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(children: [
                          _StatPill('👥 ${b.agentCount} agents', c),
                          const SizedBox(width: 8),
                          _StatPill('GH₵ ${(b.totalFloat / 1000).toStringAsFixed(1)}k float', c),
                          if (b.region != null) ...[const SizedBox(width: 8), _StatPill('📍 ${b.region}', c)],
                        ]),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: c.white, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: c.muted), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String text;
  final AppColors c;
  const _StatPill(this.text, this.c);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.border)),
        child: Text(text, style: TextStyle(fontSize: 11, color: c.slate, fontWeight: FontWeight.w600)),
      );
}

// ── Staff list tab ─────────────────────────────────────────────────────
class _StaffTab extends ConsumerWidget {
  final String role;
  const _StaffTab({required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final staffAsync = ref.watch(staffListProvider);

    return staffAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e', style: TextStyle(color: c.red))),
      data: (staff) {
        final filtered = staff.where((s) => s.role == role).toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 10, 13, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${filtered.length} ${role}s', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.muted)),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StaffInviteScreen())),
                    child: Text('📈 Leaderboard →'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final s = filtered[i];
                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: c.greenLight, borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: Text(s.initials, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: c.green)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                              Text('${s.phone} · ${s.branchName}', style: TextStyle(fontSize: 12, color: c.muted)),
                              if (s.role == 'agent')
                                Text('Today: ${s.todayTransactions} txns · GH₵ ${s.todayCommission.toStringAsFixed(0)} commission', style: TextStyle(fontSize: 11, color: c.green, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        AppBadge(label: s.status, color: s.isActive ? c.green : c.red),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Branch Detail screen ──────────────────────────────────────────────
class BranchDetailScreen extends ConsumerStatefulWidget {
  final Branch branch;
  const BranchDetailScreen({super.key, required this.branch});

  @override
  ConsumerState<BranchDetailScreen> createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends ConsumerState<BranchDetailScreen> {
  String _tab = 'Overview';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final b = widget.branch;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        title: b.name,
        onBack: () => Navigator.of(context).pop(),
        trailing: AppBadge(label: b.isActive ? 'Active' : 'Inactive', color: b.isActive ? c.green : c.muted),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [c.greenDark, c.green])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (b.location != null) Text('📍 ${b.location}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _HeaderStat('TODAY VOL', 'GH₵ 10.8k'),
                    _HeaderStat('TXNS', '42'),
                    _HeaderStat('COMMISSION', 'GH₵ 324', gold: true),
                  ],
                ),
              ],
            ),
          ),
          AppTabs(tabs: const ['Overview', 'Agents', 'Float', 'Reports'], active: _tab, onChanged: (t) => setState(() => _tab = t)),
          Expanded(
            child: switch (_tab) {
              'Agents' => _BranchAgentsTab(branchId: b.id),
              'Float' => _BranchFloatTab(),
              'Reports' => _BranchReportsTab(branchName: b.name),
              _ => _BranchOverviewTab(branch: b),
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final bool gold;
  const _HeaderStat(this.label, this.value, {this.gold = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white60)),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: gold ? const Color(0xFFFDE68A) : Colors.white)),
          ],
        ),
      );
}

class _BranchOverviewTab extends ConsumerWidget {
  final Branch branch;
  const _BranchOverviewTab({required this.branch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        Row(children: [
          _MiniStatCard(label: 'Active Agents', value: '${branch.agentCount}', color: c.green),
          const SizedBox(width: 10),
          _MiniStatCard(label: 'Monthly Txns', value: '482', color: c.gold),
        ]),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Float by Provider', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 10),
              ...[('MTN MoMo', 6200.0, 10000.0, const Color(0xFFFFCC00)),
                  ('Telecel Cash', 3800.0, 6000.0, const Color(0xFFDC143C)),
                  ('AT Money', 2400.0, 5000.0, const Color(0xFF0047AB))].map((p) {
                final ratio = p.$3 == 0 ? 0.0 : p.$2 / p.$3;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(p.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('GH₵ ${p.$2.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ]),
                      const SizedBox(height: 4),
                      ClipRRect(borderRadius: BorderRadius.circular(100), child: LinearProgressIndicator(value: ratio, minHeight: 6, backgroundColor: c.border, color: p.$4)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: AppButton(label: '📈 Top Up Float', onPressed: () {})),
          const SizedBox(width: 10),
          Expanded(child: AppButton(label: '📋 Reports', variant: AppButtonVariant.outline, onPressed: () {})),
        ]),
      ],
    );
  }
}

class _BranchAgentsTab extends ConsumerWidget {
  final String branchId;
  const _BranchAgentsTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final staffAsync = ref.watch(staffListProvider);
    return staffAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (staff) {
        final agents = staff.where((s) => s.branchId == branchId && s.role == 'agent').toList();
        return ListView.separated(
          padding: const EdgeInsets.all(13),
          itemCount: agents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final a = agents[i];
            return AppCard(
              child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: c.greenLight, borderRadius: BorderRadius.circular(11)), alignment: Alignment.center,
                  child: Text(a.initials, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: c.green))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  Text('${a.todayTransactions} txns · GH₵ ${a.todayCommission.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: c.muted)),
                ])),
                AppBadge(label: a.status, color: a.isActive ? c.green : c.red),
              ]),
            );
          },
        );
      },
    );
  }
}

class _BranchFloatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [c.green, c.greenDark]), borderRadius: BorderRadius.circular(16)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TOTAL BRANCH FLOAT', style: TextStyle(fontSize: 11, color: Colors.white70)),
            Text('GH₵ 12,400', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white)),
          ]),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Float History', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 8),
            ...const [('MTN Top-up', '+GH₵ 3,000', 'Today 9:00 AM'), ('Telecel Cash Out', '-GH₵ 800', 'Yesterday 4PM'), ('AT Top-up', '+GH₵ 1,500', 'Jun 24 10AM')]
                .map((m) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(m.$3, style: TextStyle(fontSize: 11, color: context.colors.muted)),
                        ]),
                        Text(m.$2, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: m.$2.startsWith('+') ? context.colors.green : context.colors.red)),
                      ]),
                    )),
          ]),
        ),
      ],
    );
  }
}

class _BranchReportsTab extends StatelessWidget {
  final String branchName;
  const _BranchReportsTab({required this.branchName});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: c.charcoal, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('JUNE 2026 · ${branchName.toUpperCase()}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
            const Text('GH₵ 48,200', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 10),
            Row(children: [
              _HeaderStat('COMMISSION', 'GH₵ 1,450', gold: true),
              _HeaderStat('TRANSACTIONS', '186'),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: AppButton(label: '📄 PDF', variant: AppButtonVariant.outline, onPressed: () {})),
          const SizedBox(width: 10),
          Expanded(child: AppButton(label: '📊 Excel', variant: AppButtonVariant.ghost, onPressed: () {})),
        ]),
      ],
    );
  }
}

// ── Staff Invite screen ───────────────────────────────────────────────
class StaffInviteScreen extends ConsumerStatefulWidget {
  const StaffInviteScreen({super.key});

  @override
  ConsumerState<StaffInviteScreen> createState() => _StaffInviteScreenState();
}

class _StaffInviteScreenState extends ConsumerState<StaffInviteScreen> {
  final _phoneCtrl = TextEditingController();
  String _role = 'agent';
  String _branch = 'Accra Central';
  bool _sent = false;

  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_sent) {
      return Scaffold(
        backgroundColor: c.surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('📨', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              Text('Invitation Sent!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.green)),
              const SizedBox(height: 8),
              Text('SMS sent to ${_phoneCtrl.text} to join $_branch as $_role.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.muted, height: 1.6)),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                AppButton(label: 'Invite Another', variant: AppButtonVariant.outline, onPressed: () => setState(() { _sent = false; _phoneCtrl.clear(); })),
                const SizedBox(width: 10),
                AppButton(label: 'Done', onPressed: () => Navigator.of(context).pop()),
              ]),
            ]),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(title: 'Invite Staff Member', onBack: () => Navigator.of(context).pop()),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          AppCard(
            backgroundColor: c.greenLight,
            borderColor: c.green.withOpacity(0.3),
            child: Text('Enter the new staff member\'s phone. They\'ll receive an SMS with a download link and unique join code.', style: TextStyle(fontSize: 13, color: c.slate, height: 1.6)),
          ),
          const SizedBox(height: 12),
          AppCard(child: AppTextField(label: 'STAFF PHONE NUMBER', controller: _phoneCtrl, placeholder: '024 XXX XXXX', keyboardType: TextInputType.phone)),
          const SizedBox(height: 12),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ROLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.slate, letterSpacing: 0.5)),
              const SizedBox(height: 5),
              ...['agent', 'manager', 'auditor'].map((r) => RadioListTile<String>(
                value: r,
                groupValue: _role,
                onChanged: (v) => setState(() => _role = v!),
                title: Text(r[0].toUpperCase() + r.substring(1), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                activeColor: c.green,
                contentPadding: EdgeInsets.zero,
              )),
            ]),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ASSIGN TO BRANCH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.slate, letterSpacing: 0.5)),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(11), border: Border.all(color: c.border, width: 1.5)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _branch,
                    isExpanded: true,
                    items: ['Accra Central', 'Tema Station', 'Kumasi Kejetia', 'Takoradi Market']
                        .map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 14))))
                        .toList(),
                    onChanged: (v) => setState(() => _branch = v!),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Send Invitation →',
            width: double.infinity,
            onPressed: _phoneCtrl.text.isNotEmpty ? () async {
              try {
                await ref.read(branchRepositoryProvider).inviteStaff(phone: _phoneCtrl.text, role: _role, branchId: '1');
              } catch (_) { /* Demo: proceed regardless */ }
              setState(() => _sent = true);
            } : null,
          ),
        ],
      ),
    );
  }
}
