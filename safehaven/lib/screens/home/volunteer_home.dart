import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_nav.dart';

class CaseModel {
  final String id;
  final String title;
  final String location;
  final String status;

  CaseModel({
    required this.id,
    required this.title,
    required this.location,
    required this.status,
  });
}

class VolunteerHome extends StatefulWidget {
  const VolunteerHome({super.key});

  @override
  State<VolunteerHome> createState() => _VolunteerHomeState();
}

class _VolunteerHomeState extends State<VolunteerHome> {
  List<Map<String, dynamic>> _nearbyCases = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNearbyCases();
  }

  Future<void> _loadNearbyCases() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pos = await Geolocator.getCurrentPosition();
      final res = await ApiService.getNearbyCases(pos.latitude, pos.longitude, radiusKm: 10);
      if (mounted) {
        setState(() {
          _nearbyCases = List<Map<String, dynamic>>.from(res['cases'] ?? []);
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

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.redAccent;
      case 'in-progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActiveCaseCard(Map<String, dynamic> c) {
    final status = ['Pending', 'Acknowledged', 'Escalated', 'Resolved'][c['status'] ?? 0];
    final statusStr = status.toLowerCase();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Case #${c['id']}',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${c['lat']}, ${c['lng']}',
                        style: const TextStyle(color: Colors.grey)),
                    if (c['distanceKm'] != null)
                      Text('${c['distanceKm'].toStringAsFixed(1)} km away',
                          style: const TextStyle(color: Colors.blue, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: _statusColor(statusStr).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(color: _statusColor(statusStr)),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
            ElevatedButton(
              onPressed: () => _acceptCase(c['id']),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8)),
              child: const Text('Accept'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptCase(int id) async {
    try {
      await ApiService.volunteerAccept(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Accepted case #$id')),
        );
        _loadNearbyCases();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _submitReport(int id) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Report'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Report details...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed == true && controller.text.isNotEmpty) {
      try {
        await ApiService.volunteerReport(id, controller.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Report submitted for case #$id')),
          );
          _loadNearbyCases();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Widget _buildPastCaseCard(Map<String, dynamic> c) {
    final status = ['Pending', 'Acknowledged', 'Escalated', 'Resolved'][c['status'] ?? 0];
    final statusStr = status.toLowerCase();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Case #${c['id']}',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${c['lat']}, ${c['lng']}',
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: _statusColor(statusStr).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(color: _statusColor(statusStr)),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
            ElevatedButton.icon(
              onPressed: () => _submitReport(c['id']),
              icon: const Icon(Icons.note_add, size: 16),
              label: const Text('Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A28FF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final header = Container(
      width: double.infinity,
      height: 130,
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF3F51B5)]),
      ),
      padding: const EdgeInsets.all(16),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SafeHaven',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Volunteer Dashboard',
            style: GoogleFonts.poppins(color: Colors.white70)),
      ]),
    );

    final activeCases = _nearbyCases.where((c) => c['status'] == 0 || c['status'] == 1).toList();
    final pastCases = _nearbyCases.where((c) => c['status'] == 2 || c['status'] == 3).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(children: [
        header,
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('⚠️ Active Help Requests',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loading ? null : _loadNearbyCases,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Text('Error: $_error', style: const TextStyle(color: Colors.red))
                else if (activeCases.isEmpty)
                  const Text('No active help requests nearby.')
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: activeCases.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _buildActiveCaseCard(activeCases[i]),
                  ),

                const SizedBox(height: 25),
                Text('📁 Past Cases',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                if (pastCases.isEmpty)
                  const Text('No past cases yet.')
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: pastCases.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _buildPastCaseCard(pastCases[i]),
                  ),
              ],
            ),
          ),
        ),
      ]),
      bottomNavigationBar: const BottomNav(currentRoute: '/volunteer_home', role: 'volunteer'),
    );
  }
}
