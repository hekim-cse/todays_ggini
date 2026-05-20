class MealPlanJob {
  final String jobId;
  final int estimatedSeconds;
  final List<String> stages;

  // 기본 상수 생성자
  const MealPlanJob({
    required this.jobId,
    required this.estimatedSeconds,
    required this.stages,
  });

  // JSON 데이터를 객체로 변환하는 팩토리 생성자
  factory MealPlanJob.fromJson(Map<String, dynamic> json) {
    // 서버 응답 예:
    // ```json
    // {
    //   "job_id": "job_abc123",
    //   "estimated_seconds": 10,
    //   "stages": ["프로필 분석", "식단 후보 생성", "가격 비교", "최적 조합 선정"]
    // }
    // ```
    return MealPlanJob(
      // JSON의 키(job_id)를
      // Dart의 필드(jobId)에 매핑
      jobId: json['job_id'] as String,
      estimatedSeconds: json['estimated_seconds'] as int,
      // JSON 배열(List<dynamic>)을 List<String>으로 변환
      stages: (json['stages'] as List).cast<String>(),
    );
  }
}
