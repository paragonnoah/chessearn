import 'package:flutter/material.dart';

class LearningCategory {
  final String id;
  final String title;
  final String icon;
  final List<Lesson> lessons;

  LearningCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.lessons,
  });

  factory LearningCategory.fromJson(Map<String, dynamic> json) {
    return LearningCategory(
      id: json['id']?.toString() ?? 'category_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Untitled Category',
      icon: json['icon']?.toString() ?? Icons.school.codePoint.toString(),
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((lessonJson) => Lesson.fromJson(lessonJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    };
  }
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final int difficulty;
  bool completed;
  final double progress;
  final String icon;
  final String? source;
  final List<String> tags;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.completed,
    required this.progress,
    required this.icon,
    this.source,
    this.tags = const [],
  }) {
    if (progress < 0.0 || progress > 1.0) {
      throw ArgumentError('Progress must be between 0.0 and 1.0');
    }
    if (difficulty < 0) {
      throw ArgumentError('Difficulty must be non-negative');
    }
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final progress = (json['progress'] as num?)?.toDouble() ?? 0.0;
    final difficulty = (json['difficulty'] as num?)?.toInt() ?? 0;
    return Lesson(
      id: json['id']?.toString() ?? 'lesson_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Untitled Lesson',
      description: json['description']?.toString() ?? 'No description available',
      difficulty: difficulty < 0 ? 0 : difficulty,
      completed: json['completed'] as bool? ?? false,
      progress: progress.clamp(0.0, 1.0),
      icon: json['icon']?.toString() ?? Icons.book.codePoint.toString(),
      source: json['source']?.toString(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'completed': completed,
      'progress': progress,
      'icon': icon,
      if (source != null) 'source': source,
      if (tags.isNotEmpty) 'tags': tags,
    };
  }

  Lesson copyWith({bool? completed, double? progress}) {
    return Lesson(
      id: id,
      title: title,
      description: description,
      difficulty: difficulty,
      completed: completed ?? this.completed,
      progress: progress?.clamp(0.0, 1.0) ?? this.progress,
      icon: icon,
      source: source,
      tags: tags,
    );
  }
}

class Puzzle {
  final String id;
  final String title;
  final String fen;
  final String solution;
  final int difficulty;
  final bool completed;
  final double progress;
  final String icon;
  final String? source;
  final List<String> themes;

  Puzzle({
    required this.id,
    required this.title,
    required this.fen,
    required this.solution,
    required this.difficulty,
    required this.completed,
    required this.progress,
    required this.icon,
    this.source,
    this.themes = const [],
  }) {
    if (progress < 0.0 || progress > 1.0) {
      throw ArgumentError('Progress must be between 0.0 and 1.0');
    }
    if (difficulty < 0) {
      throw ArgumentError('Difficulty must be non-negative');
    }
    if (fen.isEmpty) {
      throw ArgumentError('FEN string cannot be empty');
    }
  }

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    final progress = (json['progress'] as num?)?.toDouble() ?? 0.0;
    final difficulty = (json['difficulty'] as num?)?.toInt() ?? 1;
    final fen = json['fen']?.toString() ?? 'rnbqkbnr/pppppppp/5n5/8/8/5N5/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
    return Puzzle(
      id: json['id']?.toString() ?? 'puzzle_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Daily Puzzle',
      fen: fen.isEmpty ? 'rnbqkbnr/pppppppp/5n5/8/8/5N5/PPPPPPPP/RNBQKBNR w KQkq - 0 1' : fen,
      solution: json['solution']?.toString() ?? 'Nf3',
      difficulty: difficulty < 0 ? 1 : difficulty,
      completed: json['completed'] as bool? ?? false,
      progress: progress.clamp(0.0, 1.0),
      icon: json['icon']?.toString() ?? Icons.extension.codePoint.toString(),
      source: json['source']?.toString(),
      themes: (json['themes'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fen': fen,
      'solution': solution,
      'difficulty': difficulty,
      'completed': completed,
      'progress': progress,
      'icon': icon,
      if (source != null) 'source': source,
      if (themes.isNotEmpty) 'themes': themes,
    };
  }

  Puzzle copyWith({bool? completed, double? progress}) {
    return Puzzle(
      id: id,
      title: title,
      fen: fen,
      solution: solution,
      difficulty: difficulty,
      completed: completed ?? this.completed,
      progress: progress?.clamp(0.0, 1.0) ?? this.progress,
      icon: icon,
      source: source,
      themes: themes,
    );
  }
}