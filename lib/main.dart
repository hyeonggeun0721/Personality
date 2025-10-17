import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'main/mainlist_page.dart';

void main() async {
  // Flutter 엔진과 위젯 바인딩을 보장합니다. Firebase 초기화 전 필수입니다.
  WidgetsFlutterBinding.ensureInitialized();

  // 플랫폼에 맞는 Firebase 설정을 사용하여 앱을 초기화합니다.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 앱의 루트 위젯인 MyApp을 실행합니다.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 앱의 기본 디자인과 구조를 정의하는 MaterialApp 위젯을 반환합니다.
    return MaterialApp(
      title: 'Personality Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 앱이 실행될 때 가장 먼저 보여줄 화면으로 MainPage를 지정합니다.
      home: const MainPage(),
    );
  }
}