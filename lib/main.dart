import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Pages
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/users_page.dart';
import 'screens/teachers_page.dart';
import 'screens/courses_page.dart';
import 'screens/schedule_page.dart';

void main() {
  runApp(MyApp()); // plus de const ici
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Universitaire',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),      // retire const
        '/signup': (context) => SignupPage(),    // retire const
        '/dashboard': (context) => DashboardPage(),
        '/users': (context) => UsersPage(),
        '/teachers': (context) => TeachersPage(),
        '/courses': (context) => CoursesPage(),   // DAO dynamique
        '/schedule': (context) => SchedulePage(), // DAO dynamique
      },
    );
  }
}
