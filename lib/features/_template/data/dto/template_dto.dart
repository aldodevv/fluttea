import 'package:fluttea/features/_template/domain/models/template_model.dart';

final class TemplateDto {
  const new({required this.id, required this.title, required this.description});

  factory fromJson(Map<String, dynamic> json) {
    return TemplateDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  final String id;
  final String title;
  final String description;

  TemplateModel toDomain() => TemplateModel(id: id, title: title, description: description);

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'description': description};
}
