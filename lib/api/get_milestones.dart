import 'dart:convert';
import 'package:http/http.dart' as http;

/// Main class to fetch and manage medical records with their milestones
class Milestones {
  /// Constructor with optional base URL parameter
  /// Fetch checklistItembyId
  Future<List<ChecklistItem>> getChecklistItembyId(
    String accessToken,
    String url,
    int id,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$url/api/checklists/item/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          // Add any required authentication headers here
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => ChecklistItem.fromJson(data)).toList();
      } else {
        throw Exception(
          'Failed to load medical records: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching medical records: $e');
    }
  }

  /// Update Checklist Status
  void updateChecklistItem(String accessToken, String url, int id) async {
    try {
      final response = await http.put(
        Uri.parse('$url/api/checklists/item/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          // Add any required authentication headers here
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"task_status": 1}),
      );

      if (response.statusCode == 200) {
        null;
      } else {
        throw Exception(
          'Failed to load medical records: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching medical records: $e');
    }
  }

  /// Fetch medical records from the API
  Future<List<MedicalRecord>> getMyRecords(
    String accessToken,
    String url,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$url/api/medical_record/my_records'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          // Add any required authentication headers here
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => MedicalRecord.fromJson(data)).toList();
      } else {
        throw Exception(
          'Failed to load medical records: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching medical records: $e');
    }
  }

  /// Get all checklist items (milestones) from all records
  List<ChecklistItem> getAllMilestones(List<MedicalRecord> records) {
    List<ChecklistItem> allMilestones = [];

    for (var record in records) {
      for (var checklist in record.checklists) {
        allMilestones.addAll(checklist.checklistItems);
      }
    }

    return allMilestones;
  }

  List<ChecklistItem> getMilestones(List<Checklist> checklist) {
    List<ChecklistItem> checklistDetails = [];
    for (var checklist in checklist) {
      checklistDetails.addAll(checklist.checklistItems);
    }
    return checklistDetails;
  }

  // /// Get pending milestones (tasks with status 0)
  // List<ChecklistItem> getPendingMilestones(List<MedicalRecord> records) {
  //   return getAllMilestones(
  //     records,
  //   ).where((item) => item.taskStatus == 0).toList();
  // }

  // /// Get completed milestones (tasks with status 1)
  // List<ChecklistItem> getCompletedMilestones(List<MedicalRecord> records) {
  //   return getAllMilestones(
  //     records,
  //   ).where((item) => item.taskStatus == 1).toList();
  // }

  List<ChecklistItem> getPendingMilestones(
    List<MedicalRecord> records, {
    int? recordId,
    int? checklistId,
  }) {
    List<ChecklistItem> milestones = [];

    for (var record in records) {
      // Filter by record ID if provided
      if (recordId != null && record.id != recordId) continue;

      for (var checklist in record.checklists) {
        // Filter by checklist ID if provided
        if (checklistId != null && checklist.id != checklistId) continue;

        // Add pending items from this checklist
        milestones.addAll(
          checklist.checklistItems.where((item) => item.taskStatus == 0),
        );
      }
    }

    return milestones;
  }

  /// Get completed milestones (tasks with status 1) for a specific record and checklist
  List<ChecklistItem> getCompletedMilestones(
    List<MedicalRecord> records, {
    int? recordId,
    int? checklistId,
  }) {
    List<ChecklistItem> milestones = [];

    for (var record in records) {
      // Filter by record ID if provided
      if (recordId != null && record.id != recordId) continue;

      for (var checklist in record.checklists) {
        // Filter by checklist ID if provided
        if (checklistId != null && checklist.id != checklistId) continue;

        // Add completed items from this checklist
        milestones.addAll(
          checklist.checklistItems.where((item) => item.taskStatus == 1),
        );
      }
    }

    return milestones;
  }

  int getCompletedCount(List<Checklist> cheklist) {
    int count = 0;

    for (var checklist in cheklist) {
      for (var cheklistItem in checklist.checklistItems) {
        if (cheklistItem.taskStatus == 1) {
          count++;
        }
      }
    }

    return count;
  }

  int getPendingCount(List<Checklist> cheklist) {
    int count = 0;

    for (var checklist in cheklist) {
      for (var cheklistItem in checklist.checklistItems) {
        if (cheklistItem.taskStatus == 0) {
          count++;
        }
      }
    }

    return count;
  }

  int getCheklistId(List<Checklist> checklist) {
    int checklistId = 0;
    for (var checklist in checklist) {
      checklistId = checklist.id;
    }

    return checklistId;
  }

  /// Get milestones grouped by medical record
  Map<MedicalRecord, List<ChecklistItem>> getMilestonesByRecord(
    List<MedicalRecord> records,
  ) {
    final Map<MedicalRecord, List<ChecklistItem>> result = {};

    for (var record in records) {
      final List<ChecklistItem> recordMilestones = [];
      for (var checklist in record.checklists) {
        recordMilestones.addAll(checklist.checklistItems);
      }
      result[record] = recordMilestones;
    }

    return result;
  }

  /// Get overdue milestones
  List<ChecklistItem> getOverdueMilestones(List<MedicalRecord> records) {
    final currentDate = DateTime.now();
    return getPendingMilestones(
      records,
    ).where((item) => item.isOverdue(currentDate)).toList();
  }
}

/// Model class for a medical record
class MedicalRecord {
  final int id;
  final int patient;
  final int doctor;
  final int createdBy;
  final String createDate;
  final String symptoms;
  final String diagnosis;
  final String treatment;
  final String allergies;
  final int status;
  final List<Checklist> checklists;

  MedicalRecord({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.createdBy,
    required this.createDate,
    required this.symptoms,
    required this.diagnosis,
    required this.treatment,
    required this.allergies,
    required this.status,
    required this.checklists,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      patient: json['patient'],
      doctor: json['doctor'],
      createdBy: json['created_by'],
      createDate: json['create_date'],
      symptoms: json['symptoms'],
      diagnosis: json['diagnosis'],
      treatment: json['treatment'],
      allergies: json['allergies'],
      status: json['status'],
      checklists:
          (json['checklists'] as List)
              .map((checklist) => Checklist.fromJson(checklist))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': patient,
      'doctor': doctor,
      'created_by': createdBy,
      'create_date': createDate,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'allergies': allergies,
      'status': status,
      'checklists': checklists.map((checklist) => checklist.toJson()).toList(),
    };
  }
}

/// Model class for a checklist
class Checklist {
  final int id;
  final String createdDate;
  final int status;
  final int createdBy;
  final int record;
  final List<ChecklistItem> checklistItems;

  Checklist({
    required this.id,
    required this.createdDate,
    required this.status,
    required this.createdBy,
    required this.record,
    required this.checklistItems,
  });

  factory Checklist.fromJson(Map<String, dynamic> json) {
    return Checklist(
      id: json['id'],
      createdDate: json['created_date'],
      status: json['status'],
      createdBy: json['created_by'],
      record: json['record'],
      checklistItems:
          (json['checklistItems'] as List)
              .map((item) => ChecklistItem.fromJson(item))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_date': createdDate,
      'status': status,
      'created_by': createdBy,
      'record': record,
      'checklistItems': checklistItems.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model class for a checklist item (milestone)
class ChecklistItem {
  final int id;
  final int checklist;
  final int type;
  final String title;
  final String description;
  final String dueDate;
  int taskStatus;
  final String? completeDate;

  ChecklistItem({
    required this.id,
    required this.checklist,
    required this.type,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.taskStatus,
    this.completeDate,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'],
      checklist: json['checklist'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      dueDate: json['due_date'],
      taskStatus: json['task_status'],
      completeDate: json['complete_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checklist': checklist,
      'type': type,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'task_status': taskStatus,
      'complete_date': completeDate,
    };
  }

  /// Check if the milestone is completed
  bool get isCompleted => taskStatus == 1;

  /// Check if the milestone is overdue
  bool isOverdue(DateTime currentDate) {
    final due = DateTime.parse(dueDate);
    return !isCompleted && currentDate.isAfter(due);
  }

  void status(bool value) {
    taskStatus = value ? 1 : 0;
  }
}
