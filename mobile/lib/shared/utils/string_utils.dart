final class StringUtils {
  const StringUtils._();

  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  static String formatFirstAndLastName(String name) {
    if (name.isEmpty) return 'Lead sem nome';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts.first} ${parts.last}';
    }
    return parts.first;
  }
}
