const _monthNames = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

/// R$ 1.234,50  (negativos: -R$ 10,00)
String formatMoney(double value, {bool showSign = false}) {
  final negative = value < 0;
  final cents = (value.abs() * 100).round();
  final intPart = (cents ~/ 100).toString();
  final decPart = (cents % 100).toString().padLeft(2, '0');

  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write('.');
    buffer.write(intPart[i]);
  }

  final prefix = negative ? '-' : (showSign ? '+' : '');
  return '${prefix}R\$ $buffer,$decPart';
}

String monthName(int month) => _monthNames[month - 1];

/// "Outubro 2026"
String monthYear(DateTime d) => '${monthName(d.month)} ${d.year}';

/// "02/10"
String shortDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

String timeLabel(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// "Hoje", "Ontem" ou "12 de setembro"
String dayLabel(DateTime d, {DateTime? now}) {
  final today = dayOnly(now ?? DateTime.now());
  final day = dayOnly(d);
  if (day == today) return 'Hoje';
  if (day == today.subtract(const Duration(days: 1))) return 'Ontem';
  return '${d.day} de ${monthName(d.month).toLowerCase()}';
}

/// "12 de setembro de 2026"
String longDate(DateTime d) =>
    '${d.day} de ${monthName(d.month).toLowerCase()} de ${d.year}';

String greeting(DateTime now) {
  if (now.hour < 5) return 'Boa madrugada';
  if (now.hour < 12) return 'Bom dia';
  if (now.hour < 18) return 'Boa tarde';
  return 'Boa noite';
}
