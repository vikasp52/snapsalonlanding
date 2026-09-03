import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'lucide_svg.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scrollController = ScrollController();
  final _ctaKey = GlobalKey();

  final _emailController = TextEditingController();
  bool _submitted = false;
  String? _emailError;

  static const _accent = Color(0xFF10B981); // Emerald
  static const _bg = Color(0xFFF8FAFC); // Zinc-ish
  static const _text = Color(0xFF0F172A); // Slate 900-ish
  static const _muted = Color(0xFF475569); // Slate 600-ish

  @override
  void dispose() {
    _scrollController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _scrollToCta() {
    final ctx = _ctaKey.currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final targetOffset = box.localToGlobal(Offset.zero).dy + _scrollController.offset;
    _scrollController.animateTo(
      targetOffset - 88, // account for pinned nav height
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
    );
  }

  bool _isValidEmail(String email) {
    // Simple, practical email check for a frontend waitlist.
    final trimmed = email.trim();
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(trimmed);
  }

  void _submit() {
    final email = _emailController.text.trim();
    setState(() {
      _emailError = null;
      _submitted = false;
    });

    if (!_isValidEmail(email)) {
      setState(() {
        _emailError = 'Please enter a valid business email address.';
      });
      return;
    }

    // No backend wired yet: this is a demand-validation landing page.
    setState(() {
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              toolbarHeight: 72,
              elevation: 0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    color: Colors.white.withOpacity(0.78),
                  ),
                ),
              ),
              titleSpacing: 18,
              title: Row(
                children: [
                  _Brand(),
                  const Spacer(),
                  _NavJoinBetaButton(onPressed: _scrollToCta),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: _HeroSection(
                accent: _accent,
                text: _text,
                muted: _muted,
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionGap(),
            ),
            SliverToBoxAdapter(
              child: _ProblemVsSolutionSection(
                accent: _accent,
                text: _text,
                muted: _muted,
              ),
            ),
            SliverToBoxAdapter(child: _SectionGap()),
            SliverToBoxAdapter(
              child: _FeatureSpotlightSection(
                accent: _accent,
                text: _text,
                muted: _muted,
              ),
            ),
            SliverToBoxAdapter(child: _SectionGap()),
            SliverToBoxAdapter(
              key: _ctaKey,
              child: _FinalCtaSection(
                accent: _accent,
                text: _text,
                muted: _muted,
                submitted: _submitted,
                emailController: _emailController,
                emailError: _emailError,
                onSubmit: _submit,
              ),
            ),
            SliverToBoxAdapter(child: _Footer()),
          ],
        ),
      ),
    );
  }
}

class _SectionGap extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox(height: 18);
}

class _Brand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF10B981),
                Color(0xFF6366F1), // electric-ish indigo
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: LucideSvg(
              iconName: 'layers',
              size: 16,
              color: Colors.white,
              semanticsLabel: 'Ledger icon',
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'SnapSalon',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _NavJoinBetaButton extends StatelessWidget {
  const _NavJoinBetaButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Join beta waitlist',
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
          backgroundColor: Colors.white.withOpacity(0.7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        ),
        child: const Text(
          'Join Beta',
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.accent,
    required this.text,
    required this.muted,
  });

  final Color accent;
  final Color text;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 980;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Kicker(accent: accent),
              const SizedBox(height: 18),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _HeroCopy(
                        accent: accent,
                        text: text,
                        muted: muted,
                      ),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      flex: 5,
                      child: _DashboardMockup(accent: accent),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _HeroCopy(accent: accent, text: text, muted: muted),
                    const SizedBox(height: 18),
                    _DashboardMockup(accent: accent),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Kicker extends StatelessWidget {
  const _Kicker({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              LucideSvg(
                iconName: 'sparkles',
                size: 18,
                color: accent,
                semanticsLabel: 'Sparkles',
              ),
              const SizedBox(width: 10),
              const Text(
                'SnapSalon • Built for salon operations',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.accent,
    required this.text,
    required this.muted,
  });

  final Color accent;
  final Color text;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The 10-Second Booking Ledger for Salon Owners.',
          style: TextStyle(
            fontSize: 44,
            height: 1.08,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Stop fighting bloated client tools. Manage stylists, view live rosters, and log phone-in appointments on one internal dashboard.',
          style: TextStyle(
            fontSize: 18,
            height: 1.55,
            color: muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 22),
        Semantics(
          button: true,
          label: 'Secure Free Beta Access',
          child: SizedBox(
            width: double.infinity,
            child: _PrimaryCtaButton(accent: accent),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Private beta limited to 20 salons. No credit card required.',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _PrimaryCtaButton extends StatelessWidget {
  const _PrimaryCtaButton({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // We scroll on the nav button; the hero button remains a UI focal point.
        // The actual waitlist form is on the CTA section.
        final state = context.findAncestorStateOfType<_LandingPageState>();
        state?._scrollToCta();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        shadowColor: accent.withOpacity(0.35),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LucideSvg(
            iconName: 'zap',
            size: 18,
            color: Colors.white,
            semanticsLabel: 'Zap icon',
          ),
          const SizedBox(width: 10),
          const Text(
            'Secure Free Beta Access',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _MiniTrustRow extends StatelessWidget {
  const _MiniTrustRow({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              LucideSvg(
                iconName: 'shield-check',
                size: 18,
                color: accent,
                semanticsLabel: 'Privacy icon',
              ),
              const SizedBox(width: 10),
              const Text(
                'No credit card',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardMockup extends StatelessWidget {
  const _DashboardMockup({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      borderRadius: 22,
      gradient: LinearGradient(
        colors: [
          accent.withOpacity(0.45),
          const Color(0xFF6366F1).withOpacity(0.35),
          Colors.white.withOpacity(0.0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Container(
        height: 420,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.86),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MockupTopBar(accent: accent),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _MockupTimelineAndColumns(accent: accent),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 230,
                    child: _QuickBookingPanel(accent: accent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientBorderCard extends StatelessWidget {
  const GradientBorderCard({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.gradient,
    this.padding = 1.5,
  });

  final Widget child;
  final double borderRadius;
  final LinearGradient gradient;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: EdgeInsets.all(padding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - padding),
        child: child,
      ),
    );
  }
}

class _MockupTopBar extends StatelessWidget {
  const _MockupTopBar({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              LucideSvg(
                iconName: 'calendar-days',
                size: 18,
                color: accent,
                semanticsLabel: 'Calendar icon',
              ),
              const SizedBox(width: 8),
              const Text(
                'Today • Daily Ledger',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: LucideSvg(
            iconName: 'lock',
            size: 18,
            color: accent,
            semanticsLabel: 'Lock icon',
          ),
        ),
      ],
    );
  }
}

class _MockupTimelineAndColumns extends StatelessWidget {
  const _MockupTimelineAndColumns({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 78,
                child: _MockupTimeLabels(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MockupStylistHeader(accent: accent),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _MockupStylistColumn(accent: accent, name: 'Ava'),
                          const SizedBox(width: 8),
                          _MockupStylistColumn(accent: accent, name: 'Mia'),
                          const SizedBox(width: 8),
                          _MockupStylistColumn(accent: accent, name: 'Noah'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              LucideSvg(
                iconName: 'bolt',
                size: 18,
                color: accent,
                semanticsLabel: 'Quick booking',
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Quick Booking is designed for phone-in appointments.',
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _MockupTimeLabels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const labels = ['9:00', '10:00', '11:00', '12:00', '1:00', '2:00'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: labels
          .map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                t,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MockupStylistHeader extends StatelessWidget {
  const _MockupStylistHeader({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Active Stylists',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            color: Colors.white.withOpacity(0.85),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Live',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MockupStylistColumn extends StatelessWidget {
  const _MockupStylistColumn({
    required this.accent,
    required this.name,
  });

  final Color accent;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          color: Colors.white.withOpacity(0.55),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    _MockupBlock(accent: accent, height: 74, label: 'Booked'),
                    const SizedBox(height: 10),
                    _MockupBlock(
                      accent: accent.withOpacity(0.7),
                      height: 48,
                      label: 'Busy',
                    ),
                    const SizedBox(height: 10),
                    _MockupBlock(
                      accent: accent.withOpacity(0.25),
                      height: 66,
                      label: 'Break',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockupBlock extends StatelessWidget {
  const _MockupBlock({
    required this.accent,
    required this.height,
    required this.label,
  });

  final Color accent;
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.22),
            Colors.white.withOpacity(0.0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent.withOpacity(0.22)),
        color: Colors.white.withOpacity(0.72),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 6,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickBookingPanel extends StatelessWidget {
  const _QuickBookingPanel({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        color: Colors.white.withOpacity(0.62),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LucideSvg(
                iconName: 'sidebar',
                size: 18,
                color: accent,
                semanticsLabel: 'Quick booking icon',
              ),
              const SizedBox(width: 8),
              const Text(
                'Quick Booking',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap a slot, type a name, press enter.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.75),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phone Intake',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: Text(
                      'Customer name…',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              accent.withOpacity(0.95),
                              const Color(0xFF6366F1),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Book',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black.withOpacity(0.08)),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: LucideSvg(
                          iconName: 'arrow-right',
                          size: 16,
                          color: accent,
                          semanticsLabel: 'Enter',
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
      // Keep this mockup compact (minimal UI).
        ],
      ),
    );
  }
}

class _ProblemVsSolutionSection extends StatelessWidget {
  const _ProblemVsSolutionSection({
    required this.accent,
    required this.text,
    required this.muted,
  });

  final Color accent;
  final Color text;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: const Text(
              'Consumer tools add friction. SnapSalon removes it.',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Built for the front desk and managers—fast, operational, and purpose-made for salon teams.',
            style: TextStyle(
              color: muted,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;
              return GridView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 3 : 1,
                  mainAxisExtent: 220,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                children: [
                  _CompareCard(
                    leftIcon: 'users',
                    leftTitle: 'Consumer apps',
                    leftBullets: const [
                      'Client logins',
                      'Password resets',
                    ],
                    rightTitle: 'Zero Client Friction',
                    rightDescription:
                        'No client logins, app downloads, or password resets—just front desk access.',
                    accent: accent,
                  ),
                  _CompareCard(
                    leftIcon: 'layout-dashboard',
                    leftTitle: 'Consumer apps',
                    leftBullets: const [
                      'Roster views inside settings',
                      'Separate reports',
                    ],
                    rightTitle: '1-Click Roster Control',
                    rightDescription:
                        'Instantly see who’s on the floor, busy, or on break—without digging.',
                    accent: accent,
                  ),
                  _CompareCard(
                    leftIcon: 'ban',
                    leftTitle: 'Consumer apps',
                    leftBullets: const [
                      'Manual conflict fixes',
                    ],
                    rightTitle: 'Auto-Conflict Prevention',
                    rightDescription:
                        'Auto-blocks a time slot if a stylist, chair, or equipment is already assigned.',
                    accent: accent,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  const _CompareCard({
    required this.leftIcon,
    required this.leftTitle,
    required this.leftBullets,
    required this.rightTitle,
    required this.rightDescription,
    required this.accent,
  });

  final String leftIcon;
  final String leftTitle;
  final List<String> leftBullets;
  final String rightTitle;
  final String rightDescription;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      borderRadius: 18,
      gradient: LinearGradient(
        colors: [
          accent.withOpacity(0.25),
          const Color(0xFF6366F1).withOpacity(0.18),
          Colors.white.withOpacity(0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LucideSvg(
                  iconName: leftIcon,
                  size: 18,
                  color: mutedColor(context),
                  semanticsLabel: leftTitle,
                ),
                const SizedBox(width: 8),
                Text(
                  leftTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF334155),
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final b in leftBullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        b,
                        style: TextStyle(
                          color: const Color(0xFF475569).withOpacity(0.95),
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Divider(color: Colors.black.withOpacity(0.06)),
            const SizedBox(height: 10),
            Text(
              rightTitle,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: textColor(context),
                fontSize: 14.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              rightDescription,
              style: TextStyle(
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w600,
                height: 1.35,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color mutedColor(BuildContext context) => const Color(0xFF64748B);
  Color textColor(BuildContext context) => const Color(0xFF0F172A);
}

class _FeatureSpotlightSection extends StatelessWidget {
  const _FeatureSpotlightSection({
    required this.accent,
    required this.text,
    required this.muted,
  });

  final Color accent;
  final Color text;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The essentials, designed for operators',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fast workflows for busy service hours—no clutter.',
            style: TextStyle(
              color: muted,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;
              return GridView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 3 : 1,
                  mainAxisExtent: 230,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                children: [
                  _FeatureCard(
                    iconName: 'phone',
                    title: 'Lightning Phone Intake',
                    description:
                        'Tap a slot, type a name, confirm in under 10 seconds.',
                    accent: accent,
                  ),
                  _FeatureCard(
                    iconName: 'clipboard-list',
                    title: '1-Click End-of-Day Roster',
                    description:
                        'End-of-day earnings roster—no spreadsheets.',
                    accent: accent,
                  ),
                  _FeatureCard(
                    iconName: 'refresh-cw',
                    title: 'Live Multi-Station Sync',
                    description:
                        'Instant updates across tablet, back office, and manager phone.',
                    accent: accent,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.iconName,
    required this.title,
    required this.description,
    required this.accent,
  });

  final String iconName;
  final String title;
  final String description;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      borderRadius: 18,
      gradient: LinearGradient(
        colors: [
          accent.withOpacity(0.28),
          const Color(0xFF6366F1).withOpacity(0.2),
          Colors.white.withOpacity(0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withOpacity(0.25)),
                    color: accent.withOpacity(0.07),
                  ),
                  child: Center(
                    child: LucideSvg(
                      iconName: iconName,
                      size: 18,
                      color: accent,
                      semanticsLabel: title,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w600,
                height: 1.4,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinalCtaSection extends StatelessWidget {
  const _FinalCtaSection({
    required this.accent,
    required this.text,
    required this.muted,
    required this.submitted,
    required this.emailController,
    required this.emailError,
    required this.onSubmit,
  });

  final Color accent;
  final Color text;
  final Color muted;
  final bool submitted;
  final TextEditingController emailController;
  final String? emailError;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 980;
          final title = const Text(
            'Get 6 Months Free. Help us build SnapSalon and use it free for your first half-year.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              height: 1.35,
            ),
          );

          return GradientBorderCard(
            borderRadius: 24,
            gradient: LinearGradient(
              colors: [
                accent.withOpacity(0.35),
                const Color(0xFF6366F1).withOpacity(0.25),
                Colors.white.withOpacity(0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(22),
              ),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: title),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 5,
                          child: _WaitlistForm(
                            accent: accent,
                            submitted: submitted,
                            emailController: emailController,
                            emailError: emailError,
                            onSubmit: onSubmit,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        const SizedBox(height: 14),
                        _WaitlistForm(
                          accent: accent,
                          submitted: submitted,
                          emailController: emailController,
                          emailError: emailError,
                          onSubmit: onSubmit,
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _WaitlistForm extends StatelessWidget {
  const _WaitlistForm({
    required this.accent,
    required this.submitted,
    required this.emailController,
    required this.emailError,
    required this.onSubmit,
  });

  final Color accent;
  final bool submitted;
  final TextEditingController emailController;
  final String? emailError;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (submitted)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: accent.withOpacity(0.10),
              border: Border.all(color: accent.withOpacity(0.22)),
            ),
            child: Row(
              children: [
                LucideSvg(
                  iconName: 'circle-check',
                  size: 20,
                  color: accent,
                  semanticsLabel: 'Success',
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Thanks! You’re on the early access list. Watch for a beta invite.',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                )
              ],
            ),
          ),
        if (!submitted) ...[
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'Enter your business email address',
              hintStyle: TextStyle(
                color: const Color(0xFF64748B).withOpacity(0.9),
                fontWeight: FontWeight.w700,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.10)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.10)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: accent.withOpacity(0.9), width: 2),
              ),
            ),
            onFieldSubmitted: (_) => onSubmit(),
          ),
          if (emailError != null) ...[
            const SizedBox(height: 10),
            Text(
              emailError!,
              style: TextStyle(
                color: const Color(0xFFDC2626),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              shadowColor: accent.withOpacity(0.35),
            ),
            child: const Text(
              'Apply for Early Access',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              LucideSvg(
                iconName: 'shield-check',
                size: 18,
                color: accent,
                semanticsLabel: 'Privacy',
              ),
              const SizedBox(width: 10),
              const Text(
                '✓ Your privacy matters. We only send beta updates.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
      child: const Text(
        '© 2026 SnapSalon Technologies. Built for salon professionals.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

