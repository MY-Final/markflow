import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markflow/core/registry/command_registry.dart';
import 'package:markflow/core/registry/shortcut_registry.dart';
import 'package:markflow/core/theme/theme.dart';

class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => const CommandPalette(),
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Command> _filteredCommands = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _filteredCommands = CommandRegistry().listCommands();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterCommands(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCommands = CommandRegistry().listCommands();
      } else {
        _filteredCommands = CommandRegistry()
            .listCommands()
            .where((cmd) =>
                cmd.title.toLowerCase().contains(query.toLowerCase()) ||
                cmd.id.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _selectedIndex = 0;
    });
  }

  void _executeSelected() {
    if (_filteredCommands.isEmpty) return;
    final command = _filteredCommands[_selectedIndex];
    Navigator.of(context).pop();
    CommandRegistry().executeCommand(command.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MarkFlowTheme>()!;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            setState(() {
              _selectedIndex =
                  (_selectedIndex + 1).clamp(0, _filteredCommands.length - 1);
            });
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            setState(() {
              _selectedIndex =
                  (_selectedIndex - 1).clamp(0, _filteredCommands.length - 1);
            });
          } else if (event.logicalKey == LogicalKeyboardKey.enter) {
            _executeSelected();
          }
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 560,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.text.withValues(alpha: 0.1),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSearchBar(theme),
              if (_filteredCommands.isNotEmpty) ...[
                Divider(height: 1, color: theme.border),
                _buildCommandList(theme),
              ],
              if (_filteredCommands.isEmpty)
                _buildEmptyState(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(MarkFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: theme.secondaryText),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: theme.text,
              ),
              decoration: InputDecoration(
                hintText: '输入命令...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  color: theme.secondaryText.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
              ),
              onChanged: _filterCommands,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.hover,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'ESC',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandList(MarkFlowTheme theme) {
    return Flexible(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredCommands.length,
        itemBuilder: (context, index) {
          final command = _filteredCommands[index];
          final isSelected = index == _selectedIndex;
          final shortcut = AppShortcutRegistry().getShortcut(command.id);

          return _CommandItem(
            command: command,
            isSelected: isSelected,
            shortcut: shortcut != null
                ? AppShortcutRegistry().formatShortcut(shortcut)
                : null,
            theme: theme,
            onTap: () {
              setState(() => _selectedIndex = index);
              _executeSelected();
            },
            onHover: () {
              setState(() => _selectedIndex = index);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(MarkFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: theme.secondaryText.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '未找到命令',
            style: TextStyle(
              fontSize: 14,
              color: theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandItem extends StatefulWidget {
  final Command command;
  final bool isSelected;
  final String? shortcut;
  final MarkFlowTheme theme;
  final VoidCallback onTap;
  final VoidCallback onHover;

  const _CommandItem({
    required this.command,
    required this.isSelected,
    this.shortcut,
    required this.theme,
    required this.onTap,
    required this.onHover,
  });

  @override
  State<_CommandItem> createState() => _CommandItemState();
}

class _CommandItemState extends State<_CommandItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isActive = widget.isSelected || _isHovered;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        widget.onHover();
      },
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: isActive ? theme.hover : Colors.transparent,
          child: Row(
            children: [
              if (widget.command.icon != null) ...[
                Icon(
                  widget.command.icon,
                  size: 16,
                  color: theme.secondaryText,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.command.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isActive ? theme.text : theme.secondaryText,
                      ),
                    ),
                    if (widget.command.description.isNotEmpty)
                      Text(
                        widget.command.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.secondaryText.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.shortcut != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.hover,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.shortcut!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: theme.secondaryText,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
