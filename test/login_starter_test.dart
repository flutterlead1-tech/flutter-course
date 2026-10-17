import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tutorial_project/login_starter/data/auth_repository.dart';
import 'package:tutorial_project/login_starter/main.dart';
import 'package:tutorial_project/login_starter/models/app_user.dart';
import 'package:tutorial_project/login_starter/providers/auth_providers.dart';
import 'package:tutorial_project/login_starter/utils/auth_messages.dart';

/// A pretend account system: no Firebase, no internet.
/// It throws the same messages the real app shows for Firebase's error codes.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({Map<String, String>? accounts}) : _passwords = {...?accounts};

  final Map<String, String> _passwords; // email → password
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _current;

  @override
  Stream<AppUser?> userChanges() async* {
    yield _current; // like Firebase: send the saved login first
    yield* _controller.stream;
  }

  void _set(AppUser? user) {
    _current = user;
    _controller.add(user);
  }

  @override
  Future<void> logIn({required String email, required String password}) async {
    if (_passwords[email] != password) throw AuthException(authMessage('invalid-credential'));
    _set(AppUser(uid: 'uid-$email', email: email));
  }

  @override
  Future<void> register({required String name, required String email, required String password}) async {
    if (_passwords.containsKey(email)) throw AuthException(authMessage('email-already-in-use'));
    _passwords[email] = password;
    _set(AppUser(uid: 'uid-$email', email: email, name: name));
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> logOut() async => _set(null);
}

Widget appWith(FakeAuthRepository fake) => ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
      child: const LoginStarterApp(),
    );

void phoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2600);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  test('every Firebase error code has a clear message', () {
    expect(authMessage('email-already-in-use'), 'An account already exists for this email. Try logging in.');
    expect(authMessage('weak-password'), 'Password must be at least 6 characters.');
    expect(authMessage('invalid-email'), 'Enter a valid email address.');
    for (final code in ['invalid-credential', 'wrong-password', 'user-not-found']) {
      expect(authMessage(code), 'Email or password is incorrect.');
    }
    expect(authMessage('network-request-failed'), startsWith('No internet connection'));
    expect(authMessage('something-new'), 'Something went wrong. Please try again.');
  });

  testWidgets('wrong password shows the message; right password opens Home; log out returns', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(appWith(FakeAuthRepository(accounts: {'test@example.com': 'Test@1234'})));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    // Empty form: validation stops it before "Firebase" is asked.
    await tester.tap(find.text('Log in'));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'test@example.com');
    await tester.enterText(fields.at(1), 'wrong123');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Email or password is incorrect.'), findsOneWidget);

    await tester.enterText(fields.at(1), 'Test@1234');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Hello, test'), findsOneWidget); // name from the email

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('register validates, rejects a used email, then logs the new user in', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(appWith(FakeAuthRepository(accounts: {'taken@example.com': 'secret1'})));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ananya Rao');
    await tester.enterText(fields.at(1), 'taken@example.com');
    await tester.enterText(fields.at(2), '123');
    await tester.enterText(fields.at(3), '124');
    await tester.tap(find.text('Create account'));
    await tester.pump();
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    expect(find.text('Passwords do not match'), findsOneWidget);

    await tester.enterText(fields.at(2), 'secret12');
    await tester.enterText(fields.at(3), 'secret12');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('An account already exists for this email. Try logging in.'), findsOneWidget);

    await tester.enterText(fields.at(1), 'ananya@example.com');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Ananya Rao'), findsOneWidget); // register screen closed, gate shows Home
  });

  testWidgets('a saved login goes straight to Home (the restart test)', (tester) async {
    phoneSize(tester);
    final fake = FakeAuthRepository(accounts: {'test@example.com': 'Test@1234'});
    await fake.logIn(email: 'test@example.com', password: 'Test@1234');

    await tester.pumpWidget(appWith(fake));
    await tester.pumpAndSettle();
    expect(find.text('Hello, test'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
  });
}
