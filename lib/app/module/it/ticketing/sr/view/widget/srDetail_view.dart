import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/sr_model.dart';
import '../../view model/sr_vm.dart';
import 'package:url_launcher/url_launcher.dart';

class SRDetailPage extends StatelessWidget {
  final String token;
  final VoidCallback onBack;

  const SRDetailPage({
    super.key,
    required this.token,
    required this.onBack,
  });

  static const _brandBlue     = Color(0xFF185FA5);
  static const _brandBlueBg   = Color(0xFFE6F1FB);
  static const _textPrimary   = Color(0xFF1B1E28);
  static const _textSecondary = Color(0xFF6B7280);
  static const _textMuted     = Color(0xFF9CA3AF);
  static const _borderColor   = Color(0xFFE5E7EB);
  static const _bgLight       = Color(0xFFF9FAFB);
  static const _bgField       = Color(0xFFF3F4F6);
  static const String _baseUrl = "http://localhost:8000";

  static const _typeLabels = {
    'asset_request': 'Asset request',
    'software_installation': 'Software installation',
    'account_access': 'Account access',
    'other': 'Other',
  };

  String _typeLabel(String type) => _typeLabels[type] ?? type;

    Future<void> _openAttachment(String? attachmentPath) async {
    if (attachmentPath == null) return;

    final url = '$_baseUrl/storage/$attachmentPath';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceRequestViewModel>(
      builder: (context, vm, _) {
        final sr = vm.selected;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Back button ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: GestureDetector(
                onTap: onBack,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 13, color: _brandBlue),
                    SizedBox(width: 6),
                    Text(
                      'Back to Service Request',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _brandBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (sr == null)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SingleChildScrollView(
                    child: _buildDetailPanel(sr),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Detail panel ─────────────────────────────────────────────────────────

  Widget _buildDetailPanel(ServiceRequestModel sr) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 420;

              final iconBox = Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _brandBlueBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assignment_outlined,
                    color: _brandBlue, size: 20),
              );

              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sr.requestTitle,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary)),
                  const SizedBox(height: 2),
                  Text(sr.srNumber,
                      style: const TextStyle(
                          fontSize: 12,
                          color: _textMuted,
                          fontFamily: 'monospace')),
                ],
              );

              final pills = Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _pill(_statusLabel(sr.status),
                      bg: _statusColors(sr.status).bg,
                      fg: _statusColors(sr.status).fg),
                  _pill(_priorityLabel(sr.priority),
                      bg: _prioColors(sr.priority).bg,
                      fg: _prioColors(sr.priority).fg),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        iconBox,
                        const SizedBox(width: 12),
                        Expanded(child: titleBlock),
                      ],
                    ),
                    const SizedBox(height: 10),
                    pills,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  iconBox,
                  const SizedBox(width: 12),
                  Expanded(child: titleBlock),
                  const SizedBox(width: 8),
                  pills,
                ],
              );
            },
          ),

          const SizedBox(height: 20),
          const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
          const SizedBox(height: 20),

          // ── Row 1: Request type | Category ───────────────────────
          _fieldRow(
            _readonlyField(label: 'Request type', value: _typeLabel(sr.requestType), icon: Icons.apps_outlined),
            _readonlyField(label: 'Category', value: sr.category, icon: Icons.category_outlined),
          ),
          const SizedBox(height: 14),

          // ── Row 2: Quantity | Priority ─────────────────────────────
          _fieldRow(
            _readonlyField(label: 'Quantity/User', value: '${sr.quantity}', icon: Icons.numbers_outlined),
            _readonlyField(label: 'Priority', value: _priorityLabel(sr.priority), icon: Icons.flag_outlined),
          ),
          const SizedBox(height: 14),

          // ── Row 3: Needed by | Submitted ─────────────────────────
          _fieldRow(
            _readonlyField(label: 'Needed by', value: _formatDate(sr.neededByDate), icon: Icons.event_outlined),
            _readonlyField(label: 'Submitted', value: _formatDate(sr.createdAt), icon: Icons.calendar_today_outlined),
          ),
          const SizedBox(height: 14),

          // ── Row 4: Description (full width) ──────────────────────
          _readonlyField(
            label: 'Description',
            value: sr.description,
            icon: Icons.notes_outlined,
            maxLines: 5,
            fullWidth: true,
          ),

          // ── Attachment ───────────────────────────────────────────
          if (sr.attachmentName != null) ...[
            const SizedBox(height: 14),
            InkWell(
              onTap: () => _openAttachment(sr.attachment),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _bgLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 18, color: _textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        sr.attachmentName!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _brandBlue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.open_in_new, size: 14, color: _textMuted),
                  ],
                ),
              ),
            ),
          ],

          // ── Approval status section ───────────────────────────────
          const SizedBox(height: 20),
          const Divider(height: 0.5, thickness: 0.5, color: _borderColor),
          const SizedBox(height: 20),

          Text(
            sr.status == 'pending'
                ? 'Approval status'
                : sr.status == 'approved'
                    ? '✅ Approval status'
                    : '❌ Approval status',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: _brandBlue),
          ),
          const SizedBox(height: 16),

          if (sr.status == 'pending')
            _readonlyField(
              label: 'Status',
              value: 'Awaiting approval',
              icon: Icons.hourglass_empty_outlined,
              fullWidth: true,
            )
          else ...[
            _fieldRow(
              _readonlyField(
                label: sr.status == 'approved' ? 'Approved by' : 'Rejected by',
                value: sr.approverName ?? '—',
                icon: Icons.person_outline,
              ),
              _readonlyField(
                label: 'Reviewed at',
                value: _formatDate(sr.reviewedAt),
                icon: Icons.update_outlined,
              ),
            ),
            if (sr.status == 'rejected' && sr.rejectionReason != null) ...[
              const SizedBox(height: 14),
              _readonlyField(
                label: 'Reason for rejection',
                value: sr.rejectionReason!,
                icon: Icons.gavel_outlined,
                maxLines: 4,
                fullWidth: true,
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _readonlyField({
    required String label,
    required String value,
    required IconData icon,
    int maxLines = 1,
    bool fullWidth = false,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: _textMuted),
        prefixIcon: Icon(icon, size: 18, color: _textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: _bgField,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
      ),
      child: Text(value,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _textPrimary)),
    );
  }

  Widget _fieldRow(Widget a, Widget b) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [a, const SizedBox(height: 12), b],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: a),
            const SizedBox(width: 12),
            Expanded(child: b),
          ],
        );
      },
    );
  }

  Widget _pill(String text, {required Color bg, required Color fg}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      );

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'approved': return 'Approved';
      case 'rejected': return 'Rejected';
      default: return status;
    }
  }

  String _priorityLabel(String p) {
    switch (p) {
      case 'high': return 'High';
      case 'medium': return 'Medium';
      default: return 'Low';
    }
  }

  ({Color bg, Color fg}) _statusColors(String status) {
    switch (status) {
      case 'approved':
        return (bg: const Color(0xFFEAF3DE), fg: const Color(0xFF3B6D11));
      case 'rejected':
        return (bg: const Color(0xFFFCEBEB), fg: const Color(0xFFA32D2D));
      default:
        return (bg: const Color(0xFFFAEEDA), fg: const Color(0xFF854F0B));
    }
  }

  ({Color bg, Color fg}) _prioColors(String p) {
    switch (p) {
      case 'high':
        return (bg: const Color(0xFFFCEBEB), fg: const Color(0xFFA32D2D));
      case 'medium':
        return (bg: const Color(0xFFFAEEDA), fg: const Color(0xFF854F0B));
      default:
        return (bg: const Color(0xFFEAF3DE), fg: const Color(0xFF3B6D11));
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month]} ${dt.year} · $h:$m';
  }
}