import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/support_provider.dart';
import '../../services/api/support_service.dart';
import 'create_ticket_screen.dart';

class SupportScreen extends StatefulWidget {
  final String? prefilledOrderId;

  const SupportScreen({super.key, this.prefilledOrderId});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  static const _darkGreen = Color(0xFF0F2A1A);
  static const _accentGreen = Color(0xFF1E5C3A);
  static const _gold = Color(0xFFC88B1A);
  static const _cream = Color(0xFFF4F2EC);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SupportProvider>().loadTickets());
  }

  ({Color bg, Color text, String label}) _statusStyle(String status) {
    switch (status) {
      case 'RESOLVED':
      case 'CLOSED':
        return (
          bg: const Color(0xFFE8F9EE),
          text: _accentGreen,
          label: 'Resolved',
        );
      case 'IN_PROGRESS':
        return (
          bg: const Color(0xFFFFF8E1),
          text: _gold,
          label: 'In Progress',
        );
      default:
        return (
          bg: const Color(0xFFEDF2FF),
          text: const Color(0xFF3B5BDB),
          label: 'Open',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF1C1A17),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Help & Support',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.w900,
                        color: _darkGreen,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _openCreateTicket(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _accentGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // FAQ quick-help tiles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _faqTile(Icons.receipt_long_rounded, 'Order Issue', Colors.orange),
                  const SizedBox(width: 10),
                  _faqTile(Icons.payment_rounded, 'Payment', const Color(0xFF5B6AF0)),
                  const SizedBox(width: 10),
                  _faqTile(Icons.delivery_dining_rounded, 'Delivery', _accentGreen),
                  const SizedBox(width: 10),
                  _faqTile(Icons.help_outline_rounded, 'Other', const Color(0xFF8B5CF6)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'MY TICKETS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Color(0xFF9A9690),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(height: 1, color: const Color(0xFFE8E6E0)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Consumer<SupportProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(_darkGreen),
                      ),
                    );
                  }

                  if (provider.tickets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.support_agent_rounded,
                              size: 36,
                              color: Color(0xFFCECCC8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No support tickets',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Georgia',
                              fontWeight: FontWeight.w700,
                              color: _darkGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Need help? Create a ticket and\nour team will respond shortly.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8A8884),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _openCreateTicket,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Create Ticket',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: provider.tickets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        _buildTicketCard(provider.tickets[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateTicket() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateTicketScreen(
          prefilledOrderId: widget.prefilledOrderId,
        ),
      ),
    );
    if (result == true && mounted) {
      context.read<SupportProvider>().loadTickets();
    }
  }

  Widget _faqTile(IconData icon, String label, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _openCreateTicketWithCategory(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A3835),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCreateTicketWithCategory(String label) async {
    String category = 'GENERAL';
    if (label == 'Order Issue') category = 'ORDER';
    if (label == 'Payment') category = 'PAYMENT';
    if (label == 'Delivery') category = 'DELIVERY';

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateTicketScreen(
          prefilledOrderId: widget.prefilledOrderId,
          prefilledCategory: category,
        ),
      ),
    );
    if (result == true && mounted) {
      context.read<SupportProvider>().loadTickets();
    }
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    final st = _statusStyle(ticket.status);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  ticket.subject,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1A17),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: st.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  st.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: st.text,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ticket.category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6A6865),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFAFADAA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
