extension UrlDomainX on String? {
  String get domainLabel {
    final value = this;
    if (value == null || value.isEmpty) return 'news.ycombinator.com';
    final uri = Uri.tryParse(value);
    final host = uri?.host.isNotEmpty == true ? uri!.host : value;
    return host.replaceFirst('www.', '');
  }
}
