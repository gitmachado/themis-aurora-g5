String onlyDigits(String value) => value.replaceAll(RegExp(r'\D'), '');

String formatDateLabel(DateTime? value) {
  if (value == null) return '--';
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

String formatRelativeDate(DateTime? value) {
  if (value == null) return 'Sem data';

  final now = DateTime.now();
  final diff = now.difference(value);
  if (diff.inMinutes < 1) return 'agora';
  if (diff.inMinutes < 60) return 'ha ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'ha ${diff.inHours} h';
  if (diff.inDays == 1) return 'ontem';
  if (diff.inDays < 7) return 'ha ${diff.inDays} dias';
  return formatDateLabel(value);
}

String formatFileSize(int? bytes) {
  if (bytes == null || bytes <= 0) return '--';
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(kb >= 100 ? 0 : 1)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(mb >= 100 ? 0 : 1)} MB';
}
