import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AllergyInput extends StatefulWidget {
  final List<String> allergies;
  final ValueChanged<List<String>> onChanged;

  const AllergyInput({
    super.key,
    required this.allergies,
    required this.onChanged,
  });

  @override
  State<AllergyInput> createState() => _AllergyInputState();
}

class _AllergyInputState extends State<AllergyInput> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '[알레르기 및 제외 재료]',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '제외할 재료를 입력해 주세요.',
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _error != null ? AppColors.error : AppColors.textSecondary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        _error!,
                        style: const TextStyle(fontSize: 12, color: AppColors.error),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    if (widget.allergies.contains(_controller.text)) {
                      setState(() => _error = '이미 입력된 재료입니다.');
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _error = null);
                      });
                    } else {
                      final newList = List<String>.from(widget.allergies)
                        ..add(_controller.text);
                      _controller.clear();
                      setState(() => _error = null);
                      widget.onChanged(newList);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size.zero,
                ),
                child: const Text('추가', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.allergies.map((allergy) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    allergy,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      final newList = List<String>.from(widget.allergies)
                        ..remove(allergy);
                      widget.onChanged(newList);
                    },
                    child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}