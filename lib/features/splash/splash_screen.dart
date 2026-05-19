import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // 스플래시 최소 2초 보여주기
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');

    if (!mounted) return;

    if (token != null) {
      // 토큰 있으면 홈으로
      context.go(AppRoutes.home);
    } else {
      // 없으면 로그인 화면으로
      context.go(AppRoutes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/start.png'),
              width: 300,
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}