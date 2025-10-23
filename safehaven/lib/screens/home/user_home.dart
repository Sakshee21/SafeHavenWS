import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/cases_service.dart';
import '../../models/case_model.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SafeHaven', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Victim Dashboard', style: GoogleFonts.poppins(color: Colors.white70)),
      ]),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          gradientHeader,
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Text('Emergency SOS', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Create a new case and add to service
                          final newCase = CaseModel(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: 'Help Request #${DateTime.now().millisecondsSinceEpoch % 1000}',
                              location: 'Your current location',
                              status: 'active');
                          _service.addCase(newCase);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🚨 SOS sent! Authorities alerted.')));
                        },
                        icon: const Icon(Icons.emergency, size: 24),
                        label: const Text('Send SOS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Case History', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                StreamBuilder<List<CaseModel>>(
                  stream: _service.stream,
                  builder: (context, snap) {
                    if (snap.hasError) return Text('Error: ${snap.error}');
                    if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                    final list = snap.data!;
                    if (list.isEmpty) return const Text('No cases yet.');
                    return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final c = list[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(radius: 6, backgroundColor: _statusColor(c.status)),
                            title: Text(c.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            subtitle: Text('${c.location} • ${c.status}'),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentRoute: '/user_home', role: 'user'),
    );
  }
}
