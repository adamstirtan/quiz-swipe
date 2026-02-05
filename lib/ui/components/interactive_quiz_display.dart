import 'package:flutter/material.dart';
import '../../core/models/quiz_item.dart';

class InteractiveQuizDisplay extends StatefulWidget {
  final QuizItem item;
  final Function(dynamic) onSubmit;
  final VoidCallback onSkip;

  const InteractiveQuizDisplay({
    super.key,
    required this.item,
    required this.onSubmit,
    required this.onSkip,
  });

  @override
  State<InteractiveQuizDisplay> createState() => _InteractiveQuizDisplayState();
}

class _InteractiveQuizDisplayState extends State<InteractiveQuizDisplay> 
    with TickerProviderStateMixin {
  int _optionIdx = 0;
  double _scaleVal = 5.0;
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _glowAnim = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
    
    if (widget.item.category == QuizItemType.range) {
      final lower = widget.item.lowerBound ?? 0;
      final upper = widget.item.upperBound ?? 10;
      _scaleVal = (lower + upper) / 2.0;
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  void _handleYesNo(bool affirm) {
    widget.onSubmit(affirm ? 'Yes' : 'No');
  }

  void _handleSelection() {
    final opts = widget.item.choices;
    if (opts != null && opts.isNotEmpty) {
      widget.onSubmit(opts[_optionIdx]);
    }
  }

  void _cycleOption(int delta) {
    final opts = widget.item.choices;
    if (opts != null && opts.isNotEmpty) {
      setState(() {
        _optionIdx = (_optionIdx + delta + opts.length) % opts.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _glowAnim,
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 40, 24, 40),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFE3F2FD)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.2),
              blurRadius: 25,
              spreadRadius: 3,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Column(
            children: [
              _renderHeader(),
              Expanded(child: _renderPrompt()),
              _renderControls(),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(_getCategoryIcon(), color: Colors.indigo.shade700, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                _getCategoryLabel(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.indigo.shade700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel() {
    switch (widget.item.category) {
      case QuizItemType.yesNo:
        return 'BINARY CHOICE';
      case QuizItemType.selection:
        return 'PICK ONE';
      case QuizItemType.range:
        return 'SLIDER';
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.item.category) {
      case QuizItemType.yesNo:
        return Icons.compare_arrows_rounded;
      case QuizItemType.selection:
        return Icons.list_alt_rounded;
      case QuizItemType.range:
        return Icons.linear_scale_rounded;
    }
  }

  Widget _renderPrompt() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
      child: Center(
        child: Text(
          widget.item.prompt,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.3,
            color: Color(0xFF1A237E),
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _renderControls() {
    switch (widget.item.category) {
      case QuizItemType.yesNo:
        return _renderYesNoControls();
      case QuizItemType.selection:
        return _renderSelectionControls();
      case QuizItemType.range:
        return _renderRangeControls();
    }
  }

  Widget _renderYesNoControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildRoundButton(
            Icons.cancel_rounded,
            const Color(0xFFE57373),
            'Nope',
            () => _handleYesNo(false),
            72,
          ),
          _buildRoundButton(
            Icons.expand_less_rounded,
            const Color(0xFF9E9E9E),
            'Pass',
            widget.onSkip,
            58,
          ),
          _buildRoundButton(
            Icons.check_circle_rounded,
            const Color(0xFF81C784),
            'Yep',
            () => _handleYesNo(true),
            72,
          ),
        ],
      ),
    );
  }

  Widget _renderSelectionControls() {
    final opts = widget.item.choices ?? [];
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
          margin: const EdgeInsets.symmetric(horizontal: 35),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade100, Colors.indigo.shade200],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            opts.isNotEmpty ? opts[_optionIdx] : '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A237E),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRoundButton(
              Icons.keyboard_arrow_left_rounded,
              Colors.indigo.shade400,
              'Prev',
              () => _cycleOption(-1),
              62,
            ),
            const SizedBox(width: 18),
            _buildRoundButton(
              Icons.expand_less_rounded,
              const Color(0xFF9E9E9E),
              'Pass',
              widget.onSkip,
              56,
            ),
            const SizedBox(width: 18),
            _buildRoundButton(
              Icons.keyboard_arrow_right_rounded,
              Colors.indigo.shade400,
              'Next',
              () => _cycleOption(1),
              62,
            ),
          ],
        ),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: _handleSelection,
          icon: const Icon(Icons.done_all_rounded),
          label: const Text(
            'Choose This',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF81C784),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
            elevation: 6,
          ),
        ),
      ],
    );
  }

  Widget _renderRangeControls() {
    final lower = widget.item.lowerBound ?? 0;
    final upper = widget.item.upperBound ?? 10;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade100, Colors.indigo.shade300],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _scaleVal.round().toString(),
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A237E),
              ),
            ),
          ),
          const SizedBox(height: 28),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.indigo.shade400,
              inactiveTrackColor: Colors.indigo.shade100,
              thumbColor: Colors.indigo.shade700,
              overlayColor: Colors.indigo.shade200.withOpacity(0.4),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
              trackHeight: 10,
            ),
            child: Slider(
              value: _scaleVal,
              min: lower.toDouble(),
              max: upper.toDouble(),
              divisions: upper - lower,
              onChanged: (val) => setState(() => _scaleVal = val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lower.toString(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                Text(upper.toString(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRoundButton(
                Icons.expand_less_rounded,
                const Color(0xFF9E9E9E),
                'Pass',
                widget.onSkip,
                56,
              ),
              const SizedBox(width: 28),
              ElevatedButton.icon(
                onPressed: () => widget.onSubmit(_scaleVal.round()),
                icon: const Icon(Icons.send_rounded),
                label: const Text(
                  'Send It',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81C784),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                  elevation: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton(
    IconData ico,
    Color bg,
    String txt,
    VoidCallback action,
    double sz,
  ) {
    return GestureDetector(
      onTap: action,
      child: Column(
        children: [
          Container(
            width: sz,
            height: sz,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bg.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(ico, color: Colors.white, size: sz * 0.48),
          ),
          const SizedBox(height: 10),
          Text(
            txt,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF424242),
            ),
          ),
        ],
      ),
    );
  }
}
