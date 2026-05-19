import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/meal_plan_loading_provider.dart';
import '../widgets/loading_stage_item.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MealPlanLoadingScreen extends ConsumerStatefulWidget {
  const MealPlanLoadingScreen({super.key});

  @override
  ConsumerState<MealPlanLoadingScreen> createState() => _MealPlanLoadingScreenState();
}

class _MealPlanLoadingScreenState extends ConsumerState<MealPlanLoadingScreen> {
  bool _showFirst = true;

  @override
  void initState() {
    super.initState();
    _startImageToggle();
  }

  void _startImageToggle() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _showFirst = !_showFirst);
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealPlanLoadingProvider);

    ref.listen(mealPlanLoadingProvider, (prev, next) {
      if (next.isComplete && !(prev?.isComplete ?? false)) {
        ref.read(authProvider.notifier).markOnboarded();
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
                child: Column(
                  children: [
                    // 로딩 중 텍스트
                    Text(
                      '로딩 중 ...',
                      style: Theme.of(context).textTheme.headlineMedium
                    ),
                    const SizedBox(height: 16),
                    // 번갈아가는 이미지
                    Image.asset(
                      _showFirst
                          ? 'assets/images/loading1.png'
                          : 'assets/images/loading2.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '약 ${state.job?.estimatedSeconds ?? 10}초 정도 소요됩니다',
                  style: Theme.of(context).textTheme.bodyMedium
                ),
              ),
              const SizedBox(height: 80),
              if (state.error != null)
                Text(
                  '오류가 발생했습니다.\n${state.error}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error
                  )
                )
              else if (state.job != null)
                Center(
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(state.job!.stages.length, (i) {
                        return LoadingStageItem(
                          label: state.job!.stages[i],
                          isDone: i < state.completedStages,
                        );
                      }),
                    ),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}