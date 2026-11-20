import 'package:fluttea/app/providers.dart';
import 'package:fluttea/core/devtools/tabs/env_tab.dart';
import 'package:fluttea/core/devtools/tabs/log_tab.dart';
import 'package:fluttea/core/devtools/tabs/network_tab.dart';
import 'package:fluttea/core/devtools/tabs/security_tab.dart';
import 'package:fluttea/core/devtools/tabs/state_tab.dart';
import 'package:fluttea/core/devtools/tabs/storage_tab.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/widgets/layout/app_scaffold.dart';
import 'package:fluttea/core/widgets/states/empty_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class DevToolsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvProvider);
    final l10n = context.l10n;

    if (!env.devToolsEnabled) {
      return AppScaffold(
        body: EmptyView(title: l10n.devToolsDisabledTitle, message: l10n.devToolsDisabledMessage),
      );
    }

    final tabs = [
      Tab(text: l10n.devToolsTabEnv, icon: const Icon(Icons.tune, size: 20)),
      Tab(text: l10n.devToolsTabNetwork, icon: const Icon(Icons.http, size: 20)),
      Tab(text: l10n.devToolsTabStorage, icon: const Icon(Icons.storage, size: 20)),
      Tab(text: l10n.devToolsTabLog, icon: const Icon(Icons.article_outlined, size: 20)),
      Tab(text: l10n.devToolsTabSecurity, icon: const Icon(Icons.shield_outlined, size: 20)),
      Tab(text: l10n.devToolsTabState, icon: const Icon(Icons.alt_route, size: 20)),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: AppScaffold(
        appBar: AppBar(
          title: Text(l10n.devToolsTitle),
          bottom: TabBar(isScrollable: true, tabAlignment: TabAlignment.start, tabs: tabs),
        ),
        body: const TabBarView(
          children: [EnvTab(), NetworkTab(), StorageTab(), LogTab(), SecurityTab(), StateTab()],
        ),
      ),
    );
  }
}
