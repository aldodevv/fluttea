import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/core/network/network_providers.dart';
import 'package:fluttea/features/_template/data/template_api.dart';
import 'package:fluttea/features/_template/data/template_repository.dart';
import 'package:fluttea/features/_template/domain/models/template_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return TemplateRepositoryImpl(TemplateApiImpl(client));
});

class TemplateNotifier extends AsyncNotifier<TemplateModel?> {
  @override
  Future<TemplateModel?> build() async => null;

  Future<void> load(String id) async {
    state = const AsyncValue.loading();
    final repository = ref.read(templateRepositoryProvider);
    final result = await repository.getTemplate(id);

    state = switch (result) {
      Ok(:final value) => AsyncValue.data(value),
      Err(:final failure) => AsyncValue.error(failure, failure.stackTrace ?? StackTrace.current),
    };
  }
}

final AsyncNotifierProvider<TemplateNotifier, TemplateModel?> templateNotifierProvider =
    AsyncNotifierProvider.autoDispose<TemplateNotifier, TemplateModel?>(TemplateNotifier.new);
