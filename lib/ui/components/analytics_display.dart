import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/models/analytics.dart';

class AnalyticsDisplay extends StatefulWidget {
  final Analytics data;
  final String userChoice;
  final VoidCallback onNext;

  const AnalyticsDisplay({
    super.key,
    required this.data,
    required this.userChoice,
    required this.onNext,
  });

  @override
  State<AnalyticsDisplay> createState() => _AnalyticsDisplayState();
}

class _AnalyticsDisplayState extends State<AnalyticsDisplay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    
    _animCtrl.forward();
    
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) widget.onNext();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onNext,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8EAF6), Color(0xFFFAFAFA)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  const SizedBox(height: 45),
                  _renderTitle(),
                  const SizedBox(height: 35),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          _renderUserChoice(),
                          const SizedBox(height: 35),
                          _renderChartSection(),
                          const SizedBox(height: 35),
                          _renderInsight(),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                  _renderContinuePrompt(),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderTitle() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.indigo.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.poll_rounded,
            size: 50,
            color: Colors.indigo.shade700,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Results Are In!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${widget.data.totalCount} people responded',
          style: TextStyle(
            fontSize: 17,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _renderUserChoice() {
    final ratio = widget.data.calculateRatio(widget.userChoice);
    
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade500, Colors.indigo.shade700],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                color: Colors.amber.shade300,
                size: 26,
              ),
              const SizedBox(width: 10),
              const Text(
                'You Picked',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            widget.userChoice,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getMatchIcon(ratio),
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                '${ratio.toStringAsFixed(1)}% match',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getMatchIcon(double ratio) {
    if (ratio >= 65) return Icons.thumb_up_alt_rounded;
    if (ratio >= 35) return Icons.horizontal_rule_rounded;
    return Icons.thumb_down_alt_rounded;
  }

  Widget _renderChartSection() {
    final sortedData = widget.data.distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedData.isEmpty) {
      return const Center(child: Text('Not enough data yet'));
    }

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How Everyone Voted',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            height: 220,
            child: _renderPieChart(sortedData),
          ),
          const SizedBox(height: 26),
          ...sortedData.map((e) => _renderBar(e.key, e.value)).toList(),
        ],
      ),
    );
  }

  Widget _renderPieChart(List<MapEntry<String, int>> entries) {
    final palette = [
      const Color(0xFF5C6BC0),
      const Color(0xFF66BB6A),
      const Color(0xFFFF7043),
      const Color(0xFFAB47BC),
      const Color(0xFFEF5350),
      const Color(0xFF26A69A),
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 55,
        sections: entries.asMap().entries.map((e) {
          final idx = e.key;
          final entry = e.value;
          final pct = (entry.value / widget.data.totalCount) * 100;
          
          return PieChartSectionData(
            color: palette[idx % palette.length],
            value: entry.value.toDouble(),
            title: '${pct.toStringAsFixed(0)}%',
            radius: 70,
            titleStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _renderBar(String choice, int count) {
    final pct = (count / widget.data.totalCount) * 100;
    final isUserChoice = choice == widget.userChoice;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    if (isUserChoice)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFFFFA726),
                        size: 22,
                      ),
                    if (isUserChoice) const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        choice,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: isUserChoice ? FontWeight.w800 : FontWeight.w600,
                          color: isUserChoice ? const Color(0xFF1A237E) : const Color(0xFF424242),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${pct.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF616161),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 14,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                isUserChoice ? const Color(0xFF5C6BC0) : const Color(0xFFBDBDBD),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderInsight() {
    final ratio = widget.data.calculateRatio(widget.userChoice);
    final topChoice = widget.data.distribution.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    final isTopChoice = topChoice.key == widget.userChoice;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade300, width: 2.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_objects_rounded, color: Colors.amber.shade800, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Insight',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF424242),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _generateMessage(ratio, isTopChoice, topChoice.key),
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Color(0xFF424242),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _generateMessage(double ratio, bool isTop, String topAnswer) {
    if (isTop) {
      return "You're in the majority! Your choice matches what most people picked.";
    } else if (ratio >= 35) {
      return "Your answer represents ${ratio.toStringAsFixed(0)}% of responses - a significant viewpoint!";
    } else if (ratio >= 15) {
      return "You're in the minority on this one. Most people chose '$topAnswer'.";
    } else {
      return "You're among the ${ratio.toStringAsFixed(0)}% who chose this unique response!";
    }
  }

  Widget _renderContinuePrompt() {
    return Column(
      children: [
        Icon(
          Icons.swipe_rounded,
          color: Colors.grey.shade400,
          size: 35,
        ),
        const SizedBox(height: 10),
        Text(
          'Tap to continue',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
