import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../repository/level_selection_repository.dart';
import '../binding/level_selection_binding.dart';
import '../model/level_progress.dart';

class LevelSelectionController extends StateController<LevelSelectionBinding> {
  final LevelSelectionRepository _repository = LevelSelectionRepository();

  List<LevelProgress> _levelProgress = [];
  int _currentLevel = 1;
  int _coins = 566;
  final ScrollController _scrollController = ScrollController();

  List<LevelProgress> get levelProgress => _levelProgress;
  int get currentLevel => _currentLevel;
  int get coins => _coins;
  ScrollController get scrollController => _scrollController;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _levelProgress = await _repository.loadLevelProgress();
    _currentLevel = await _repository.getCurrentLevel();
    _coins = await _repository.getCoins();
    update();
    
    // Scroll to current level after layout
    Future.delayed(const Duration(milliseconds: 300), _scrollToCurrentLevel);
  }

  void _scrollToCurrentLevel() {
    if (_scrollController.hasClients) {
      // Wait for the list to be laid out
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final index = (_currentLevel - 1).clamp(0, _levelProgress.length - 1);
          // Each level takes approximately 180px (node + connector)
          final position = index * 180.0;
          final targetPosition = (position - 300).clamp(0.0, _scrollController.position.maxScrollExtent);
          
          _scrollController.animateTo(
            targetPosition,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  void onLevelTap(int levelNumber) {
    final progress = _levelProgress[levelNumber - 1];
    if (progress.isUnlocked) {
      binding?.navigateToPlay(levelNumber);
    }
  }

  void onPlayLevel(int levelNumber) {
    // Update current level before navigating
    _repository.setCurrentLevel(levelNumber).then((_) {
      binding?.navigateToPlay(levelNumber);
    });
  }

  void onBackTap() {
    binding?.navigateBack();
  }

  void onSettingsTap() {
    // Open settings dialog
    // Settings implementation can be added later
  }

  Future<void> refreshData() async {
    await _loadData();
  }

  void scrollToCurrentLevel() {
    _scrollToCurrentLevel();
  }
}