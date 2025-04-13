class SampleEntity {
  SampleEntity({
    required this.id,
    required this.itemOne,
  });

  String id;
  String itemOne;

  Map<String, dynamic> toJson() {
    return {
      'task_id': id,
      'task_status': itemOne,
    };
  }

  Map<String, dynamic> toMap(String checkInId) {
    return {
      'id': id,
      'item_one': itemOne,
    };
  }
}
