/// A place to look up sun hours for. County seats are close enough: solar
/// resource changes little over tens of kilometres.
class SiteLocation {
  const SiteLocation(this.name, this.lat, this.lng);

  final String name;
  final double lat;
  final double lng;
}

/// Kenya's 47 counties, by their county seat. Sorted A–Z for the picker.
const kenyaCounties = [
  SiteLocation('Baringo (Kabarnet)', 0.49, 35.74),
  SiteLocation('Bomet', -0.78, 35.34),
  SiteLocation('Bungoma', 0.56, 34.56),
  SiteLocation('Busia', 0.46, 34.11),
  SiteLocation('Elgeyo-Marakwet (Iten)', 0.67, 35.51),
  SiteLocation('Embu', -0.54, 37.46),
  SiteLocation('Garissa', -0.45, 39.65),
  SiteLocation('Homa Bay', -0.53, 34.46),
  SiteLocation('Isiolo', 0.35, 37.58),
  SiteLocation('Kajiado', -1.85, 36.78),
  SiteLocation('Kakamega', 0.28, 34.75),
  SiteLocation('Kericho', -0.37, 35.28),
  SiteLocation('Kiambu', -1.17, 36.83),
  SiteLocation('Kilifi', -3.63, 39.85),
  SiteLocation('Kirinyaga (Kerugoya)', -0.50, 37.28),
  SiteLocation('Kisii', -0.68, 34.77),
  SiteLocation('Kisumu', -0.09, 34.77),
  SiteLocation('Kitui', -1.37, 38.01),
  SiteLocation('Kwale', -4.17, 39.45),
  SiteLocation('Laikipia (Nanyuki)', 0.01, 37.07),
  SiteLocation('Lamu', -2.27, 40.90),
  SiteLocation('Machakos', -1.52, 37.26),
  SiteLocation('Makueni (Wote)', -1.78, 37.63),
  SiteLocation('Mandera', 3.94, 41.86),
  SiteLocation('Marsabit', 2.33, 37.99),
  SiteLocation('Meru', 0.05, 37.65),
  SiteLocation('Migori', -1.06, 34.47),
  SiteLocation('Mombasa', -4.04, 39.67),
  SiteLocation("Murang'a", -0.72, 37.15),
  SiteLocation('Nairobi', -1.29, 36.82),
  SiteLocation('Nakuru', -0.30, 36.07),
  SiteLocation('Nandi (Kapsabet)', 0.20, 35.10),
  SiteLocation('Narok', -1.08, 35.87),
  SiteLocation('Nyamira', -0.57, 34.94),
  SiteLocation('Nyandarua (Ol Kalou)', -0.27, 36.38),
  SiteLocation('Nyeri', -0.42, 36.95),
  SiteLocation('Samburu (Maralal)', 1.10, 36.70),
  SiteLocation('Siaya', 0.06, 34.29),
  SiteLocation('Taita-Taveta (Wundanyi)', -3.40, 38.36),
  SiteLocation('Tana River (Hola)', -1.50, 40.03),
  SiteLocation('Tharaka-Nithi (Chuka)', -0.33, 37.65),
  SiteLocation('Trans Nzoia (Kitale)', 1.02, 35.00),
  SiteLocation('Turkana (Lodwar)', 3.12, 35.60),
  SiteLocation('Uasin Gishu (Eldoret)', 0.51, 35.27),
  SiteLocation('Vihiga (Mbale)', 0.08, 34.72),
  SiteLocation('Wajir', 1.75, 40.06),
  SiteLocation('West Pokot (Kapenguria)', 1.24, 35.11),
];
