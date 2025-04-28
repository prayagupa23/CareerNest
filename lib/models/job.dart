// Job model for use in both employer and applicant dashboards
class Job {
  final String id;
  final String company;
  final String title;
  final List<String> tags;
  final String salary;
  final String description;
  final String requirements;
  final String status;
  final List<dynamic> applicants;

  Job({
    required this.id,
    required this.company,
    required this.title,
    required this.tags,
    required this.salary,
    required this.description,
    required this.requirements,
    required this.status,
    required this.applicants,
  });

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'] ?? '',
      company: map['company'] ?? '',
      title: map['title'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      salary: map['salary'] ?? '',
      description: map['description'] ?? '',
      requirements: map['requirements'] ?? '',
      status: map['status'] ?? '',
      applicants: map['applicants'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company': company,
      'title': title,
      'tags': tags,
      'salary': salary,
      'description': description,
      'requirements': requirements,
      'status': status,
      'applicants': applicants,
    };
  }
} 