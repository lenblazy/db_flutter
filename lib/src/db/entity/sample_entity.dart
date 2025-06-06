class SampleEntity {
  SampleEntity({required this.id, required this.itemOne});

  String id;
  String itemOne;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{"task_id": id, "task_status": itemOne};
  }

  Map<String, dynamic> toMap(String checkInId) {
    return <String, dynamic>{"id": id, "item_one": itemOne};
  }
}
