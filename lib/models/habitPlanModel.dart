import 'dart:convert';
import 'package:githo/extracted_functions/typeExtentions.dart';

class HabitPlan {
  int? id;
  bool isActive;
  String goal;
  int requiredReps;
  List<String> challenges;
  List<String> comments;
  int trainingTimeIndex;
  int requiredTrainings;
  int requiredTrainingPeriods;
  DateTime lastChanged;

  HabitPlan({
    required this.isActive,
    required this.goal,
    required this.requiredReps,
    required this.challenges,
    required this.comments,
    required this.trainingTimeIndex,
    required this.requiredTrainings,
    required this.requiredTrainingPeriods,
    required this.lastChanged,
  });

  HabitPlan.withId({
    required this.id,
    required this.isActive,
    required this.goal,
    required this.requiredReps,
    required this.challenges,
    required this.comments,
    required this.trainingTimeIndex,
    required this.requiredTrainings,
    required this.requiredTrainingPeriods,
    required this.lastChanged,
  });

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map["id"] = id;
    }

    map["isActive"] = isActive.boolToInt();
    map["goal"] = goal;
    map["requiredReps"] = requiredReps;
    map["challenges"] = jsonEncode(challenges);
    map["comments"] = jsonEncode(comments);
    map["trainingTimeIndex"] = trainingTimeIndex;
    map["requiredTrainings"] = requiredTrainings;
    map["requiredTrainingPeriods"] = requiredTrainingPeriods;
    map["lastChanged"] = lastChanged.toString();

    return map;
  }

  factory HabitPlan.fromMap(Map<String, dynamic> map) {
    List<String> jsonToList(json) {
      var dynamicList = jsonDecode(json);
      List<String> list = [];

      dynamicList.forEach((element) {
        list.add(element);
      });
      return list;
    }

    return HabitPlan.withId(
      id: map["id"],
      isActive: (map["isActive"] as int).intToBool(),
      goal: map["goal"],
      requiredReps: map["requiredReps"],
      challenges: jsonToList(map["challenges"]),
      comments: jsonToList(map["comments"]),
      trainingTimeIndex: map["trainingTimeIndex"],
      requiredTrainings: map["requiredTrainings"],
      requiredTrainingPeriods: map["requiredTrainingPeriods"],
      lastChanged: DateTime.parse(map["lastChanged"]),
    );
  }
}