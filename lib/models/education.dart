class Education {
  String institution;
  String degree;
  String dates;
  String description;

  Education({
    this.institution = '',
    this.degree = '',
    this.dates = '',
    this.description = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'institution': institution,
      'degree': degree,
      'dates': dates,
      'description': description,
    };
  }

  factory Education.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Education();
    }
    return Education(
      institution: json['institution'] ?? '',
      degree: json['degree'] ?? '',
      dates: json['dates'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Education copyWith({
    String? institution,
    String? degree,
    String? dates,
    String? description,
  }) {
    return Education(
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      dates: dates ?? this.dates,
      description: description ?? this.description,
    );
  }
}
