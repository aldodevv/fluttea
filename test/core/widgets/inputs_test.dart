import 'package:fluttea/core/theme/app_theme.dart';
import 'package:fluttea/core/widgets/inputs/app_dropdown.dart';
import 'package:fluttea/core/widgets/inputs/app_text_field.dart';
import 'package:fluttea/core/widgets/inputs/otp_field.dart';
import 'package:fluttea/core/widgets/inputs/search_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('Inputs Widgets', () {
    Widget createSubject({required Widget child}) {
      return MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets('AppTextField handles input and toggles password', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createSubject(
          child: AppTextField(controller: controller, label: 'Kata Sandi', isPassword: true),
        ),
      );

      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'rahasia123');
      expect(controller.text, equals('rahasia123'));

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('AppDropdown selects value', (tester) async {
      String? selected;
      await tester.pumpWidget(
        createSubject(
          child: AppDropdown<String>(
            label: 'Pilih Role',
            value: 'member',
            items: const [
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'member', child: Text('Member')),
            ],
            onChanged: (val) => selected = val,
          ),
        ),
      );

      expect(find.text('Member'), findsOneWidget);
      await tester.tap(find.text('Member'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Admin').last);
      await tester.pumpAndSettle();
      expect(selected, equals('admin'));
    });

    testWidgets('OtpField triggers onCompleted', (tester) async {
      String? completedCode;
      await tester.pumpWidget(
        createSubject(child: OtpField(length: 4, onCompleted: (code) => completedCode = code)),
      );

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(4));

      await tester.enterText(textFields.at(0), '1');
      await tester.enterText(textFields.at(1), '2');
      await tester.enterText(textFields.at(2), '3');
      await tester.enterText(textFields.at(3), '4');

      expect(completedCode, equals('1234'));
    });

    testWidgets('SearchField debounces query and clears input', (tester) async {
      String? searchResult;
      await tester.pumpWidget(
        createSubject(
          child: SearchField(
            debounceDelay: const Duration(milliseconds: 50),
            onSearch: (q) => searchResult = q,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'fluttea');
      await tester.pump();
      expect(searchResult, isNull);

      await tester.pump(const Duration(milliseconds: 60));
      expect(searchResult, equals('fluttea'));

      expect(find.byIcon(Icons.clear), findsOneWidget);
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump(const Duration(milliseconds: 60));
      expect(searchResult, equals(''));
    });
  });
}
