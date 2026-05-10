import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart';                    
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/match_service.dart';

void main() async {                               
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(                    
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.signInAnonymously(); 

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AVoxApp());
}

class AVoxApp extends StatefulWidget {
  const AVoxApp({super.key});

  @override
  State<AVoxApp> createState() => _AVoxAppState();
}

class _AVoxAppState extends State<AVoxApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama arka plana geçince veya kapanınca pool'dan çık
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      MatchService.leavePool();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'aVox',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}