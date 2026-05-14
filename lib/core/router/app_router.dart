import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/meal_detail/presentation/screens/meal_detail_screen.dart';
import '../../features/meal_plan_loading/presentation/screens/meal_plan_loading_screen.dart';
import '../../features/meal_style_select/presentation/screens/meal_style_select_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/persona_select/presentation/screens/persona_select_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/mypage/presentation/screens/mypage_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/ingredient_list/presentation/screens/ingredient_list_screen.dart';
import '../../features/shopping_list/presentation/screens/shopping_list_screen.dart';
import '../../features/ingredient_detail/presentation/screens/ingredient_detail_screen.dart';
import '../../features/menu_change/presentation/screens/menu_change_screen.dart';

import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.personaSelect,
        builder: (_, __) => const PersonaSelectScreen(),
      ),
      GoRoute(path: AppRoutes.auth, builder: (_, __) => const AuthScreen()),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.mealStyleSelect,
        builder: (_, __) => const MealStyleSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.mealPlanLoading,
        builder: (_, __) => const MealPlanLoadingScreen(),
      ),
      GoRoute(
        path: AppRoutes.calendar,
        builder: (_, __) => const CalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.myPage,
        builder: (_, __) => const MyPageScreen(),
      ),
      GoRoute(
        path: AppRoutes.mealDetail,
        builder: (_, state) {
          final dateStr = state.pathParameters['date'] ?? '';
          final date = DateTime.tryParse(dateStr) ?? DateTime.now();
          return MealDetailScreen(date: date);
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.ingredientList,
        builder: (_, state) {
          final mealId = state.pathParameters['mealId'] ?? '';
          final dateStr = state.uri.queryParameters['date'];
          final slotStr = state.uri.queryParameters['slot'];
          final sourceDate = dateStr != null ? DateTime.tryParse(dateStr) : null;
          final sourceSlot = slotStr != null ? int.tryParse(slotStr) : null;
          return IngredientListScreen(
            mealId: mealId,
            sourceDate: sourceDate,
            sourceSlot: sourceSlot,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.shoppingList,
        builder: (_, __) => const ShoppingListScreen(),
      ),
      GoRoute(
        path: AppRoutes.ingredientDetail,
        builder: (_, state) {
          final ingredientId = state.pathParameters['ingredientId'] ?? '';
          return IngredientDetailScreen(ingredientId: ingredientId);
        },
      ),
      GoRoute(
        path: AppRoutes.menuChange,
        builder: (_, state) {
          final mealId = state.pathParameters['mealId'] ?? '';
          final dateStr = state.uri.queryParameters['date'];
          final slotStr = state.uri.queryParameters['slot'];
          final date = dateStr != null ? DateTime.tryParse(dateStr) ?? DateTime.now() : DateTime.now();
          final slot = slotStr != null ? int.tryParse(slotStr) ?? 1 : 1;
          return MenuChangeScreen(mealId: mealId, date: date, slot: slot);
        },
      ),
    ],
  );
});