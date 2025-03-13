import 'package:flutter/material.dart';
import 'components/sidebar.dart';
import 'api/get_milestones.dart';

class CheklistPage extends StatefulWidget {
  final int checklistId;
  final List<Checklist> checkList;

  const CheklistPage({
    super.key,
    required this.checklistId,
    required this.checkList,
  });

  @override
  State<CheklistPage> createState() => _CheklistState();
}

class _CheklistState extends State<CheklistPage> {
  bool _isLoading = true; // Start with loading state
  final Milestones _milestonesService = Milestones();
  List<ChecklistItem>? _checkListItems;

  @override
  void initState() {
    super.initState();
    // Fetch checklist items when the widget initializes
    _fetchChecklistItems();
  }

  // Method to fetch checklist items
  Future<void> _fetchChecklistItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch checklist items using the service
      final items = await _milestonesService.getMilestones(widget.checkList);

      setState(() {
        _checkListItems = items;
        _isLoading = false;
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
    bool isChecked =
        checklist
            .isCompleted; // You might want to get this from the checklist item
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              checklist.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Complete",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Checkbox(
                  value: isChecked,
                  onChanged:
                      isChecked
                          ? null // Disables the checkbox after checking
                          : (bool? value) {
                            setState(() {
                              isChecked = value!;
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
