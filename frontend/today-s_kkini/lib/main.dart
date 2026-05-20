import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'core/env/env.dart';
import 'app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko', null);

  // 카카오 SDK 초기화.
  // - Mobile (iOS/Android): nativeAppKey 사용
  // - Web: javaScriptAppKey 사용
  // 두 키를 한꺼번에 넘기면 SDK 가 플랫폼에 맞게 골라 씀.
  KakaoSdk.init(
    nativeAppKey: Env.kakaoNativeKey,
    javaScriptAppKey: Env.kakaoJavaScriptKey,
  );

  runApp(const ProviderScope(child: KkiniPickApp()));
}
