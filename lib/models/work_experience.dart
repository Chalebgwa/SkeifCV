class WorkExperience {
  String jobTitle;
  String company;
  String dates;
  String description;

  WorkExperience({
    this.jobTitle = '',
    this.company = '',
    this.dates = '',
    this.description = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'jobTitle': jobTitle,
      'company': company,
      'dates': dates,
      'description': description,
    };
  }

  factory WorkExperience.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WorkExperience();
    }
    return WorkExperience(
      jobTitle: json['jobTitle'] ?? '',
      company: json['company'] ?? '',
      dates: json['dates'] ?? '',
      description: json['description'] ?? '',
    );
  }

  WorkExperience copyWith({
    String? jobTitle,
    String? company,
    String? dates,
    String? description,
  }) {
    return WorkExperience(
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      dates: dates ?? this.dates,
      description: description ?? this.description,
    );
  }
}
