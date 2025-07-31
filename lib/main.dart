import 'package:flutter/material.dart';
import 'Homepages/home_page.dart';
import 'models/expense_report.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'settings_page.dart';
import 'NavigationBar/main_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'providers/session_provider.dart';
import 'services/auth_service.dart';
import 'services/auth_api.dart';
import 'config/app_config.dart';
import 'Authentication/token_page.dart';
import 'add_expenses/add_expense_choice.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SessionProvider(
            authService: AuthService(),
            authApi: AuthApi(baseUrl: AppConfig.baseUrl),
          ),
        ),
      ],
      child: const LivaApp(),
    );
  }
}

class LivaApp extends StatefulWidget {
  const LivaApp({super.key});
  @override
  State<LivaApp> createState() => _LivaAppState();
}

class _LivaAppState extends State<LivaApp> {
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    final sessionProvider = Provider.of<SessionProvider>(
      context,
      listen: false,
    );
    await sessionProvider.initializeSession();
    setState(() {
      _isLoading = false;
    });
  }

  final List<ExpenseReport> reports = [];
  int _currentIndex = 0;

  void addReport(ExpenseReport report) {
    setState(() {
      final idx = reports.indexWhere((r) => r.id == report.id);
      if (idx >= 0) {
        reports[idx] = report;
      } else {
        reports.add(report);
      }
    });
  }

  void updateReport(ExpenseReport report) {
    setState(() {
      final idx = reports.indexWhere((r) => r.id == report.id);
      if (idx >= 0) {
        reports[idx] = report;
      }
    });
  }

  void updateReportStatus(ExpenseReport updatedReport) {
    setState(() {
      final idx = reports.indexWhere((r) => r.id == updatedReport.id);
      if (idx >= 0) {
        reports[idx] = updatedReport;
      }
    });
  }

  void onLogin(String user) {
    setState(() {}); // Just trigger rebuild
  }

  void onLogout() {
    setState(() {
      reports.clear();
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final user = sessionProvider.currentUser;
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LivaControl',
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr'), Locale('en')],
            home: user == null
          ? const TokenPage()
          : Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: [
                  HomePage(
                    username: user.username,
                    reports: reports,
                    onAddReport: addReport,
                    onUpdateReport: updateReport,
                    onLogout: onLogout,
                    onGoToSettings: () {
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                  ),
                  SettingsPage(onLogout: onLogout),
                  // Admin paneli için route ekle (gerekirse)
                ],
              ),
              bottomNavigationBar: MainNavigationBar(
                currentIndex: _currentIndex,
                onHome: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
                onSettings: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
                onAdd: () {},
              ),
              floatingActionButton: Builder(
                builder: (context) => SizedBox(
                  height: 64,
                  width: 64,
                  child: FloatingActionButton(
                    backgroundColor: const Color(0xFFF57A20),
                    elevation: 6,
                    shape: const CircleBorder(),
                    onPressed: () async {
                      final report = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddExpenseChoicePage(),
                        ),
                      );
                      if (report != null) {
                        addReport(report);
                      }
                    },
                    child: const Icon(Icons.add, size: 36, color: Colors.white),
                  ),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
            ),
    );
  }
}
