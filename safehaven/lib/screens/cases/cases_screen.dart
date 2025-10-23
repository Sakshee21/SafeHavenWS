import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/cases_service.dart';
import '../../models/case_model.dart';

class CasesScreen extends StatefulWidget {
  const CasesScreen({super.key});

  @override
  State<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  final CasesService _service = CasesService();

  Color _statusColor(String s) {
    switch (s) {
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
  void initState() {
    super.initState();
    _service.fetchFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cases')),
      body: StreamBuilder<List<CaseModel>>(
        stream: _service.stream,
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final cases = snap.data!;
          if (cases.isEmpty) return const Center(child: Text('No cases available.'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: cases.length,
            itemBuilder: (context, i) {
              final c = cases[i];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: _statusColor(c.status), radius: 8),
                  title: Text(c.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  subtitle: Text('${c.location} • ${c.status}'),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await _service.submitReport(c.id, newStatus: 'in-progress');
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted')));
                        },
                        child: const Text('Submit Report'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton(
                        onPressed: () async {
                          await _service.followUp(c.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Follow-up logged')));
                        },
                        child: const Text('Follow Up'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNav(currentRoute: '/cases', role: 'volunteer'),
    );
  }
}
