
import 'package:flutter/material.dart';
import 'package:chessearn_new/screens/models.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/theme.dart';

class LessonDetailScreen extends StatelessWidget {
  final Lesson lesson;
  final String? userId;

  const LessonDetailScreen({super.key, required this.lesson, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = ChessEarnTheme.themeData;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lesson.title,
          style: theme.textTheme.titleLarge!.copyWith(
            color: ChessEarnTheme.getColor('text-light'),
          ),
        ),
        backgroundColor: ChessEarnTheme.getColor('brand-dark'),
        elevation: theme.appBarTheme.elevation,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.description,
              style: theme.textTheme.bodyLarge!.copyWith(
                color: ChessEarnTheme.getColor('text-light'),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.updateLessonProgress(userId, lesson.id, true);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update lesson: $e')),
                  );
                }
              },
              style: theme.elevatedButtonTheme.style!.copyWith(
                backgroundColor: WidgetStateProperty.all(ChessEarnTheme.getColor('btn-primary')),
                foregroundColor: WidgetStateProperty.all(ChessEarnTheme.getColor('text-light')),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              child: Text(
                'Complete Lesson',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: ChessEarnTheme.getColor('text-light'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
