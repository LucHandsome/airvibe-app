class FamousCities {
  final String name;
  final String lat;
  final String lon;
  
  const FamousCities({
    required this.name,
    required this.lat,
    required this.lon,
  });
}

List<FamousCities> famousCities = [
  const FamousCities(name: 'Hà Nội', lat: '21.0285', lon: '105.8542'),
  const FamousCities(name: 'Hồ Chí Minh', lat: '10.8231', lon: '106.6297'),
  const FamousCities(name: 'Đà Nẵng', lat: '16.0544', lon: '108.2022'),
  const FamousCities(name: 'Nha Trang', lat: '12.2384', lon: '109.1967'),
  const FamousCities(name: 'Cần Thơ', lat: '10.0343', lon: '105.7842'),
];