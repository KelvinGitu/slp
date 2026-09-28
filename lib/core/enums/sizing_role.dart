/// Which catalogue item the sizing calculator fills in. Kept as a role on the
/// item rather than matched by name, so renaming "Panels" in the catalogue
/// doesn't break sizing.
enum SizingRole {
  none,

  /// Item rating is the panel's watts; the calculator sets the panel count.
  panel,

  /// Option ratings are watts; the calculator picks the smallest that fits.
  inverter,

  /// Option ratings are amp-hours at the item's nominal voltage; the
  /// calculator picks a capacity and a battery count.
  battery;

  static SizingRole fromName(String? name) =>
      SizingRole.values.firstWhere((r) => r.name == name, orElse: () => SizingRole.none);
}
