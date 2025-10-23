import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/cases_service.dart';
import '../../models/case_model.dart';

class CombinedHome extends StatefulWidget {
  const CombinedHome({super.key});

  @override
  State<CombinedHome> createState() => _CombinedHomeState();
}

class _CombinedHomeState extends State<CombinedHome> {
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
      height: 140,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF3F51B5)]),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SafeHaven', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('User + Volunteer', style: GoogleFonts.poppins(color: Colors.white70)),
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
              // SOS section (same as user)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text('Emergency SOS', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final newCase = CaseModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: 'Help Request #${DateTime.now().millisecondsSinceEpoch % 1000}',
                            location: 'Your current location',
                            status: 'active');
                        _service.addCase(newCase);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🚨 SOS sent!')));
                      },
                      icon: const Icon(Icons.emergency),
                      label: const Text('Send SOS'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // Volunteer requests
              Text('Active Help Requests', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              StreamBuilder<List<CaseModel>>(
                stream: _service.stream,
                builder: (context, snap) {
                  if (snap.hasError) return Text('Error: ${snap.error}');
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final active = snap.data!;
                  if (active.isEmpty) return const Text('No requests.');
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: active.length,
                    itemBuilder: (context, i) {
                      final c = active[i];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(c.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          subtitle: Text('${c.location} • ${c.status}'),
                          trailing: c.status == 'active'
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  onPressed: () async {
                                    await _service.acceptCase(c.id);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accepted')));
                                  },
                                  child: const Text('Accept'),
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ]),
          ),
        )
      ]),
      bottomNavigationBar: const BottomNav(currentRoute: '/combined_home', role: 'combined'),
    );
  }
}
