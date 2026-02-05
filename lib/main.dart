import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/state/quiz_session_manager.dart';
import 'core/state/persona_manager.dart';
import 'core/services/data_repository.dart';
import 'ui/screens/quiz_feed_page.dart';
import 'ui/screens/preferences_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const endpoint = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  const apiKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key-here',
  );
  
  await DataRepository().setup(endpoint, apiKey);
  
  runApp(const QuizSwipeApp());
}

class QuizSwipeApp extends StatelessWidget {
  const QuizSwipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizSessionManager()),
        ChangeNotifierProvider(create: (_) => PersonaManager()),
      ],
      child: MaterialApp(
        title: 'QuizSwipe',
        debugShowCheckedModeBanner: false,
        theme: _createTheme(),
        home: const AppShell(),
      ),
    );
  }

  ThemeData _createTheme() {
    return ThemeData(
      primarySwatch: Colors.indigo,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5C6BC0),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1A237E),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _navIndex = 0;
  final PageController _pageController = PageController();

  final List<_NavDestination> _destinations = const [
    _NavDestination(
      iconData: Icons.home_outlined,
      selectedIconData: Icons.home_rounded,
      labelText: 'Feed',
    ),
    _NavDestination(
      iconData: Icons.tune_outlined,
      selectedIconData: Icons.tune_rounded,
      labelText: 'Settings',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNavTap(int idx) {
    setState(() {
      _navIndex = idx;
    });
    _pageController.animateToPage(
      idx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (idx) {
          setState(() {
            _navIndex = idx;
          });
        },
        children: const [
          QuizFeedPage(),
          PreferencesPage(),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _destinations.asMap().entries.map((entry) {
              final idx = entry.key;
              final dest = entry.value;
              final isActive = idx == _navIndex;
              
              return _buildNavButton(
                iconData: isActive ? dest.selectedIconData : dest.iconData,
                labelText: dest.labelText,
                isActive: isActive,
                onTap: () => _handleNavTap(idx),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData iconData,
    required String labelText,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
          color: isActive 
              ? const Color(0xFF5C6BC0).withOpacity(0.15) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              color: isActive ? const Color(0xFF5C6BC0) : const Color(0xFF9E9E9E),
              size: 28,
            ),
            if (isActive) ...[
              const SizedBox(width: 12),
              Text(
                labelText,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5C6BC0),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavDestination {
  final IconData iconData;
  final IconData selectedIconData;
  final String labelText;

  const _NavDestination({
    required this.iconData,
    required this.selectedIconData,
    required this.labelText,
  });
}
