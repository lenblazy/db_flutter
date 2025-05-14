class SampleEntityRef {
  SampleEntityRef({required this.id, required this.itemOne});

  String id;
  String itemOne;

  Map<String, dynamic> toJson() {
    return {'task_id': id, 'task_status': itemOne};
  }

  Map<String, dynamic> toMap(String sampleId) {
    return {'id': id, 'sample_id': sampleId, 'item_two': itemOne};
  }
}
