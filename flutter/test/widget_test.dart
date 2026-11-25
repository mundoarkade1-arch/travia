import 'package:flutter_test/flutter_test.dart';
import 'package:travia/main.dart';

void main() {
  test('declara o aplicativo Travia', () {
    expect(const TraviaApp(), isA<TraviaApp>());
  });
}
