import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mascot_speech.dart';
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
        child: Column(
          children: [
            const MascotSpeech(message: '나는...'),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                  children: Persona.values.map((persona) {
                    return PersonaCard(
                      persona: persona,
                      isSelected: _selectedPersona == persona,
                      onTap: () => setState(() => _selectedPersona = persona),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedPersona == null
                      ? null
                      : () {
                          ref.read(selectedPersonaProvider.notifier).state =
                              _selectedPersona!;
                          context.go(AppRoutes.onboarding);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.buttonGray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text(
                    '이 프로필로 시작하기',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
