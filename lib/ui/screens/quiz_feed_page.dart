import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/quiz_session_manager.dart';
import '../../core/state/persona_manager.dart';
import '../components/interactive_quiz_display.dart';
import '../components/analytics_display.dart';
import '../../core/services/data_repository.dart';
import '../../core/models/analytics.dart';

class QuizFeedPage extends StatefulWidget {
  const QuizFeedPage({super.key});

  @override
  State<QuizFeedPage> createState() => _QuizFeedPageState();
}

class _QuizFeedPageState extends State<QuizFeedPage> {
  bool _viewingAnalytics = false;
  Analytics? _currentAnalytics;
  String? _lastResponse;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final sessionMgr = context.read<QuizSessionManager>();
    final personaMgr = context.read<PersonaManager>();
    
    await personaMgr.restore();
    await sessionMgr.restoreProgress();
    await sessionMgr.loadBatch();
    
    setState(() {
      _initialized = true;
    });
  }

  Future<void> _processResponse(dynamic val) async {
    final sessionMgr = context.read<QuizSessionManager>();
    final personaMgr = context.read<PersonaManager>();
    final activeQuiz = sessionMgr.activeItem;
    
    if (activeQuiz == null) return;

    await sessionMgr.recordAnswer(val);
    personaMgr.incrementAnswered();

    final analyticsData = await DataRepository().fetchAnalytics(activeQuiz.uid);
    
    setState(() {
      _currentAnalytics = analyticsData;
      _lastResponse = val.toString();
      _viewingAnalytics = true;
    });
  }

  void _handleSkip() {
    context.read<QuizSessionManager>().moveNext();
  }

  void _exitAnalytics() {
    setState(() {
      _viewingAnalytics = false;
      _currentAnalytics = null;
      _lastResponse = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_viewingAnalytics && _currentAnalytics != null && _lastResponse != null) {
      return Scaffold(
        body: AnalyticsDisplay(
          data: _currentAnalytics!,
          userChoice: _lastResponse!,
          onNext: _exitAnalytics,
        ),
      );
    }

    return Scaffold(
      body: Consumer2<QuizSessionManager, PersonaManager>(
        builder: (ctx, sessionMgr, personaMgr, _) {
          if (sessionMgr.loading && sessionMgr.allItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeQuiz = sessionMgr.activeItem;
          if (activeQuiz == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, 
                       size: 90, 
                       color: Colors.grey.shade400),
                  const SizedBox(height: 24),
                  const Text(
                    'No more questions!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 35),
                  ElevatedButton.icon(
                    onPressed: () => sessionMgr.loadBatch(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Load More'),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                _buildProgressBar(sessionMgr),
                Expanded(
                  child: InteractiveQuizDisplay(
                    key: ValueKey(activeQuiz.uid),
                    item: activeQuiz,
                    onSubmit: _processResponse,
                    onSkip: _handleSkip,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(QuizSessionManager sessionMgr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.whatshot_rounded,
                  color: Colors.orange.shade700,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${sessionMgr.streak} day streak',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF424242),
                    ),
                  ),
                  Text(
                    '${sessionMgr.dailyProgress} of 5 today',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Icon(Icons.layers_rounded, 
                     color: Colors.indigo.shade700, 
                     size: 20),
                const SizedBox(width: 8),
                Text(
                  '${sessionMgr.allItems.length}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
