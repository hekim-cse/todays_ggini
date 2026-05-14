import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../../onboarding/domain/persona.dart';
import '../widgets/persona_card.dart';

class PersonaSelectScreen extends ConsumerStatefulWidget {
  const PersonaSelectScreen({super.key});

  @override
  ConsumerState<PersonaSelectScreen> createState() => _PersonaSelectScreenState();
}

class _PersonaSelectScreenState extends ConsumerState<PersonaSelectScreen> {
  Persona? _selectedPersona;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const AppLogo(),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '   나는 ...',
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: Persona.values.map((persona) {
                    return PersonaCard(
                      persona: persona,
                      isSelected: _selectedPersona == persona,
                      onTap: () => setState(() => _selectedPersona = persona),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedPersona == null
                      ? null
                      : () {
                          // 선택한 페르소나 저장
                          ref.read(selectedPersonaProvider.notifier).state =
                              _selectedPersona!;
                          context.go(AppRoutes.onboarding);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.surfaceDim,
                  ),
                  child: const Text(
                    '이 프로필로 시작하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}