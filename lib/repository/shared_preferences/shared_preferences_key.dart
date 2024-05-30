enum SharedPreferencesKey {
  isFirst('isFirst'),
  noticedVersion('noticedVersion'),
  isDarkMode('isDarkMode'),
  isHaptic('isHaptic'),
  language('language'),
  ;

  const SharedPreferencesKey(this.value);
  final String value;
}
