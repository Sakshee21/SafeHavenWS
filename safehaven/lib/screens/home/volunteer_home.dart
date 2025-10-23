import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/cases_service.dart';
import '../../models/case_model.dart';

class VolunteerHome extends StatefulWidget {
  const VolunteerHome({super.key});

  @override
  State<VolunteerHome> createState() => _VolunteerHomeState();
}

class _VolunteerHomeState extends State<VolunteerHome> {
  final CasesService _service = CasesService();

  @override
  void initState() {
    super.initState();
    _service.fetchFromServer();
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

  @override
  Widget build(BuildContext context) {
    final header = Container(
      width: double.infinity,
      height: 130,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF3F51B5)]),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SafeHaven', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Volunteer Dashboard', style: GoogleFonts.poppins(color: Colors.white70)),
      ]),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(children: [
        header,
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Volunteer Actions', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Submit a generic report (for demo)
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted.')));
                    },
                    icon: const Icon(Icons.note_add),
                    label: const Text('Submit Report'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7A28FF)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Follow-up logged.')));
                    },
                    icon: const Icon(Icons.update),
                    label: const Text('Follow Up'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              Text('⚠️ Active Help Requests', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),

              StreamBuilder<List<CaseModel>>(
                stream: _service.stream,
                builder: (context, snap) {
                  if (snap.hasError) return Text('Error: ${snap.error}');
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final active = snap.data!.where((c) => c.status == 'active').toList();
                  if (active.isEmpty) return const Text('No active help requests.');
                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: active.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final c = active[i];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Row(children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(c.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(c.location, style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 6),
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: _statusColor(c.status).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Text(c.status, style: TextStyle(color: _statusColor(c.status))),
                                  ),
                                ]),
                              ]),
                            ),
                            const SizedBox(width: 8),
                            Column(children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await _service.acceptCase(c.id);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You accepted the request.')));
                                },
                                child: const Text('Accept'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // Optionally navigate to case detail
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening details...')));
                                },
                                child: const Text('Details'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black),
                              ),
                            ]),
                          ]),
                        ),
                      );
                    },
                  );
                },
              ),
            ]),
          ),
        ),
      ]),
      bottomNavigationBar: const BottomNav(currentRoute: '/volunteer_home', role: 'volunteer'),
    );
  }
}
