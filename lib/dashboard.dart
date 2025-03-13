import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'api/auth_service.dart';
import 'components/sidebar.dart';
import 'api/user_details.dart';
import 'api/get_milestones.dart'; // Make sure the import path is correct

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  double _progressValue = 0.0;
  int _totalMilestones = 0;

  bool _isLoading = false;
  String _greeting = '';
  IconData _greetingIcon = Icons.access_time;
  String _formattedDate = '';
  late Timer _timer;

  double temperature = 36.5;
  double hemoglobin = 13.5;
  String heartCondition = "Normal";
  int bloodPressureSystolic = 120;
  int bloodPressureDiastolic = 80;

  String baseUrl = AuthService.baseUrl;
  String? _access_token = AuthService.accessToken;

  User? user;
  List<ChecklistItem>? _pendingMilestones;
  List<ChecklistItem>? _overdueMilestones;
  int _completedMilestones = 0;

  final Milestones _milestonesService = Milestones();

  String username = 'Loading...';

  @override
  void initState() {
    super.initState();

    // Set initial greeting and date
    _updateTimeAndDate();

    // Fetch user data when widget initializes
    _fetchUserData();

    // Fetch milestone data
    _fetchMilestoneData();

    // Optional: Set up a timer to update the greeting and date every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _updateTimeAndDate();
      });
    });
  }

  // Method to fetch user data
  Future<void> _fetchUserData() async {
    if (_access_token == null) {
      print('Access token is null');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedUser = await fetchUser(_access_token!, baseUrl);
      setState(() {
        user = fetchedUser;
        username = '${user!.firstName} ${user!.lastName}';
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        username = 'Error loading user';
        _isLoading = false;
      });
    }
  }

  // Method to fetch milestone data
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
      final overdueMilestones = _milestonesService.getOverdueMilestones(
        records,
      );

      setState(() {
        _pendingMilestones = pendingMilestones;
        _completedMilestones = completedMilestones.length;
        _overdueMilestones = overdueMilestones;
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
  void dispose() {
    // Cancel the timer when the widget is disposed to prevent memory leaks
    _timer.cancel();
    super.dispose();
  }

  String _progressStatus(double progressvalue) {
    String Message = '';

    if (progressvalue <= 0.25) {
      Message = 'Better Get Started';
    } else if (progressvalue > 0.25 && progressvalue <= 0.50) {
      Message = 'Getting There';
    } else if (progressvalue > 0.5 && progressvalue <= 0.75) {
      Message = 'Almost There';
    } else if (progressvalue > 0.75 && progressvalue <= 100) {
      Message = 'Almost Done';
    } else {
      Message = 'Well Done';
    }

    return Message;
  }

  void _updateTimeAndDate() {
    final now = DateTime.now();
    final hour = now.hour;

    // Determine greeting based on time of day
    if (hour >= 5 && hour < 12) {
      _greeting = 'Good Morning';
      _greetingIcon = Icons.wb_sunny;
    } else if (hour >= 12 && hour < 17) {
      _greeting = 'Good Afternoon';
      _greetingIcon = Icons.wb_cloudy;
    } else {
      _greeting = 'Good Evening';
      _greetingIcon = Icons.nights_stay;
    }

    // Format the current date
    _formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
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
                      Row(
                        children: [
                          Icon(
                            _greetingIcon,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _greeting,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formattedDate,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Card(
                        elevation: 4.0,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/milestone');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Healing Milestones",
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "$_completedMilestones/$_totalMilestones Milestones Completed",
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      if (_overdueMilestones != null &&
                                          _overdueMilestones!.isNotEmpty)
                                        Text(
                                          "${_overdueMilestones!.length} Overdue",
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.red,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,

                                  children: [
                                    Text(
                                      _progressStatus(_progressValue),
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    Text(
                                      ' ${(_progressValue * 100).toStringAsFixed(0)}%',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  color: Theme.of(context).shadowColor,
                                  value: _progressValue,
                                  minHeight: 20.0,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: progressCard(
                                  "Temperature",
                                  "$temperature°C",
                                  Icons.thermostat,
                                  Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: progressCard(
                                  "Hemoglobin",
                                  "$hemoglobin g/dL",
                                  Icons.bloodtype,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: progressCard(
                                  "Heart Condition",
                                  heartCondition,
                                  Icons.favorite,
                                  Colors.pink,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: progressCard(
                                  "Blood Pressure",
                                  "$bloodPressureSystolic/$bloodPressureDiastolic mmHg",
                                  Icons.monitor_heart,
                                  Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget progressCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
  ) {
    return SizedBox(
      height: 110, // Fixed height for all cards
      child: Card(
        color: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ensures consistent layout
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
