#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: ./tool/new_feature.sh <feature_name>"
  echo "Example: ./tool/new_feature.sh profile"
  exit 1
fi

FEATURE_NAME="$1"

# Validate snake_case
if ! [[ "$FEATURE_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Error: Feature name must be lowercase snake_case (e.g. 'order_history')"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TEMPLATE_DIR="lib/features/_template"
TARGET_DIR="lib/features/$FEATURE_NAME"

if [ -d "$TARGET_DIR" ]; then
  echo "Error: Feature directory $TARGET_DIR already exists."
  exit 1
fi

# Convert snake_case to PascalCase
PASCAL_CASE=$(echo "$FEATURE_NAME" | awk -F_ '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1' OFS="")
# Convert snake_case to camelCase
CAMEL_CASE=$(echo "$PASCAL_CASE" | awk '{print tolower(substr($0,1,1)) substr($0,2)}')

echo "Scaffolding feature: $FEATURE_NAME"
echo "  PascalCase: $PASCAL_CASE"
echo "  camelCase : $CAMEL_CASE"

# Copy template directory
cp -r "$TEMPLATE_DIR" "$TARGET_DIR"

# Rename files in target directory
mv "$TARGET_DIR/data/dto/template_dto.dart" "$TARGET_DIR/data/dto/${FEATURE_NAME}_dto.dart"
mv "$TARGET_DIR/data/template_api.dart" "$TARGET_DIR/data/${FEATURE_NAME}_api.dart"
mv "$TARGET_DIR/data/template_repository.dart" "$TARGET_DIR/data/${FEATURE_NAME}_repository.dart"
mv "$TARGET_DIR/domain/models/template_model.dart" "$TARGET_DIR/domain/models/${FEATURE_NAME}_model.dart"
mv "$TARGET_DIR/presentation/widgets/template_card.dart" "$TARGET_DIR/presentation/widgets/${FEATURE_NAME}_card.dart"
mv "$TARGET_DIR/presentation/screens/template_screen.dart" "$TARGET_DIR/presentation/screens/${FEATURE_NAME}_screen.dart"
mv "$TARGET_DIR/state/template_notifier.dart" "$TARGET_DIR/state/${FEATURE_NAME}_notifier.dart"

# Replace content placeholders
find "$TARGET_DIR" -type f -name "*.dart" | while read -r file; do
  sed -i '' "s/_template/$FEATURE_NAME/g" "$file"
  sed -i '' "s/template_/$FEATURE_NAME\_/g" "$file"
  sed -i '' "s/Template/$PASCAL_CASE/g" "$file"
  sed -i '' "s/template/$CAMEL_CASE/g" "$file"
done

# Scaffold test directory
TEST_DIR="test/features/$FEATURE_NAME"
mkdir -p "$TEST_DIR"
cat <<EOF > "$TEST_DIR/${FEATURE_NAME}_test.dart"
import 'package:flutter_test/flutter_test.dart';

import 'package:fluttea/features/$FEATURE_NAME/domain/models/${FEATURE_NAME}_model.dart';

void main() {
  group('$PASCAL_CASE Feature Tests', () {
    test('instantiates $PASCAL_CASE model correctly', () {
      const model = ${PASCAL_CASE}Model(
        id: 'test-1',
        title: 'Test Title',
        description: 'Test Description',
      );

      expect(model.id, 'test-1');
      expect(model.title, 'Test Title');
    });
  });
}
EOF

echo "✓ Successfully scaffolded feature in $TARGET_DIR"
echo "✓ Scaffolded tests in $TEST_DIR"
echo ""
echo "Next steps:"
echo "1. Register route in lib/app/router/routes.dart:"
echo "   GoRoute(path: '/$FEATURE_NAME', builder: (context, state) => const ${PASCAL_CASE}Screen())"
echo "2. Run 'rtk fvm dart format' and 'rtk fvm dart analyze'"
