import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fptu_obsidian_brain/main.dart';

void main() {
  testWidgets('FPTU Obsidian Brain app smoke test', (
    WidgetTester tester,
  ) async {
    // Cấu hình màn hình Desktop kích thước chuẩn 1280x800
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const FptuObsidianBrainApp());
    await tester.pumpAndSettle();

    // Verify header and initial components render
    expect(find.text('FPTU SE Knowledge'), findsOneWidget);
    expect(find.text('Mở Vault'), findsOneWidget);
    expect(find.text('Graph View'), findsOneWidget);
    expect(find.text('AI Study Buddy'), findsOneWidget);
  });
}
