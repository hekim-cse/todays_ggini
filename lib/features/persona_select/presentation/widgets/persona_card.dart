import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/domain/persona.dart';

class PersonaCard extends StatelessWidget {
  final Persona persona;
  final bool isSelected;
  final VoidCallback onTap;

  const PersonaCard({
    super.key,
    required this.persona,
    required this.isSelected,
    required this.onTap,
  });

  String _getImagePath() {
    switch (persona) {
      case Persona.singleValue:
        return 'assets/images/persona1.png';
      case Persona.familyNutrition:
        return 'assets/images/persona2.png';
      case Persona.bodyProfile:
        return 'assets/images/persona3.png';
      case Persona.salaryBeer:
        return 'assets/images/persona4.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.buttonGray,
            width: isSelected ? 3 : 3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: Image.asset(
                  _getImagePath(),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mypage : AppColors.buttonGray,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  persona.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
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
