import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────────────────────
const _bg = Color(0xFF0A0A0A);
const _surface = Color(0xFF141414);
const _border = Color(0xFF222222);
const _accent = Color(0xFF10B981);
const _accentDim = Color(0xFF064E3B);
const _textPrimary = Color(0xFFF5F5F5);
const _textMuted = Color(0xFF6B7280);
const _textDim = Color(0xFF374151);
const _red = Color(0xFFEF4444);

const _formspreeEndpoint = 'https://formspree.io/f/xppzrgdw';

// ─────────────────────────────────────────────────────────────
//  Page state
// ─────────────────────────────────────────────────────────────
class ComingSoonPage extends StatefulWidget {
  const ComingSoonPage({super.key});

  @override
  State<ComingSoonPage> createState() => _ComingSoonPageState();
}

class _ComingSoonPageState extends State<ComingSoonPage> {
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _error;
  bool _submitted = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool _validEmail(String s) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s.trim());

  // Phone: optional leading +, digits/spaces/dashes, 7–16 chars total
  bool _validPhone(String s) =>
      RegExp(r'^\+?[\d\s\-(]{1,4}[\d\s\-()]{6,14}$').hasMatch(s.trim());

  Future<void> _submit() async {
    if (_loading) return;

    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    setState(() => _error = null);

    // At least one field must be filled
    if (email.isEmpty && phone.isEmpty) {
      setState(
          () => _error = 'Please enter at least your email or phone number.');
      return;
    }
    // Validate email if provided
    if (email.isNotEmpty && !_validEmail(email)) {
      setState(() => _error = 'Enter a valid email address (e.g. you@work.com).');
      return;
    }
    // Validate phone if provided
    if (phone.isNotEmpty && !_validPhone(phone)) {
      setState(() =>
          _error = 'Enter a valid phone number including country code (e.g. +1 555 000 0000).');
      return;
    }

    setState(() => _loading = true);

    try {
      final body = <String, String>{
        if (email.isNotEmpty) 'email': email,
        if (phone.isNotEmpty) 'phone': phone,
        '_subject': 'SnapSalon early access signup',
      };

      final response = await http.post(
        Uri.parse(_formspreeEndpoint),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _submitted = true;
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Something went wrong. Please try again in a moment.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not connect. Check your internet and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;

    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Column(
            children: [
              const _Nav(),
              _divider(),
              _Hero(isMobile: isMobile),
              _divider(),
              _Features(isMobile: isMobile),
              _divider(),
              _EarlyAccessSection(
                isMobile: isMobile,
                emailCtrl: _emailCtrl,
                phoneCtrl: _phoneCtrl,
                error: _error,
                submitted: _submitted,
                loading: _loading,
                onSubmit: _submit,
              ),
              _divider(),
              _Footer(isMobile: isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, thickness: 1, color: _border);
}

// ─────────────────────────────────────────────────────────────
//  Nav
// ─────────────────────────────────────────────────────────────
class _Nav extends StatelessWidget {
  const _Nav();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Row(
          children: const [
            _Logo(),
            Spacer(),
            _StatusBadge(),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'S',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'SnapSalon',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _accentDim,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 7),
          const Text(
            'Coming Soon',
            style: TextStyle(
              color: _accent,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Hero
// ─────────────────────────────────────────────────────────────
class _Hero extends StatelessWidget {
  const _Hero({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 56 : 96,
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(999),
              color: _surface,
            ),
            child: const Text(
              'SALON MANAGEMENT SOFTWARE',
              style: TextStyle(
                color: _textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Run your salon like\na modern business.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textPrimary,
              fontSize: isMobile ? 34 : 60,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: const Text(
              'Employee management, smart bookings, revenue & profit tracking, and loyal customer rewards—all in one clean dashboard.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textMuted,
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: const [
              _Pill('Employee Management'),
              _Pill('Bookings'),
              _Pill('Revenue & Profit'),
              _Pill('Loyal Customers'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Feature grid
// ─────────────────────────────────────────────────────────────
class _Features extends StatelessWidget {
  const _Features({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    const items = [
      _FeatureItem(
        icon: '👥',
        title: 'Employee Management',
        desc: 'Track schedules, shifts, and performance for every team member.',
      ),
      _FeatureItem(
        icon: '📅',
        title: 'Smart Bookings',
        desc: 'Phone-in or walk-in appointments logged in under 10 seconds.',
      ),
      _FeatureItem(
        icon: '💰',
        title: 'Revenue & Profit',
        desc: 'Real-time totals for daily revenue, tips, and net profit.',
      ),
      _FeatureItem(
        icon: '🏆',
        title: 'Loyal Customers',
        desc: 'Build a loyal base with visit history, rewards, and notes.',
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 64,
        vertical: isMobile ? 40 : 64,
      ),
      child: isMobile
          ? Column(
              children: items
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _FeatureCard(item: e),
                      ))
                  .toList(),
            )
          : Row(
              children: items
                  .expand((e) => [
                        Expanded(child: _FeatureCard(item: e)),
                        if (e != items.last) const SizedBox(width: 14),
                      ])
                  .toList(),
            ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem(
      {required this.icon, required this.title, required this.desc});
  final String icon;
  final String title;
  final String desc;
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.item});
  final _FeatureItem item;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hovered ? _surface : _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                _hovered ? _accent.withValues(alpha: 0.3) : _border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.item.icon,
                style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 14),
            Text(
              widget.item.title,
              style: const TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.desc,
              style: const TextStyle(
                color: _textMuted,
                fontSize: 13.5,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Early-access CTA
// ─────────────────────────────────────────────────────────────
class _EarlyAccessSection extends StatelessWidget {
  const _EarlyAccessSection({
    required this.isMobile,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.error,
    required this.submitted,
    required this.loading,
    required this.onSubmit,
  });

  final bool isMobile;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final String? error;
  final bool submitted;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _surface,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 56 : 80,
      ),
      child: Column(
        children: [
          const Text(
            'Be the first to know.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Get early access and an exclusive launch discount.\nEnter your email and/or phone — fill in both if you like!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textMuted,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 36),
          submitted
              ? const _SuccessCard()
              : _Form(
                  isMobile: isMobile,
                  emailCtrl: emailCtrl,
                  phoneCtrl: phoneCtrl,
                  error: error,
                  loading: loading,
                  onSubmit: onSubmit,
                ),
          const SizedBox(height: 20),
          const Text(
            'No spam. Only launch updates and your discount code.',
            style: TextStyle(color: _textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Form — two separate fields stacked vertically
// ─────────────────────────────────────────────────────────────
class _Form extends StatelessWidget {
  const _Form({
    required this.isMobile,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.error,
    required this.loading,
    required this.onSubmit,
  });

  final bool isMobile;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final String? error;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Email field ──────────────────────────────────
          _LabeledField(
            label: 'Email address',
            child: _StyledTextField(
              controller: emailCtrl,
              hint: 'you@yoursalon.com',
              keyboardType: TextInputType.emailAddress,
              enabled: !loading,
              onSubmit: onSubmit,
            ),
          ),
          const SizedBox(height: 12),

          // ── Phone field ──────────────────────────────────
          _LabeledField(
            label: 'Phone number',
            subLabel: 'Include your country code',
            child: _StyledTextField(
              controller: phoneCtrl,
              hint: '+1 555 000 0000',
              keyboardType: TextInputType.phone,
              enabled: !loading,
              onSubmit: onSubmit,
            ),
          ),
          const SizedBox(height: 6),

          // ── Helper hint ──────────────────────────────────
          const Text(
            'Fill in one or both — at least one is required.',
            style: TextStyle(color: _textDim, fontSize: 12),
          ),

          // ── Error ────────────────────────────────────────
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(
              error!,
              style: const TextStyle(color: _red, fontSize: 13),
            ),
          ],

          const SizedBox(height: 20),

          // ── Submit button ────────────────────────────────
          _SubmitButton(onPressed: onSubmit, loading: loading),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.subLabel,
  });

  final String label;
  final String? subLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subLabel != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _accentDim,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  subLabel!,
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.onSubmit,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final VoidCallback onSubmit;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onSubmitted: (_) => onSubmit(),
      keyboardType: keyboardType,
      inputFormatters: [LengthLimitingTextInputFormatter(80)],
      style: const TextStyle(color: _textPrimary, fontSize: 14),
      cursorColor: _accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textDim, fontSize: 14),
        filled: true,
        fillColor: _bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: _accent.withValues(alpha: 0.8)),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  const _SubmitButton({required this.onPressed, required this.loading});
  final VoidCallback onPressed;
  final bool loading;

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.loading;

    return MouseRegion(
      onEnter: (_) {
        if (!disabled) setState(() => _hovered = true);
      },
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: disabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          decoration: BoxDecoration(
            color: disabled
                ? _accent.withValues(alpha: 0.55)
                : (_hovered ? const Color(0xFF0EA472) : _accent),
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.loading
              ? const SizedBox(
                  height: 20,
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
              : const Text(
                  'Get Early Access',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.1,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: _accentDim,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('✓',
                style: TextStyle(
                    color: _accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                "You're on the list! We'll reach out before launch with your exclusive discount.",
                style: TextStyle(
                  color: _accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Footer  — stacks on mobile to prevent overflow
// ─────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    const left = Text(
      '© 2026 SnapSalon. All rights reserved.',
      style: TextStyle(color: _textDim, fontSize: 12),
    );
    const right = Text(
      'Built for salon professionals.',
      style: TextStyle(color: _textDim, fontSize: 12),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 28,
        vertical: isMobile ? 18 : 22,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [left, SizedBox(height: 6), right],
            )
          : const Row(
              children: [left, Spacer(), right],
            ),
    );
  }
}
