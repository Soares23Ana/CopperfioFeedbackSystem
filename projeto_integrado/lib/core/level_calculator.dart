/// Lógica para calcular o nível do cliente baseado em CopperPoints
class LevelCalculator {
  /// Define os limites de pontos para cada nível
  static const Map<String, int> levelThresholds = {
    'Bronze': 0,
    'Prata': 500,
    'Ouro': 1500,
    'Diamante': 3000,
  };

  /// Retorna a lista de níveis em ordem
  static const List<String> levelOrder = [
    'Bronze',
    'Prata',
    'Ouro',
    'Diamante',
  ];

  /// Calcula o nível atual baseado nos pontos
  static String calculateLevel(int copperPoints) {
    for (int i = levelOrder.length - 1; i >= 0; i--) {
      final level = levelOrder[i];
      if (copperPoints >= levelThresholds[level]!) {
        return level;
      }
    }
    return 'Bronze';
  }

  /// Retorna o próximo nível
  static String getNextLevel(String currentLevel) {
    final currentIndex = levelOrder.indexOf(currentLevel);
    if (currentIndex >= 0 && currentIndex < levelOrder.length - 1) {
      return levelOrder[currentIndex + 1];
    }
    return currentLevel; // Diamante é o último
  }

  /// Calcula o progresso em percentual para o próximo nível
  static double calculateProgress(int copperPoints, String currentLevel) {
    final nextLevel = getNextLevel(currentLevel);
    if (nextLevel == currentLevel) {
      return 1.0; // Já está no nível máximo
    }

    final currentThreshold = levelThresholds[currentLevel]!;
    final nextThreshold = levelThresholds[nextLevel]!;
    final progress =
        (copperPoints - currentThreshold) / (nextThreshold - currentThreshold);

    return progress.clamp(0.0, 1.0);
  }

  /// Retorna os pontos necessários para o próximo nível
  static int pointsForNextLevel(int copperPoints, String currentLevel) {
    final nextLevel = getNextLevel(currentLevel);
    if (nextLevel == currentLevel) {
      return 0; // Já está no nível máximo
    }

    final nextThreshold = levelThresholds[nextLevel]!;
    final remaining = nextThreshold - copperPoints;
    return remaining > 0 ? remaining : 0;
  }

  /// Retorna os pontos necessários até o nível seguinte (para exibição)
  static int pointsNeededForNextLevel(int copperPoints, String currentLevel) {
    final nextLevel = getNextLevel(currentLevel);
    if (nextLevel == currentLevel) {
      return 0; // Já está no nível máximo
    }

    final nextThreshold = levelThresholds[nextLevel]!;
    return nextThreshold;
  }
}
