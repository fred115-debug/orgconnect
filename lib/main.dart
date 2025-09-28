import 'package:flutter/material.dart';
import 'package:my_app/screens/home_page.dart';
import 'package:my_app/core/supabase_client.dart';

// import your pages
import 'screens/organizations/org_list_screen.dart';
import 'screens/auth/sign_in_page.dart';
import 'screens/auth/sign_up_page.dart';
import 'screens/role_selection_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organization List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF79CFC4),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            fontSize: 20,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        scaffoldBackgroundColor: const Color(0xFFEAF6F0),
        useMaterial3: false,
      ),
      initialRoute: '/role', // ✅ Fixed: string route name
      routes: {
        '/role': (context) => RoleSelectionScreen(),
        '/orglist': (context) => OrgListScreen(),
        '/signin': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}