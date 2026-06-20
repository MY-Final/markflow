import 'package:flutter/material.dart';
import 'package:markflow/core/theme/theme.dart';

class SlidingButtonGroup<T> extends StatefulWidget {
  final List<SlidingButtonOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  const SlidingButtonGroup({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  State<SlidingButtonGroup<T>> createState() => _SlidingButtonGroupState<T>();
}

class _SlidingButtonGroupState<T> extends State<SlidingButtonGroup<T>> {
  final Map<int, GlobalKey> _buttonKeys = {};
  double? _highlightLeft;
  double? _highlightWidth;
  double? _highlightHeight;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.options.length; i++) {
      _buttonKeys[i] = GlobalKey();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHighlight());
  }

  @override
  void didUpdateWidget(SlidingButtonGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateHighlight());
    }
  }

  void _updateHighlight() {
    final selectedIndex = widget.options
        .indexWhere((opt) => opt.value == widget.selectedValue);
    if (selectedIndex < 0) return;

    final key = _buttonKeys[selectedIndex];
    if (key?.currentContext == null) return;

    final box = key!.currentContext!.findRenderObject() as RenderBox;
    final parentBox = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero, ancestor: parentBox);

    setState(() {
      _highlightLeft = position.dx;
      _highlightWidth = box.size.width;
      _highlightHeight = box.size.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.surfaceWarm,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // 滑动高亮块
          if (_highlightLeft != null && _highlightWidth != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _highlightLeft,
              top: 0,
              width: _highlightWidth,
              height: _highlightHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: theme.text.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          // 按钮列表
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.options.length, (index) {
              final option = widget.options[index];
              final isSelected = option.value == widget.selectedValue;

              return GestureDetector(
                key: _buttonKeys[index],
                onTap: () => widget.onChanged(option.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (option.icon != null) ...[
                        Icon(
                          option.icon,
                          size: 14,
                          color: isSelected
                              ? theme.primary
                              : theme.tertiaryText,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.normal,
                          color: isSelected
                              ? theme.primary
                              : theme.tertiaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class SlidingButtonOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const SlidingButtonOption({
    required this.value,
    required this.label,
    this.icon,
  });
}
