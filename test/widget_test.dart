import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/modules/auth/data/auth_repository.dart';
import 'package:frontend/modules/auth/presentation/pages/login_page.dart';
import 'package:frontend/modules/auth/presentation/pages/onboarding/onboarding_page.dart';
import 'package:frontend/modules/auth/presentation/pages/welcome_page.dart';
import 'package:frontend/modules/auth/presentation/validators/password_validator.dart';

void main() {
  testWidgets('welcome page shows the authentication entry actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const WelcomePage()),
    );

    expect(find.text('Selamat datang di Gawen'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Daftar Pemilik Usaha'), findsOneWidget);
    expect(find.text('Gabung sebagai Karyawan'), findsOneWidget);
  });

  testWidgets('onboarding starts with the first slide', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const OnboardingPage()),
    );

    expect(find.text('Tim kerja lebih teratur.'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);
  });

  testWidgets('login offers owner and employee modes', (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AuthBloc(AuthRepository(client: Dio())),
        child: MaterialApp(theme: AppTheme.light, home: const LoginPage()),
      ),
    );

    expect(find.text('Masuk sebagai Karyawan'), findsOneWidget);
    expect(
      find.text(
        'Jika akun belum terhubung ke perusahaan, kamu akan diarahkan untuk memasukkan kode bisnis.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Pemilik'));
    await tester.pump();
    expect(find.text('Masuk sebagai Pemilik'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  test('new password validation uses the shared eight-character rule', () {
    expect(PasswordValidator.validateNewPassword(''), isNotNull);
    expect(PasswordValidator.validateNewPassword('x'), isNotNull);
    expect(PasswordValidator.validateNewPassword('1234567'), isNotNull);
    expect(PasswordValidator.validateNewPassword('12345678'), isNull);
    expect(PasswordValidator.validateNewPassword('123456789'), isNull);
    expect(PasswordValidator.validateNewPassword('lowercas'), isNull);
    expect(PasswordValidator.validateNewPassword('        '), isNull);
    expect(
      PasswordValidator.validateNewPassword(List.filled(128, 'a').join()),
      isNull,
    );
    expect(
      PasswordValidator.validateNewPassword(List.filled(129, 'a').join()),
      isNotNull,
    );
    expect(PasswordValidator.validateNewPassword('😀😀😀😀'), isNotNull);
    expect(PasswordValidator.validateNewPassword('😀😀😀😀😀😀😀😀'), isNull);
    expect(
      PasswordValidator.validateConfirmation(
        confirmation: 'different',
        password: '12345678',
      ),
      isNotNull,
    );
    expect(
      PasswordValidator.validateConfirmation(
        confirmation: '12345678',
        password: '12345678',
      ),
      isNull,
    );
  });

  test('auth routing sends each access state to a safe destination', () {
    expect(safeAuthReturnPath('https://example.com'), isNull);
    expect(safeAuthReturnPath('${AppRoutes.home}?external=true'), isNull);
    expect(safeAuthReturnPath(AppRoutes.join), AppRoutes.join);
    expect(
      resolveAuthRedirect(
        location: AppRoutes.home,
        auth: const AuthState(status: AuthStatus.unauthenticated),
      ),
      '/login?from=%2Fhome',
    );
    expect(
      resolveAuthRedirect(
        location: AppRoutes.home,
        auth: const AuthState(status: AuthStatus.initial),
      ),
      AppRoutes.splash,
    );
    expect(
      resolveAuthRedirect(
        location: AppRoutes.home,
        auth: const AuthState(
          status: AuthStatus.authenticated,
          user: {'id': 'user'},
          membershipAccess: MembershipAccess.pending,
        ),
      ),
      AppRoutes.pending,
    );
    expect(
      resolveAuthRedirect(
        location: AppRoutes.pending,
        auth: const AuthState(
          status: AuthStatus.authenticated,
          user: {'id': 'user'},
          membershipAccess: MembershipAccess.pending,
        ),
      ),
      isNull,
    );
    expect(
      resolveAuthRedirect(
        location: AppRoutes.pending,
        auth: const AuthState(
          status: AuthStatus.authenticated,
          user: {'id': 'user'},
          membershipAccess: MembershipAccess.active,
        ),
      ),
      AppRoutes.home,
    );
    expect(
      resolveAuthRedirect(
        location: AppRoutes.login,
        auth: const AuthState(
          status: AuthStatus.authenticated,
          user: {'id': 'employee'},
          membershipAccess: MembershipAccess.none,
        ),
      ),
      AppRoutes.join,
    );
    expect(
      resolveAuthRedirect(
        location: AppRoutes.login,
        auth: const AuthState(
          status: AuthStatus.authenticated,
          user: {'id': 'user'},
          membershipAccess: MembershipAccess.pending,
        ),
        returnTo: AppRoutes.home,
      ),
      AppRoutes.pending,
    );
    expect(
      resolveAuthRedirect(
        location: AppRoutes.home,
        auth: const AuthState(
          status: AuthStatus.authenticated,
          user: {'id': 'user'},
          membershipAccess: MembershipAccess.active,
        ),
      ),
      isNull,
    );
    expect(
      resolveAuthRedirect(
        location: AppRoutes.welcome,
        auth: const AuthState(
          status: AuthStatus.authenticated,
          user: {'id': 'user'},
        ),
      ),
      AppRoutes.join,
    );
  });
}
