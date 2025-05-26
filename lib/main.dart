import 'package:drhouse/screens/login.dart';
import 'package:drhouse/utils/config.dart';
import 'package:drhouse/utils/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  MyAppState createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    //SwitchValue().init(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dr House',
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Inter',
        inputDecorationTheme: const InputDecorationTheme(
          border: Config.outlinedBorder,
          focusedBorder: Config.outlinedBorder,
          errorBorder: Config.errorBorder,
          floatingLabelStyle: TextStyle(color: Colors.green),
          prefixIconColor: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey.shade500,
          elevation: 10,
          type: BottomNavigationBarType.shifting,
        ),
        // fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Inter',
          inputDecorationTheme: const InputDecorationTheme(
            border: Config.outlinedBorder,
            focusedBorder: Config.outlinedBorder,
            errorBorder: Config.errorBorder,
            floatingLabelStyle: TextStyle(color: Colors.green),
            prefixIconColor: Colors.white,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor:const Color.fromARGB(255, 79, 158, 91),
            unselectedItemColor: Colors.grey.shade500,
            elevation: 10,
            type: BottomNavigationBarType.shifting,
          )),
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        //this is the initial route of the app
        // aka the auth page login and sign up
        '/': (context) => const Login(),
        // this is for main layout after login
        'main': (context) => const MainLayout(),
      },
    );
  }
}
