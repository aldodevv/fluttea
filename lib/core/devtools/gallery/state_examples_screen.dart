import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/devtools/gallery/state_cases/case1_async_view_section.dart';
import 'package:fluttea/core/devtools/gallery/state_cases/case2_form_mutation_section.dart';
import 'package:fluttea/core/devtools/gallery/state_cases/case3_session_reset_section.dart';
import 'package:fluttea/core/devtools/gallery/state_cases/case4_family_scoped_section.dart';
import 'package:fluttea/core/devtools/gallery/state_cases/case5_selective_rebuild_section.dart';
import 'package:fluttea/core/widgets/layout/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';

class StateExamplesScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('State Management Examples')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Case1AsyncViewSection(),
            SizedBox(height: Spacing.lg),
            Case2FormMutationSection(),
            SizedBox(height: Spacing.lg),
            Case3SessionResetSection(),
            SizedBox(height: Spacing.lg),
            Case4FamilyScopedSection(),
            SizedBox(height: Spacing.lg),
            Case5SelectiveRebuildSection(),
            SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }
}
