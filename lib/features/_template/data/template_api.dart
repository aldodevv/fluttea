import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/core/network/api_client.dart';
import 'package:fluttea/features/_template/data/dto/template_dto.dart';

abstract interface class TemplateApi {
  Future<Result<TemplateDto>> fetchTemplate(String id);
}

final class TemplateApiImpl implements TemplateApi {
  const new(this._client);

  final ApiClient _client;

  @override
  Future<Result<TemplateDto>> fetchTemplate(String id) async {
    return await _client.request<TemplateDto>(
      HttpMethod.get,
      '/templates/$id',
      fromJson: (json) => TemplateDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
