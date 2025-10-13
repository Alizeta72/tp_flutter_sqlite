import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tp_flutter_sqlite/main.dart';
import 'package:tp_flutter_sqlite/screens/login_page.dart';
import 'package:tp_flutter_sqlite/screens/signup_page.dart';
import 'package:tp_flutter_sqlite/screens/home_screen.dart';

void main() {
  testWidgets('Test navigation login/signup/home', (WidgetTester tester) async {
    //  Charger l'application
    await tester.pumpWidget(MyApp());

    // Vérifie que LoginPage s'affiche
    expect(find.byType(LoginPage), findsOneWidget);

    //  Vérifie que le bouton "Créer un compte" existe et navigue vers SignupPage
    final createAccountButton = find.text('Créer un compte');
    expect(createAccountButton, findsOneWidget);

    await tester.tap(createAccountButton);
    await tester.pumpAndSettle(); // Attend la navigation

    expect(find.byType(SignupPage), findsOneWidget);

    //  Remplir les champs de création de compte (simulation)
    await tester.enterText(find.byType(TextField).at(0), 'testuser');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.enterText(find.byType(TextField).at(2), 'test@test.com');
    await tester.enterText(find.byType(TextField).at(3), '2000-01-01');

    // Cliquer sur "Créer un compte"
    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();

    // Après création, on retourne normalement sur LoginPage
    expect(find.byType(LoginPage), findsOneWidget);

    // Remplir les champs de login
    await tester.enterText(find.byType(TextField).at(0), 'testuser');
    await tester.enterText(find.byType(TextField).at(1), '123456');

    // Cliquer sur "Se connecter"
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    // Vérifie que l'on arrive sur HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);

    //  Vérifie que les boutons vers les cours et l'emploi du temps existent
    expect(find.text('Voir les cours'), findsOneWidget);
    expect(find.text('Voir l\'emploi du temps'), findsOneWidget);
  });
}
