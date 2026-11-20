import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/features/_template/data/template_api.dart';
import 'package:fluttea/features/_template/domain/models/template_model.dart';

abstract interface class TemplateRepository {
  Future<Result<TemplateModel>> getTemplate(String id);
}

final class TemplateRepositoryImpl implements TemplateRepository {
  const new(this._api);

  final TemplateApi _api;

  @override
  Future<Result<TemplateModel>> getTemplate(String id) async {
    final result = await _api.fetchTemplate(id);
    return switch (result) {
      Ok(:final value) => Result.ok(value.toDomain()),
      Err(:final failure) => Result.err(failure),
    };
  }
}
