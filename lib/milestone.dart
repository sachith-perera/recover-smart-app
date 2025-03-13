import 'package:RecoverSmart/cheklist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'components/sidebar.dart';
import 'api/get_milestones.dart';
import 'api/auth_service.dart';

class Milestone extends StatefulWidget {
  @override
  State<Milestone> createState() => _MiletoneState();
}

class _MiletoneState extends State<Milestone> {
  double _progressValue = 0.0;
  int _totalMilestones = 0;

  String baseUrl = AuthService.baseUrl;
  String? _access_token = AuthService.accessToken;

  bool _isLoading = false;

  List<MedicalRecord>? _medicalRecords;
  List<ChecklistItem>? _pendingMilestones;
  late int _completedMilestones;

  final Milestones _milestonesService = Milestones();

  @override
  void initState() {
    super.initState();
    _fetchMilestoneData();
  }

  Future<void> _fetchMilestoneData() async {
    if (_access_token == null) {
      print('Access token is null');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch medical records using the Milestones service
      final records = await _milestonesService.getMyRecords(
        _access_token!,
        baseUrl,
      );

      //Get pending and completed milestones
      final pendingMilestones = _milestonesService.getPendingMilestones(
        records,
      );
      final completedMilestones = _milestonesService.getCompletedMilestones(
        records,
      );
      _milestonesService.getOverdueMilestones(records);

      setState(() {
        _medicalRecords = records;
        _pendingMilestones = pendingMilestones;
        _completedMilestones = completedMilestones.length;
        _totalMilestones = _completedMilestones + _pendingMilestones!.length;
        _progressValue = _completedMilestones / _totalMilestones;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching milestone data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: const Text("Healing Milestones"),
        surfaceTintColor: Theme.of(context).primaryColor,
      ),
      drawer: Sidebar(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(10.0),
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _fetchMilestoneData();
                  },
                  child: ListView(
                    children: [
                      ..._medicalRecords!.map(
                        (record) => _buildMedicalRecordCard(record),
                      ),
                    ],
                  ),
                ),
              ),
    ));
  }

  Widget _buildMedicalRecordCard(MedicalRecord record) {
    List<Checklist> checklist = record.checklists;

    int completed = _milestonesService.getCompletedCount(checklist);
    int pending = _milestonesService.getPendingCount(checklist);
    _totalMilestones = completed + pending;

    _progressValue = completed / _totalMilestones;

    int cheklitsId = _milestonesService.getCheklistId(checklist);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheklistPage(checklistId: cheklitsId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    record.diagnosis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                "$completed/$_totalMilestones Milestones Completed",
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                color: Theme.of(context).shadowColor,
                value: _progressValue,
                minHeight: 20.0,
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              Text('Progress: ${(_progressValue * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ),
      ),
    );
  }
}


//..._medicalRecords!.map(
                        // (record) => _buildMedicalRecordCard(record),