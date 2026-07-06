import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_widgets.dart';

/// AI Assistant screen using Claude Sonnet 4.6 via Anthropic API.
/// Implements spec §9: Ghana MoMo context, PIN rule, escalation.
///
/// IMPORTANT: In production the API call MUST be proxied through your
/// backend (spec §9.3) — never expose the Anthropic API key on the client.
/// The backend endpoint should be: POST /ai/chat (spec §5)
/// which forwards to Anthropic with the system prompt server-side.
///
/// For development/demo, the key is passed from a build-time env variable:
///   flutter run --dart-define=ANTHROPIC_API_KEY=sk-ant-...
/// Never commit a real key to version control.

const _systemPrompt = '''
You are the AI Assistant inside Agent Pro Ghana — a Mobile Money super app 
for Ghanaian MoMo agents, business owners, managers, and aggregators.

Your role: help users understand how to use the app, guide them through 
Mobile Money operations, explain commission structures, float management, 
USSD workflows, and business reporting.

Ghana context:
- Currency: GH₵ (Ghanaian Cedi)
- MoMo providers: MTN Mobile Money (*170#), Telecel Cash (*110#), AT Money (*500#)
- Typical operations: Cash In, Cash Out, Send Money, Bill Payment, Airtime, Data Bundle
- Commission: typically 1.5% of transaction amount (configurable per Business Owner)
- Float: working capital held by the agent in their MoMo account

CRITICAL RULE — NEVER:
- Ask for, accept, store, or mention Mobile Money PINs
- Suggest the user share any PIN with anyone including yourself
- If a user mentions their PIN, immediately tell them to change it and never share it

Keep responses under 120 words. Be concise, helpful, and Ghana-context aware.
If you cannot help after 3 exchanges, offer to open a support ticket.
''';

// Message model
class _Message {
  final String role; // 'user' | 'assistant'
  final String content;
  final bool isLoading;

  const _Message({required this.role, required this.content, this.isLoading = false});
}

final _suggestedQuestions = [
  'How do I perform a Cash In transaction?',
  'Why is my float balance low?',
  'How is my commission calculated?',
  'How do I add a new agent to my branch?',
  'What is the USSD code for MTN MoMo?',
  'How do I request a payout?',
];

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final List<_Message> _messages = [];
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  int _failedCount = 0;

  // Retrieve the API key injected at build time.
  // In production this is replaced by a backend proxy call.
  static const _apiKey = String.fromEnvironment('ANTHROPIC_API_KEY', defaultValue: '');

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    _inputController.clear();

    setState(() {
      _messages.add(_Message(role: 'user', content: text));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Build message history for multi-turn context (spec §9.3)
      final history = _messages
          .where((m) => !m.isLoading)
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-6',
          'max_tokens': 512,
          'system': _systemPrompt,
          'messages': history,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = (data['content'] as List).firstWhere((c) => c['type'] == 'text')['text'] as String;
        _failedCount = 0;
        setState(() {
          _isLoading = false;
          _messages.add(_Message(role: 'assistant', content: reply));
        });
      } else {
        _handleError();
      }
    } catch (_) {
      _handleError();
    }
    _scrollToBottom();
  }

  void _handleError() {
    _failedCount++;
    final msg = _failedCount >= 3
        ? 'I\'m having trouble connecting. Would you like me to open a support ticket instead?'
        : 'Having trouble connecting. Please try again in a moment.';
    setState(() {
      _isLoading = false;
      _messages.add(_Message(role: 'assistant', content: msg));
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        title: 'AI Assistant',
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: c.greenLight, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 7, height: 7, decoration: BoxDecoration(color: c.green, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('Claude Sonnet 4.6', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.green)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Chat area
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState(c) : _buildMessageList(c),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 14),
            decoration: BoxDecoration(
              color: c.white,
              border: Border(top: BorderSide(color: c.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: c.border, width: 1.5),
                    ),
                    child: TextField(
                      controller: _inputController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onSubmitted: _send,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything about Agent Pro Ghana...',
                        hintStyle: TextStyle(fontSize: 13, color: c.muted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => _send(_inputController.text),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isLoading ? c.muted : c.green,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors c) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        Center(child: Text('🤖', style: TextStyle(fontSize: 56, color: c.green))),
        const SizedBox(height: 12),
        const Center(child: Text('AI Assistant', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22))),
        const SizedBox(height: 4),
        Center(child: Text('Powered by Claude Sonnet 4.6', style: TextStyle(fontSize: 13, color: c.muted))),
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: c.redLight, borderRadius: BorderRadius.circular(20)),
            child: Text('🔒 Never asks for your MoMo PIN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.red)),
          ),
        ),
        const SizedBox(height: 24),
        Text('SUGGESTED QUESTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.muted, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        ..._suggestedQuestions.map((q) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _send(q),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: c.white,
                    border: Border.all(color: c.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text('💬', style: TextStyle(fontSize: 16, color: c.green)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(q, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                      Icon(Icons.chevron_right, size: 16, color: c.muted),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildMessageList(AppColors c) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(13),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == _messages.length) {
          // Loading bubble
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10, right: 60),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: c.white,
                border: Border.all(color: c.border),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Dot(c.muted, delay: 0),
                  const SizedBox(width: 4),
                  _Dot(c.muted, delay: 150),
                  const SizedBox(width: 4),
                  _Dot(c.muted, delay: 300),
                ],
              ),
            ),
          );
        }

        final msg = _messages[i];
        final isUser = msg.role == 'user';

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(
              bottom: 10,
              left: isUser ? 60 : 0,
              right: isUser ? 0 : 60,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? c.green : c.white,
              border: isUser ? null : Border.all(color: c.border),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
            ),
            child: Text(
              msg.content,
              style: TextStyle(fontSize: 14, color: isUser ? Colors.white : c.charcoal, height: 1.5),
            ),
          ),
        );
      },
    );
  }
}

/// Simple animated loading dot.
class _Dot extends StatefulWidget {
  final Color color;
  final int delay;
  const _Dot(this.color, {required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.3 + _anim.value * 0.7),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
