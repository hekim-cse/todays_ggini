import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'core/env/env.dart';
import 'app.dart';


void main() async {
  // runApp() 실행 전에 Flutter 엔진과 위젯 바인딩 초기화
  // main()에서 await, 플러그인, 로컬 데이터 초기화 등을 사용하기 위해 필요
  WidgetsFlutterBinding.ensureInitialized();
  // 한국어 날짜/시간 포맷 데이터 초기화
  // null은 intl 패키지의 기본 로케일 데이터를 사용한다는 의미
  await initializeDateFormatting('ko', null);
  KakaoSdk.init(nativeAppKey: Env.kakaoNativeKey);
  runApp(const ProviderScope(child: KkiniPickApp()));
}


// import 'package:flutter/material.dart';
// import 'core/theme/app_theme.dart'; 
// import 'features/mypage/presentation/screens/mypage_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.light(),
//       home: MyPageScreen(),
//     );
//   }
// }