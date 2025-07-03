import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CollegeDropdown extends StatefulWidget {
  final String? value;
  final List<String> colleges;
  final ValueChanged<String?> onChanged;
  final bool isRequired;

  const CollegeDropdown({
    super.key,
    required this.value,
    required this.colleges,
    required this.onChanged,
    this.isRequired = false,
  });

  @override
  State<CollegeDropdown> createState() => _CollegeDropdownState();
}

class _CollegeDropdownState extends State<CollegeDropdown> {
  bool _isOpen = false;
  String? _hovered;

  void _toggleDropdown() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _selectCollege(String? college) {
    if (widget.value == college) {
      widget.onChanged(null);
    } else {
      widget.onChanged(college);
    }
    setState(() {
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : AppColors.inputBorder;
    final focusColor = AppColors.inputFocus;
    final labelColor = _isOpen
        ? AppColors.primary
        : (isDark ? Colors.white : AppColors.textPrimary);
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final hintColor = isDark ? Colors.white54 : AppColors.textSecondary;
    final bgColor = isDark ? Colors.white10 : AppColors.inputBackground;
    const double labelFontSize = 15;
    const double inputFontSize = 16;
    const double hintFontSize = 15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Select College',
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
            if (widget.isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _toggleDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isOpen ? focusColor : borderColor,
                width: _isOpen ? 2 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value ?? 'Select your college',
                    style: TextStyle(
                      fontSize: inputFontSize,
                      color: widget.value == null ? hintColor : textColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: _isOpen ? AppColors.primary : AppColors.textSecondary,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
        if (_isOpen)
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: focusColor,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.13) : AppColors.cardShadow.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: widget.colleges.map((college) {
                final selected = widget.value == college;
                final hovered = _hovered == college;
                return MouseRegion(
                  onEnter: (_) => setState(() => _hovered = college),
                  onExit: (_) => setState(() => _hovered = null),
                  child: GestureDetector(
                    onTap: () => _selectCollege(college),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                      color: selected
                          ? AppColors.primary.withOpacity(0.12)
                          : hovered
                              ? AppColors.primary.withOpacity(0.08)
                              : Colors.transparent,
                      child: Text(
                        college,
                        style: TextStyle(
                          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                          color: selected
                              ? AppColors.primary
                              : (isDark ? AppColors.textLight : AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
