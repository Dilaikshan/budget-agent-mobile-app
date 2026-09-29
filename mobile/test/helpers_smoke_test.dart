import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test(
    'seed creates profile, accounts with openings and default categories',
    () async {
      final env = TestEnv();
      final ids = await env.seed();
      expect(ids.cash, isNotEmpty);
      expect((await env.db.select(env.db.accounts).get()).length, 2);
      expect(
        (await env.db.select(env.db.categories).get()).length,
        greaterThan(8),
      );
      await env.dispose();
    },
  );
}
