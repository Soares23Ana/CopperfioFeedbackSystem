import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  static final RegExp _digitOnly = RegExp(r'\D');
  static const int maxDigits = 11;

  static String digitsOnly(String value) {
    return value.replaceAll(_digitOnly, '');
  }

  static String format(String value) {
    final digits = digitsOnly(value);
    return _formatDigits(digits);
  }

  static String _formatDigits(String digits) {
    final buffer = StringBuffer();
    final length = digits.length.clamp(0, maxDigits);

    for (var i = 0; i < length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7 && length > 10) buffer.write('-');
      if (i == 6 && length <= 10) buffer.write('-');
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = digitsOnly(newValue.text);
    final formatted = _formatDigits(digits);
    final selectionIndex = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
