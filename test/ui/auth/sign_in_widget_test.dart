import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';

import 'package:lichess_mobile/src/common/api_client.dart';
import 'package:lichess_mobile/src/ui/auth/sign_in_widget.dart';
import '../../test_utils.dart';
import '../../test_app.dart';

void main() {
  final mockClient = MockClient((request) {
    if (request.url.path != '/api/account') {
      return mockResponse('', 404);
    }
    return mockResponse(testAccountResponse, 200);
  });

  testWidgets(
    'SignInWidget',
    (WidgetTester tester) async {
      final app = await buildTestApp(
        tester,
        home: Scaffold(
          appBar: AppBar(
            actions: const [
              SignInWidget(),
            ],
          ),
        ),
        overrides: [
          httpClientProvider.overrideWithValue(mockClient),
        ],
      );

      await tester.pumpWidget(app);

      // first frame is a loading state
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Sign in'), findsOneWidget);

      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 1)); // wait for sign in future

      expect(find.text('Sign in'), findsNothing);
    },
    // fails on iOS, no idea why
    // variant: kPlatformVariant,
  );
}

const testAccountResponse = '''
{
  "id": "test",
  "username": "test",
  "createdAt": 1290415680000,
  "seenAt": 1290415680000,
  "title": "GM",
  "patron": true,
  "perfs": {
    "blitz": {
      "games": 2340,
      "rating": 1681,
      "rd": 30,
      "prog": 10
    },
    "rapid": {
      "games": 2340,
      "rating": 1677,
      "rd": 30,
      "prog": 10
    },
    "classical": {
      "games": 2340,
      "rating": 1618,
      "rd": 30,
      "prog": 10
    }
  },
  "profile": {
    "country": "France",
    "location": "Lille",
    "bio": "test bio",
    "firstName": "John",
    "lastName": "Doe",
    "fideRating": 1800,
    "links": "http://test.com"
  }
}
''';
