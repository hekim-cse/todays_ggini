import 'package:intl/intl.dart';

// 숫자/날짜 포맷팅 유틸
//
// intl 패키지의 NumberFormat / DateFormat을 wrapping
// 매번 NumberFormat 객체를 만들지 않게 static으로 캐싱

// 캐싱된 포매터 (모듈 로드 시 한 번만 생성)
final _priceFormat = NumberFormat('#,###');
final _dateFormat = DateFormat('yyyy-MM-dd');
final _yearMonthFormat = DateFormat('yyyy-MM');

// 정수를 천 단위 콤마 형식 문자열로 변환
//
// 예: 1234567 → "1,234,567"
String formatPrice(int price) => _priceFormat.format(price);

// DateTime을 'YYYY-MM-DD' 형식 문자열로 변환
//
// 예: DateTime(2026, 4, 6) → "2026-04-06"
// 백엔드 API의 date path parameter 형태에 맞춤
String formatDate(DateTime date) => _dateFormat.format(date);

// year, month를 'YYYY-MM' 형식 문자열로 변환
//
// 예: (2026, 4) → "2026-04"
String formatYearMonth(int year, int month) =>
    _yearMonthFormat.format(DateTime(year, month));
