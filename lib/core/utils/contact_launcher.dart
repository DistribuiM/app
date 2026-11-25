import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactLaunchException implements Exception {
  const ContactLaunchException(this.message);

  final String message;
}

Uri phoneCallUri(String phone) {
  return Uri(scheme: 'tel', path: _normalizePhoneNumber(phone));
}

Uri whatsAppUri(String phone, {String? message}) {
  final number = _normalizePhoneNumber(phone);
  return Uri.https(
    'wa.me',
    '/$number',
    message == null ? null : {'text': message},
  );
}

Future<void> openPhoneCall(String phone) async {
  final launched = await launchUrl(
    phoneCallUri(phone),
    mode: LaunchMode.externalApplication,
  );
  if (!launched) {
    throw const ContactLaunchException(
      'Não foi possível abrir o aplicativo de telefone.',
    );
  }
}

Future<void> openWhatsApp(String phone, {String? message}) async {
  final launched = await launchUrl(
    whatsAppUri(phone, message: message),
    mode: LaunchMode.externalApplication,
  );
  if (!launched) {
    throw const ContactLaunchException(
      'Não foi possível abrir o WhatsApp para esse telefone.',
    );
  }
}

Future<void> runContactAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
  } on FormatException catch (error) {
    _showContactError(messenger, error.message.toString());
  } on ContactLaunchException catch (error) {
    _showContactError(messenger, error.message);
  } on PlatformException catch (error, stackTrace) {
    debugPrint('Erro ao abrir aplicativo de contato: $error\n$stackTrace');
    _showContactError(
      messenger,
      'Não foi possível abrir o aplicativo. Verifique o telefone cadastrado.',
    );
  } on MissingPluginException catch (error, stackTrace) {
    debugPrint('Plugin de contato indisponível: $error\n$stackTrace');
    _showContactError(
      messenger,
      'Não foi possível abrir o aplicativo. Verifique o telefone cadastrado.',
    );
  }
}

String _normalizePhoneNumber(String phone) {
  final input = phone.trim();
  var digits = input.replaceAll(RegExp(r'\D'), '');

  if (digits.isEmpty) {
    throw const FormatException('O cliente não possui telefone cadastrado.');
  }

  final hasInternationalPrefix =
      input.startsWith('+') || input.startsWith('00');
  if (input.startsWith('00')) {
    digits = digits.substring(2);
  }

  if (hasInternationalPrefix) {
    return _validateInternationalNumber(digits);
  }

  if (digits.startsWith('55') && (digits.length == 12 || digits.length == 13)) {
    return digits;
  }

  if (digits.startsWith('0') && (digits.length == 11 || digits.length == 12)) {
    digits = digits.substring(1);
  }

  if (digits.length == 10 || digits.length == 11) {
    return '55$digits';
  }

  throw const FormatException(
    'Telefone inválido. Informe o DDD e o número do cliente.',
  );
}

String _validateInternationalNumber(String digits) {
  if (digits.length < 8 || digits.length > 15) {
    throw const FormatException('O telefone cadastrado não é válido.');
  }
  return digits;
}

void _showContactError(ScaffoldMessengerState messenger, String message) {
  if (!messenger.mounted) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
