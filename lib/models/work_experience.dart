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

  // toJson method to convert WorkExperience to a Map
  Map<String, dynamic> toJson() {
    return {
      'jobTitle': jobTitle,
      'company': company,
      'dates': dates,
      'description': description,

    };

    
}
