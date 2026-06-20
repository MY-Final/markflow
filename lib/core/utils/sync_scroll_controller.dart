import 'package:flutter/material.dart';

class SyncScrollController extends ChangeNotifier {
  final ScrollController leftController;
  final ScrollController rightController;

  bool _isSyncing = false;
  bool _enabled = true;
  String? _activeSide;

  SyncScrollController({
    ScrollController? leftController,
    ScrollController? rightController,
  })  : leftController = leftController ?? ScrollController(),
        rightController = rightController ?? ScrollController() {
    _attachListeners();
  }

  void _attachListeners() {
    leftController.addListener(() => _onScroll('left'));
    rightController.addListener(() => _onScroll('right'));
  }

  void _onScroll(String source) {
    if (!_enabled || _isSyncing || source == _activeSide) return;
    if (source == _activeSide) return;

    _isSyncing = true;
    _activeSide = source;

    final sourceController =
        source == 'left' ? leftController : rightController;
    final targetController =
        source == 'left' ? rightController : leftController;

    if (!sourceController.hasClients || !targetController.hasClients) {
      _isSyncing = false;
      _activeSide = null;
      return;
    }

    final sourcePosition = sourceController.position;
    final targetPosition = targetController.position;

    final sourceMaxScroll = sourcePosition.maxScrollExtent;
    final targetMaxScroll = targetPosition.maxScrollExtent;

    if (sourceMaxScroll <= 0 || targetMaxScroll <= 0) {
      _isSyncing = false;
      _activeSide = null;
      return;
    }

    final scrollPercent = sourcePosition.pixels / sourceMaxScroll;
    final targetOffset = (scrollPercent * targetMaxScroll).clamp(0.0, targetMaxScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (targetController.hasClients) {
        targetPosition.jumpTo(targetOffset);
      }
      _isSyncing = false;
      _activeSide = null;
    });
  }

  void scrollTo(double percent) {
    _enabled = false;

    _animateToPercent(leftController, percent);
    _animateToPercent(rightController, percent);

    Future.delayed(const Duration(milliseconds: 300), () {
      _enabled = true;
    });
  }

  void _animateToPercent(ScrollController controller, double percent) {
    if (!controller.hasClients) return;

    final position = controller.position;
    final maxScroll = position.maxScrollExtent;

    if (maxScroll <= 0) return;

    final targetOffset = (percent * maxScroll).clamp(0.0, maxScroll);

    controller.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  double get scrollPercent {
    if (!leftController.hasClients) return 0.0;
    final maxScroll = leftController.position.maxScrollExtent;
    if (maxScroll <= 0) return 0.0;
    return leftController.position.pixels / maxScroll;
  }

  void enable() {
    _enabled = true;
    _isSyncing = false;
    _activeSide = null;
  }

  void disable() {
    _enabled = false;
  }

  @override
  void dispose() {
    leftController.dispose();
    rightController.dispose();
    super.dispose();
  }
}
