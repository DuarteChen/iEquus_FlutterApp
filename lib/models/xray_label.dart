class XRayLabel {
  final String name;
  final int x;
  final int y;
  final String description;

  XRayLabel({
    required this.name,
    required this.x,
    required this.y,
    required this.description,
  });

  factory XRayLabel.fromJson(String name, Map<String, dynamic> json) {
    return XRayLabel(
      name: name,
      x: json['x'] as int? ?? 0,
      y: json['y'] as int? ?? 0,
      description:
          json['description'] as String? ?? 'No description available.',
    );
  }
}
