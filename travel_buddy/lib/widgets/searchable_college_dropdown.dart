import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SearchableCollegeDropdown extends StatefulWidget {
  final String? value;
  final List<String> colleges;
  final ValueChanged<String?> onChanged;
  final bool isRequired;

  const SearchableCollegeDropdown({
    super.key,
    required this.value,
    required this.colleges,
    required this.onChanged,
    this.isRequired = false,
  });

  @override
  State<SearchableCollegeDropdown> createState() => _SearchableCollegeDropdownState();
}

class _SearchableCollegeDropdownState extends State<SearchableCollegeDropdown> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isOpen = false;
  String? _hovered;
  List<String> _filteredColleges = [];

  @override
  void initState() {
    super.initState();
    _filteredColleges = widget.colleges;
    if (widget.value != null) {
      _controller.text = widget.value!;
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isOpen = _focusNode.hasFocus;
    });
  }

  void _filterColleges(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredColleges = widget.colleges;
      } else {
        _filteredColleges = widget.colleges
            .where((college) => college.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _isOpen = _focusNode.hasFocus && _filteredColleges.isNotEmpty;
    });
  }

  void _selectCollege(String college) {
    _controller.text = college;
    widget.onChanged(college);
    setState(() {
      _isOpen = false;
    });
    _focusNode.unfocus();
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
              'College Name',
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
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isOpen ? focusColor : borderColor,
              width: _isOpen ? 2 : 1.2,
            ),
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            style: TextStyle(
              fontSize: inputFontSize,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Type your college name...',
              hintStyle: TextStyle(
                fontSize: hintFontSize,
                color: hintColor,
              ),
              prefixIcon: Icon(
                Icons.school_outlined,
                color: _isOpen ? AppColors.primary : AppColors.textSecondary,
              ),
              suffixIcon: _isOpen
                  ? Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: AppColors.primary,
                      size: 26,
                    )
                  : Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 26,
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            onChanged: _filterColleges,
            validator: (value) {
              if (widget.isRequired && (value == null || value.isEmpty)) {
                return 'College name is required';
              }
              return null;
            },
          ),
        ),
        if (_isOpen && _filteredColleges.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 2),
            constraints: const BoxConstraints(maxHeight: 200),
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
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _filteredColleges.length,
              itemBuilder: (context, index) {
                final college = _filteredColleges[index];
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
              },
            ),
          ),
      ],
    );
  }
} 