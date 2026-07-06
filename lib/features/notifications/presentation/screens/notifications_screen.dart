import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';

enum NotifType { transaction, float, commission, subscription, fraud, system }

class AppNotification {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final String time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });

  String get icon => switch (type) {
        NotifType.transaction => '💸',
        NotifType.float => '📊',
        NotifType.commission => '💰',
        NotifType.subscription => '💳',
        NotifType.fraud => '🚨',
        NotifType.system => '⚙️',
      };

  Color color(AppColors c) => switch (type) {
        NotifType.transaction => c.green,
        NotifType.float => c.blue,
        NotifType.commission => c.gold,
        NotifType.subscription => c.purple,
        NotifType.fraud => c.red,
        NotifType.system => c.muted,
      };
}

final notificationsProvider = StateProvider<List<AppNotification>>((_) => [
  AppNotification(id: '1', type: NotifType.transaction, title: 'Cash In Successful', body: 'GH₵ 500 received from Ama Boateng · MTN MoMo · Ref: TXN-A1B2C3', time: '10:42 AM'),
  AppNotification(id: '2', type: NotifType.float, title: '⚠ MTN Float Low', body: 'MTN MoMo balance GH₵ 2,400 is below your threshold of GH₵ 2,500. Top up now.', time: '10:15 AM'),
  AppNotification(id: '3', type: NotifType.commission, title: 'Commission Milestone 🎉', body: "You've earned GH₵ 200 commission today — your best day this week!", time: '9:30 AM'),
  AppNotification(id: '4', type: NotifType.transaction, title: 'Cash Out Completed', body: 'GH₵ 300 paid to Kofi Mensah · Telecel Cash · Ref: TXN-D4E5F6', time: '9:15 AM'),
  AppNotification(id: '5', type: NotifType.fraud, title: 'Security Alert', body: 'Unusual login attempt detected from a new device in Kumasi. Not you? Change your password immediately.', time: 'Yesterday 11:00 PM', isRead: true),
  AppNotification(id: '6', type: NotifType.subscription, title: 'Subscription Renewing Soon', body: 'Your Business Plan renews in 50 days on Aug 15, 2026. GH₵ 10.00 will be charged via MTN MoMo.', time: 'Yesterday 9:00 AM', isRead: true),
  AppNotification(id: '7', type: NotifType.system, title: 'App Updated to v1.0.1', body: 'Performance improvements and bug fixes. See what\'s new in App Info.', time: 'Jun 24', isRead: true),
]);

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final notifs = ref.watch(notificationsProvider);
    final unreadCount = notifs.where((n) => !n.isRead).length;

    final filtered = _filter == 'All'
        ? notifs
        : notifs.where((n) => n.type.name.toLowerCase() == _filter.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        title: 'Notifications',
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).update(
                    (list) => list.map((n) => n..isRead = true).toList(),
                  ),
              child: const Text('Mark all read'),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: () => Navigator.of(context).pushNamed('/notifprefs'),
          ),
        ]),
      ),
      body: Column(
        children: [
          // Unread badge + filter chips
          Container(
            color: c.white,
            padding: const EdgeInsets.fromLTRB(13, 8, 13, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (unreadCount > 0) Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: c.redLight, borderRadius: BorderRadius.circular(20)),
                    child: Text('$unreadCount unread', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c.red)),
                  ),
                ]),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Transaction', 'Float', 'Commission', 'Fraud', 'System'].map((f) {
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
            ]),
          ),
          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('🔔', style: TextStyle(fontSize: 48, color: c.muted)),
                    const SizedBox(height: 12),
                    Text('No notifications', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: c.muted)),
                  ]))
                : ListView.separated(
                    padding: const EdgeInsets.all(13),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final n = filtered[i];
                      return _NotifCard(notif: n, onTap: () {
                        ref.read(notificationsProvider.notifier).update(
                          (list) => list.map((item) => item.id == n.id ? (item..isRead = true) : item).toList(),
                        );
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = notif.color(c);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? c.white : color.withOpacity(0.05),
          border: Border(
            top: BorderSide(color: c.border),
            right: BorderSide(color: c.border),
            bottom: BorderSide(color: c.border),
            left: BorderSide(color: notif.isRead ? c.border : color, width: notif.isRead ? 1 : 4),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Text(notif.icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(notif.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: notif.isRead ? c.slate : c.charcoal))),
              if (!notif.isRead)
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 4),
            Text(notif.body, style: TextStyle(fontSize: 12, color: c.muted, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(notif.time, style: TextStyle(fontSize: 11, color: c.muted)),
          ])),
        ]),
      ),
    );
  }
}
