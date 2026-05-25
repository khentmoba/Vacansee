import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vacansee/screens/landing/landing_screen.dart';

void main() {
  group('LandingScreen Footer Links Widget Tests', () {
    testWidgets('Tapping Search Listings footer link opens Search Listings modal', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      // Verify that the landing screen renders successfully
      expect(find.text('VacanSee'), findsWidgets);

      // Find the "Search Listings" text button in the footer and tap it
      final searchLink = find.widgetWithText(TextButton, 'Search Listings');
      expect(searchLink, findsOneWidget);
      await tester.ensureVisible(searchLink);
      await tester.tap(searchLink);
      await tester.pumpAndSettle();

      // Verify that the dialog is open and displays the title and unique content
      expect(find.text('Search Listings'), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('Start Searching Now'),
        ),
        findsOneWidget,
      );

      // Close the dialog
      await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.byIcon(Icons.close)));
      await tester.pumpAndSettle();

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Tapping How It Works footer link opens How It Works modal', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      final howItWorksLink = find.widgetWithText(TextButton, 'How It Works');
      expect(howItWorksLink, findsOneWidget);
      await tester.ensureVisible(howItWorksLink);
      await tester.tap(howItWorksLink);
      await tester.pumpAndSettle();

      expect(find.text('How It Works'), findsWidgets);
      expect(find.text('Browse & Filter'), findsOneWidget);

      // Close the dialog
      await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.byIcon(Icons.close)));
      await tester.pumpAndSettle();

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Tapping Safety Tips footer link opens Safety Tips modal', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      final safetyTipsLink = find.widgetWithText(TextButton, 'Safety Tips');
      expect(safetyTipsLink, findsOneWidget);
      await tester.ensureVisible(safetyTipsLink);
      await tester.tap(safetyTipsLink);
      await tester.pumpAndSettle();

      expect(find.text('Safety Tips'), findsWidgets);
      expect(find.text('Verify Listings'), findsOneWidget);

      // Close the dialog
      await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.byIcon(Icons.close)));
      await tester.pumpAndSettle();

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Tapping List Your Property footer link opens List Your Property modal', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      final listPropertyLink = find.widgetWithText(TextButton, 'List Your Property');
      expect(listPropertyLink, findsOneWidget);
      await tester.ensureVisible(listPropertyLink);
      await tester.tap(listPropertyLink);
      await tester.pumpAndSettle();

      expect(find.text('List Your Property'), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('Sign Up as Owner'),
        ),
        findsOneWidget,
      );

      // Close the dialog
      await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.byIcon(Icons.close)));
      await tester.pumpAndSettle();

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Tapping Pricing footer link opens Pricing modal', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      final pricingLink = find.widgetWithText(TextButton, 'Pricing');
      expect(pricingLink, findsOneWidget);
      await tester.ensureVisible(pricingLink);
      await tester.tap(pricingLink);
      await tester.pumpAndSettle();

      expect(find.text('VacanSee Pricing'), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('Start Free (Always Free)'),
        ),
        findsOneWidget,
      );

      // Close the dialog
      await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.byIcon(Icons.close)));
      await tester.pumpAndSettle();

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Tapping About Us footer link opens About Us modal', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      final aboutUsLink = find.widgetWithText(TextButton, 'About Us');
      expect(aboutUsLink, findsOneWidget);
      await tester.ensureVisible(aboutUsLink);
      await tester.tap(aboutUsLink);
      await tester.pumpAndSettle();

      expect(find.text('About VacanSee'), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('Join the Community'),
        ),
        findsOneWidget,
      );

      // Close the dialog
      await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.byIcon(Icons.close)));
      await tester.pumpAndSettle();

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Tapping Contact footer link opens Contact modal', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      final contactLink = find.widgetWithText(TextButton, 'Contact');
      expect(contactLink, findsOneWidget);
      await tester.ensureVisible(contactLink);
      await tester.tap(contactLink);
      await tester.pumpAndSettle();

      expect(find.text('Contact Us'), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('Send Message'),
        ),
        findsOneWidget,
      );

      // Close the dialog
      await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.byIcon(Icons.close)));
      await tester.pumpAndSettle();

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Tapping Privacy Policy footer link opens Privacy Policy modal', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      final privacyPolicyLink = find.widgetWithText(TextButton, 'Privacy Policy');
      expect(privacyPolicyLink, findsOneWidget);
      await tester.ensureVisible(privacyPolicyLink);
      await tester.tap(privacyPolicyLink);
      await tester.pumpAndSettle();

      expect(find.text('Privacy Policy'), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('Accept & Close'),
        ),
        findsOneWidget,
      );

      // Close the dialog
      await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.byIcon(Icons.close)));
      await tester.pumpAndSettle();

      await tester.binding.setSurfaceSize(null);
    });
  });
}
