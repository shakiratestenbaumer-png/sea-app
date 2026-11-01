import 'package:flutter_test/flutter_test.dart';
import 'package:swiss_energy_assistant/core/swiss_format.dart';

void main() {
  test('Swiss price formatting in Rp', () {
    expect(
      SwissFormat.formatPrice(0.2147, unit: PriceUnit.rp),
      '21.5 Rp./kWh',
    );
  });
}
