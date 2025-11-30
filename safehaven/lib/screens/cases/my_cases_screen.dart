import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';

class MyCasesScreen extends StatefulWidget {
  const MyCasesScreen({super.key});

  @override
  State<MyCasesScreen> createState() => _MyCasesScreenState();
}

class _MyCasesScreenState extends State<MyCasesScreen> {
  List<Map<String, dynamic>> _cases = [];
  bool _loading = true;
  String? _error;
  String? _userAddress;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // For demo, we'll use a default address. In production, this would come from user's wallet
      // For now, we'll use the backend signer address as a placeholder
      // In a real app, you'd get this from Firebase Auth or wallet connection
      const demoAddress = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'; // Hardhat account #0
      
      final res = await ApiService.getUserCases(demoAddress);
      if (mounted) {
        setState(() {
          _cases = List<Map<String, dynamic>>.from(res['cases'] ?? []);
          _userAddress = demoAddress;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Acknowledged';
      case 2:
        return 'Escalated';
      case 3:
        return 'Resolved';
      case 4:
        return 'False Alarm';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.red;
      case 3:
        return Colors.green;
      case 4:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _markFalseAlarm(String caseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as False Alarm?'),
        content: const Text('Are you sure you want to mark this case as a false alarm? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApiService.markFalseAlarm(int.parse(caseId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Case marked as false alarm')),
        );
        _loadCases(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientHeader = Container(
      width: double.infinity,
      height: 170,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF3F51B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Cases',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('View and manage your SOS cases',
              style: GoogleFonts.poppins(color: Colors.white70)),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          gradientHeader,
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadCases,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _cases.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text('No cases yet',
                                    style: GoogleFonts.poppins(
                                        fontSize: 18, color: Colors.grey)),
                                const SizedBox(height: 8),
                                Text('Send an SOS to create your first case',
                                    style: GoogleFonts.poppins(color: Colors.grey)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadCases,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemCount: _cases.length,
                              itemBuilder: (context, index) {
                                final caseData = _cases[index];
                                final status = int.parse(caseData['status'] ?? '0');
                                final statusText = _getStatusText(status);
                                final statusColor = _getStatusColor(status);
                                final timestamp = int.parse(caseData['timestamp'] ?? '0');
                                final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Case #${caseData['id']}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: statusColor),
                                              ),
                                              child: Text(
                                                statusText,
                                                style: GoogleFonts.poppins(
                                                  color: statusColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                size: 16, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${caseData['latitude']}, ${caseData['longitude']}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time,
                                                size: 16, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (status != 4 && status != 3) ...[
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton.icon(
                                              onPressed: () => _markFalseAlarm(caseData['id']),
                                              icon: const Icon(Icons.cancel_outlined, size: 18),
                                              label: const Text('Mark as False Alarm'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: const BorderSide(color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentRoute: '/my_cases', role: 'user'),
    );
  }
}

