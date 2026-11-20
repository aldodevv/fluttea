import 'package:flutter/foundation.dart';

@immutable
final class TemplateModel {
  const new({required this.id, required this.title, required this.description});

  final String id;
  final String title;
  final String description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateModel &&
          other.id == id &&
          other.title == title &&
          other.description == description;

  @override
  int get hashCode => Object.hash(id, title, description);
}
