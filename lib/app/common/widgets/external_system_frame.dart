import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

/// Displays an external system (AutoCount, Zoho, Terra, etc.) inside the
/// portal.
///
/// - If [embeddable] is true: renders the system via an iframe (works for
///   systems that don't block framing, e.g. Terra).
/// - If [embeddable] is false: renders a branded launch card with a button
///   that opens the system in a new tab (for systems that block iframe
///   embedding via X-Frame-Options, e.g. AutoCount, Zoho).
class ExternalSystemFrame extends StatefulWidget {
  final String url;
  final String systemKey; // e.g. 'autocount', 'zoho', 'terra'
  final String systemName; // display name, e.g. 'AutoCount'
  final bool embeddable; // false = show launch card instead of iframe
  final String? description; // shown on launch card only
  final IconData icon;
  final Color accentColor;

  const ExternalSystemFrame({
    super.key,
    required this.url,
    required this.systemKey,
    required this.systemName,
    this.embeddable = true,
    this.description,
    this.icon = Icons.apps_rounded,
    this.accentColor = const Color(0xFF185FA5),
  });

  @override
  State<ExternalSystemFrame> createState() => _ExternalSystemFrameState();
}

class _ExternalSystemFrameState extends State<ExternalSystemFrame> {
  // Keep track of which viewTypes have already been registered so we
  // don't call registerViewFactory twice for the same key (it throws
  // if you re-register the same viewId).
  static final Set<String> _registeredViewTypes = {};

  String? _viewId;

  @override
  void initState() {
    super.initState();
    if (widget.embeddable) {
      _viewId = 'external-iframe-${widget.systemKey}';
      if (!_registeredViewTypes.contains(_viewId)) {
        ui_web.platformViewRegistry.registerViewFactory(_viewId!, (int viewId) {
          final iframe = html.IFrameElement()
            ..src = widget.url
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allow = 'clipboard-read; clipboard-write; fullscreen'
            ..allowFullscreen = true;
          return iframe;
        });
        _registeredViewTypes.add(_viewId!);
      }
    }
  }

  Future<void> _openExternal() async {
    html.window.open(
      widget.url,
      'external_${widget.systemKey}', // nama unique per system — reuse window kalau diklik lagi
      'width=1400,height=900,left=100,top=50,resizable=yes,scrollbars=yes,toolbar=yes,location=yes',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embeddable) {
      return HtmlElementView(viewType: _viewId!);
    }
    return _LaunchCard(
      systemName: widget.systemName,
      description: widget.description ??
          'Sistem ini dihoskan secara berasingan oleh ${widget.systemName}.',
      icon: widget.icon,
      accentColor: widget.accentColor,
      onTap: _openExternal,
    );
  }
}

class _LaunchCard extends StatelessWidget {
  final String systemName;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _LaunchCard({
    required this.systemName,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: const Color(0xFFF4F7FC),
      child: Center(
        child: Container(
          width: isMobile ? double.infinity : 420,
          margin: EdgeInsets.all(isMobile ? 20 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 34),
              ),
              const SizedBox(height: 20),
              Text(
                systemName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1E28),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text('Open $systemName'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Will open in a separate window',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}