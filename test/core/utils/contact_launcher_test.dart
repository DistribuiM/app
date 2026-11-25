import 'package:app_distribuim/core/utils/contact_launcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('phoneCallUri', () {
    test('normalizes a formatted Brazilian number with DDD', () {
      expect(phoneCallUri('(11) 99999-1234').toString(), 'tel:5511999991234');
    });

    test('keeps an explicit international number', () {
      expect(phoneCallUri('+1 (650) 555-0100').toString(), 'tel:16505550100');
    });

    test('rejects a number without a valid DDD', () {
      expect(() => phoneCallUri('9999-1234'), throwsA(isA<FormatException>()));
    });
  });

  group('whatsAppUri', () {
    test('adds the Brazilian country code and includes a message', () {
      const message = 'Olá, Cliente! O saldo pendente é R\$ 125,50.';
      final uri = whatsAppUri('(11) 99999-1234', message: message);

      expect(uri.scheme, 'https');
      expect(uri.host, 'wa.me');
      expect(uri.path, '/5511999991234');
      expect(uri.queryParameters['text'], message);
    });

    test('opens the chat without a prefilled message when omitted', () {
      final uri = whatsAppUri('5511999991234');

      expect(uri.host, 'wa.me');
      expect(uri.path, '/5511999991234');
      expect(uri.queryParameters, isEmpty);
    });
  });
}
