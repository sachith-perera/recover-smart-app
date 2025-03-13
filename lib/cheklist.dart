import 'package:RecoverSmart/api/auth_service.dart';
import 'package:flutter/material.dart';
import 'api/get_milestones.dart';

class CheklistPage extends StatefulWidget {
  final int checklistId;
  const CheklistPage({super.key, required this.checklistId});

  @override
  State<CheklistPage> createState() => _CheklistState();
}

class _CheklistState extends State<CheklistPage> {
  bool isChecked = false;
  bool _isLoading = true; // Start with loading state
  final Milestones _milestonesService = Milestones();
  List<ChecklistItem>? _checkListItems;

  String baseUrl = AuthService.baseUrl;
  String? _access_token = AuthService.accessToken;

  @override
  void initState() {
    super.initState();
    // Fetch checklist items when the widget initializes
    _fetchChecklistItems();
  }

  void _sortChecklistItems() {
    if (_checkListItems != null) {
      _checkListItems!.sort((a, b) {
        if (a.isCompleted && !b.isCompleted) {
          return 1;
        } else if (!a.isCompleted && b.isCompleted) {
          return -1;
        }
        return 0;
      });
    }
  }

  // Method to fetch checklist items
  Future<void> _fetchChecklistItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch checklist items using the service
      final items = await _milestonesService.getChecklistItembyId(
        _access_token!,
        baseUrl,
        widget.checklistId,
      );

      // items.sort((a, b) {
      //   if (a.isCompleted && !b.isCompleted) {
      //     return 1; // a is completed, b is not, so b comes first
      //   } else if (!a.isCompleted && b.isCompleted) {
      //     return -1; // a is not completed, b is, so a comes first
      //   }
      //   return 0; // both have same completion status
      // });

      setState(() {
        _checkListItems = items;
        _isLoading = false;

        _sortChecklistItems();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (you might want to show a snackbar or dialog)
      print('Error fetching checklist items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checklist"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Return 'refresh' as result when going back
            Navigator.pushNamed(context, '/milestone');
          },
        ),
        surfaceTintColor: Theme.of(context).primaryColor,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(10.0),
                child: RefreshIndicator(
                  onRefresh:
                      _fetchChecklistItems, // Use the fetch method for refresh
                  child:
                      _checkListItems == null || _checkListItems!.isEmpty
                          ? const Center(
                            child: Text('No checklist items found'),
                          )
                          : ListView.builder(
                            itemCount: _checkListItems!.length,
                            itemBuilder: (context, index) {
                              return _buildChecklistCard(
                                _checkListItems![index],
                              );
                            },
                          ),
                ),
              ),
    );
  }

  Widget _buildChecklistCard(ChecklistItem checklist) {
    // You might want to get this from the checklist item
    // isChecked = checklist.isCompleted;
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color:
          checklist.isCompleted
              ? Theme.of(context).splashColor
              : Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              checklist.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0XffF0F0F0),
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              checklist.description,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0XffF0F0F0),
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              "Complete By : ${checklist.dueDate}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0XffF0F0F0),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  checklist.isCompleted ? "Completed" : "Compelete",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0XffF0F0F0),
                  ),
                ),
                Checkbox(
                  value: checklist.isCompleted,
                  onChanged:
                      checklist.isCompleted
                          ? (null) // Disables the checkbox after checking
                          : (bool? value) {
                            _milestonesService.updateChecklistItem(
                              _access_token!,
                              baseUrl,
                              checklist.id,
                            );
                            setState(() {
                              checklist.status(value!);
                              _sortChecklistItems();
                            });
                          },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
