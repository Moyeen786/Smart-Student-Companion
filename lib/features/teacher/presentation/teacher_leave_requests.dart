
import 'package:flutter/material.dart';

class TeacherLeaveRequests extends StatefulWidget {
  const TeacherLeaveRequests({super.key});

  @override
  State<TeacherLeaveRequests> createState() =>
      _TeacherLeaveRequestsState();
}

class _TeacherLeaveRequestsState
    extends State<TeacherLeaveRequests> {
  String selectedFilter = 'Pending';
  String searchQuery = '';

  final TextEditingController searchController =
      TextEditingController();

  final List<Map<String, dynamic>> requests = [
    {
      'id': 'LR001',
      'name': 'Student One',
      'roll': 'CSE001',
      'type': 'Sick Leave',
      'reason': 'Not feeling well and need rest.',
      'start': DateTime.now().add(
        const Duration(days: 1),
      ),
      'end': DateTime.now().add(
        const Duration(days: 2),
      ),
      'status': 'Pending',
      'submitted': DateTime.now(),
    },
    {
      'id': 'LR002',
      'name': 'Student Two',
      'roll': 'CSE002',
      'type': 'Personal Leave',
      'reason': 'Family function at home.',
      'start': DateTime.now().add(
        const Duration(days: 3),
      ),
      'end': DateTime.now().add(
        const Duration(days: 3),
      ),
      'status': 'Pending',
      'submitted': DateTime.now(),
    },
    {
      'id': 'LR003',
      'name': 'Student Three',
      'roll': 'CSE003',
      'type': 'Medical Leave',
      'reason': 'Medical appointment.',
      'start': DateTime.now().subtract(
        const Duration(days: 2),
      ),
      'end': DateTime.now().subtract(
        const Duration(days: 1),
      ),
      'status': 'Approved',
      'submitted': DateTime.now().subtract(
        const Duration(days: 3),
      ),
    },
    {
      'id': 'LR004',
      'name': 'Student Four',
      'roll': 'CSE004',
      'type': 'Personal Leave',
      'reason': 'Personal work.',
      'start': DateTime.now().add(
        const Duration(days: 5),
      ),
      'end': DateTime.now().add(
        const Duration(days: 5),
      ),
      'status': 'Rejected',
      'submitted': DateTime.now(),
    },
  ];

  int get pendingCount => requests
      .where((r) => r['status'] == 'Pending')
      .length;

  int get approvedCount => requests
      .where((r) => r['status'] == 'Approved')
      .length;

  int get rejectedCount => requests
      .where((r) => r['status'] == 'Rejected')
      .length;

  List<Map<String, dynamic>> get filteredRequests {
    final query = searchQuery.trim().toLowerCase();

    return requests.where((request) {
      final matchesFilter = selectedFilter == 'All' ||
          request['status'] == selectedFilter;

      final name =
          request['name'].toString().toLowerCase();
      final roll =
          request['roll'].toString().toLowerCase();

      final matchesSearch =
          name.contains(query) || roll.contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  int leaveDays(Map<String, dynamic> request) {
    final start = request['start'] as DateTime;
    final end = request['end'] as DateTime;

    return end.difference(
          DateTime(start.year, start.month, start.day),
        ).inDays +
        1;
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> updateRequest(
    Map<String, dynamic> request,
    String newStatus,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$newStatus Leave Request?'),
          content: Text(
            'Do you want to $newStatus the leave request '
            'from ${request['name']}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(newStatus),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      request['status'] = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Leave request ${newStatus.toLowerCase()} successfully.',
        ),
      ),
    );
  }

  void refreshRequests() {
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Leave request list refreshed.'),
      ),
    );
  }

  Widget summaryCard(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget statusBadge(String status) {
    final color = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  void showRequestDetails(
    Map<String, dynamic> request,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final status = request['status'] as String;

        return AlertDialog(
          title: const Text('Leave Request Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                detailRow('Request ID', request['id'].toString()),
                detailRow('Student', request['name'].toString()),
                detailRow('Roll Number', request['roll'].toString()),
                detailRow('Leave Type', request['type'].toString()),
                detailRow('Reason', request['reason'].toString()),
                detailRow(
                  'From',
                  formatDate(request['start'] as DateTime),
                ),
                detailRow(
                  'To',
                  formatDate(request['end'] as DateTime),
                ),
                detailRow(
                  'Total Days',
                  '${leaveDays(request)}',
                ),
                detailRow('Status', status),
                detailRow(
                  'Submitted',
                  formatDate(request['submitted'] as DateTime),
                ),
              ],
            ),
          ),
          actions: [
            if (status == 'Pending') ...[
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  updateRequest(request, 'Rejected');
                },
                child: const Text('Reject'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  updateRequest(request, 'Approved');
                },
                child: const Text('Approve'),
              ),
            ] else
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Close'),
              ),
          ],
        );
      },
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRequestCard(
    Map<String, dynamic> request,
  ) {
    final status = request['status'] as String;
    final isPending = status == 'Pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showRequestDetails(request),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      request['name']
                          .toString()
                          .substring(0, 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          request['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${request['roll']} • ${request['type']}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  statusBadge(status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${formatDate(request['start'] as DateTime)}'
                      ' – ${formatDate(request['end'] as DateTime)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    '${leaveDays(request)} day(s)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Reason',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                request['reason'] as String,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              if (isPending)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => updateRequest(
                          request,
                          'Rejected',
                        ),
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => updateRequest(
                          request,
                          'Approved',
                        ),
                        icon: const Icon(
                          Icons.check_rounded,
                        ),
                        label: const Text('Approve'),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => showRequestDetails(request),
                    child: const Text('View Details'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleRequests = filteredRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: refreshRequests,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Manage Leave Requests',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Review student leave applications and update their status.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // Summary
            Row(
              children: [
                Expanded(
                  child: summaryCard(
                    'Pending',
                    pendingCount,
                    Colors.orange,
                    Icons.pending_actions,
                  ),
                ),
                Expanded(
                  child: summaryCard(
                    'Approved',
                    approvedCount,
                    Colors.green,
                    Icons.check_circle_outline,
                  ),
                ),
                Expanded(
                  child: summaryCard(
                    'Rejected',
                    rejectedCount,
                    Colors.red,
                    Icons.cancel_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Search
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search student or roll number',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final filter in [
                    'Pending',
                    'Approved',
                    'Rejected',
                    'All',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 8,
                      ),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: selectedFilter == filter,
                        onSelected: (_) {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Requests (${visibleRequests.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (visibleRequests.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 48,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.inbox_outlined,
                      size: 64,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No leave requests found',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Try another filter or search term.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...visibleRequests.map(buildRequestCard),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
