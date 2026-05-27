import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vacansee/screens/landing/landing_screen.dart';

void main() {
  group('LandingScreen Footer Links Widget Tests', () {
    Future<void> openDialog(WidgetTester tester, String linkText) async {
      final link = find.text(linkText);
      expect(link, findsOneWidget);
      await tester.ensureVisible(link);
      await tester.tap(link);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    Future<void> closeDialog(WidgetTester tester) async {
      await tester.tap(find.descendant(
        of: find.byType(Dialog),
        matching: find.byIcon(Icons.close),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('Tapping Search Rooms opens Search Listings modal', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('VacanSee'), findsWidgets);

      await openDialog(tester, 'Search Rooms');

      expect(find.text('Search Listings'), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('Start Searching Now'),
        ),
        findsOneWidget,
      );

      await closeDialog(tester);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Tapping Student Guides opens How It Works modal', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await openDialog(tester, 'Student Guides');

      expect(find.text('How It Works'), findsWidgets);
      expect(find.text('Browse & Filter'), findsOneWidget);

      await closeDialog(tester);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Tapping List Property opens List Your Property modal', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await openDialog(tester, 'List Property');

      expect(find.text('List Your Property'), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('Sign Up as Owner'),
        ),
        findsOneWidget,
      );

      await closeDialog(tester);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Tapping About Us opens About VacanSee modal', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await openDialog(tester, 'About Us');

      expect(find.text('About VacanSee'), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('Join the Community'),
        ),
        findsOneWidget,
      );

      await closeDialog(tester);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Tapping Premium Listing opens Pricing modal', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await openDialog(tester, 'Premium Listing');

      expect(find.text('VacanSee Pricing'), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('Start Free (Always Free)'),
        ),
        findsOneWidget,
      );

      await closeDialog(tester);
      await tester.binding.setSurfaceSize(null);
    });
  });
}
