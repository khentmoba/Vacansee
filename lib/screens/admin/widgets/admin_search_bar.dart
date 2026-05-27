import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AdminSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback? onFilterTap;
  final String? initialValue;
  final String hintText;
  final bool showFilterButton;
  final int debounceMilliseconds;

  const AdminSearchBar({
    super.key,
    required this.onSearch,
    this.onFilterTap,
    this.initialValue,
    this.hintText = 'Search by name, address, or owner...',
    this.showFilterButton = true,
    this.debounceMilliseconds = 300,
  });

  @override
  State<AdminSearchBar> createState() => _AdminSearchBarState();
}

class _AdminSearchBarState extends State<AdminSearchBar> {
  bool _isHovered = false;
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      Duration(milliseconds: widget.debounceMilliseconds),
      () => widget.onSearch(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppShadows.md],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              style: GoogleFonts.workSans(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.workSans(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                fillColor: AppColors.background,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (widget.showFilterButton) ...[
            const SizedBox(width: 12),
            MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                decoration: BoxDecoration(
                  color: _isHovered ? AppColors.primary.withValues(alpha: 0.1) : AppColors.divider,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isHovered ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: InkWell(
                  onTap: widget.onFilterTap,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          color: _isHovered ? AppColors.primary : AppColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filters',
                          style: GoogleFonts.outfit(
                            color: _isHovered ? AppColors.primary : AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
