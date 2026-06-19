import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CleanoovRadioGroup extends StatelessWidget {
  final String label;
  final List<RadioOption> options;
  final String value;
  final ValueChanged<String> onChanged;

  const CleanoovRadioGroup({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            )),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: options.map((opt) {
            final selected = value == opt.value;
            return GestureDetector(
              onTap: () => onChanged(opt.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  opt.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class RadioOption {
  final String value;
  final String label;
  const RadioOption(this.value, this.label);
}
