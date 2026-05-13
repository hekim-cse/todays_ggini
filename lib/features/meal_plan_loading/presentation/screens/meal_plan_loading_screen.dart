import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/meal_plan_loading_provider.dart';
import '../widgets/loading_stage_item.dart';

class MealPlanLoadingScreen extends ConsumerWidget {
  const MealPlanLoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mealPlanLoadingProvider);

    ref.listen(mealPlanLoadingProvider, (prev, next) {
      if (next.isComplete && !(prev?.isComplete ?? false)) {
        context.go(AppRoutes.home);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/images/pic.png',  // ← 변경
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              '이미지 로드 실패: $error',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                              ),
                            );
                          },
                        ),
                      ),
                      const Positioned(
                        top: 20,
                        child: Text(
                          '로딩 중 ...',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '약 ${state.job?.estimatedSeconds ?? 10}초 정도 소요됩니다',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 56),
              if (state.error != null)
                Text(
                  '오류가 발생했습니다.\n${state.error}',
                  style: const TextStyle(color: Colors.red),
                )
              else if (state.job != null)
                ...List.generate(state.job!.stages.length, (i) {
                  return LoadingStageItem(
                    label: state.job!.stages[i],
                    isDone: i < state.completedStages,
                  );
                })
              else
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}