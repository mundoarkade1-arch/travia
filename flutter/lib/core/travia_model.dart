class TraviaState {
  TraviaState(
      {this.version = 4,
      this.courses = const [],
      this.tasks = const [],
      this.settings = const {},
      this.notes = const {},
      this.events = const [],
      this.materials = const [],
      this.scenarios = const [],
      this.tutor = const {}});

  final int version;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> tasks;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> notes;
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> materials;
  final List<Map<String, dynamic>> scenarios;
  final Map<String, dynamic> tutor;

  factory TraviaState.fromJson(Map<String, dynamic> json) => TraviaState(
        version: 4,
        courses: List<Map<String, dynamic>>.from(
            (json['courses'] as List? ?? [])
                .map((item) => Map<String, dynamic>.from(item as Map))),
        tasks: List<Map<String, dynamic>>.from((json['tasks'] as List? ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))),
        settings: {
          'semester': 5,
          'limit': 9,
          ...Map<String, dynamic>.from(json['settings'] as Map? ?? {})
        },
        notes: Map<String, dynamic>.from(json['notes'] as Map? ?? {}),
        events: List<Map<String, dynamic>>.from((json['events'] as List? ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))),
        materials: List<Map<String, dynamic>>.from(
            (json['materials'] as List? ?? [])
                .map((item) => Map<String, dynamic>.from(item as Map))),
        scenarios: List<Map<String, dynamic>>.from(
            (json['scenarios'] as List? ?? [])
                .map((item) => Map<String, dynamic>.from(item as Map))),
        tutor: {
          'provider': 'OpenAI-compatible',
          'endpoint': '',
          'model': '',
          'messages': <dynamic>[],
          'conversations': <String, dynamic>{},
          'activeCourse': 1,
          ...Map<String, dynamic>.from(json['tutor'] as Map? ?? {})
        },
      );

  Map<String, dynamic> toJson() => {
        'version': version,
        'courses': courses,
        'tasks': tasks,
        'settings': settings,
        'notes': notes,
        'events': events,
        'materials': materials,
        'scenarios': scenarios,
        'tutor': tutor
      };
}
