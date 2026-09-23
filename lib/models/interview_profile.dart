class InterviewProfile {
  final String name;
  final int age;
  final String occupation;
  final String lifeStage;
  final String greatestAchievement;
  final String importantMistake;
  final String dissatisfaction;
  final String desiredChange;

  const InterviewProfile({
    required this.name,
    required this.age,
    required this.occupation,
    required this.lifeStage,
    required this.greatestAchievement,
    required this.importantMistake,
    required this.dissatisfaction,
    required this.desiredChange,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'occupation': occupation,
      'lifeStage': lifeStage,
      'greatestAchievement': greatestAchievement,
      'importantMistake': importantMistake,
      'dissatisfaction': dissatisfaction,
      'desiredChange': desiredChange,
    };
  }

  factory InterviewProfile.fromJson(Map<String, dynamic> json) {
    return InterviewProfile(
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      occupation: json['occupation'] as String? ?? '',
      lifeStage: json['lifeStage'] as String? ?? '',
      greatestAchievement: json['greatestAchievement'] as String? ?? '',
      importantMistake: json['importantMistake'] as String? ?? '',
      dissatisfaction: json['dissatisfaction'] as String? ?? '',
      desiredChange: json['desiredChange'] as String? ?? '',
    );
  }
}
