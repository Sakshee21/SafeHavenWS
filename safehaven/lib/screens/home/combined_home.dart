import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/bottom_nav.dart';
import '../../models/case_model.dart';

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

class CombinedHome extends StatefulWidget {
  const CombinedHome({super.key});

  @override
  State<CombinedHome> createState() => _CombinedHomeState();
}

class _CombinedHomeState extends State<CombinedHome> {
  late List<CaseModel> allCases;

  @override
  void initState() {
    super.initState();
    allCases = [
      CaseModel(
          id: '1',
          title: 'Emergency near Park Street',
          location: 'Downtown, City A',
          status: 'active'),
      CaseModel(
          id: '2',
          title: 'Domestic Disturbance',
          location: 'Sector 8, City B',
          status: 'in-progress'),
      CaseModel(
          id: '3',
          title: 'Resolved Case #301',
          location: 'Block D, City C',
          status: 'resolved'),
    ];
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

  Widget _buildActiveCaseCard(CaseModel c) {
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
                    Text(c.title,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(c.location,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: _statusColor(c.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            c.status.toUpperCase(),
                            style: TextStyle(color: _statusColor(c.status)),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Accepted case: ${c.title}')));
              },
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

  Widget _buildPastCaseCard(CaseModel c) {
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
                    Text(c.title,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(c.location,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: _statusColor(c.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            c.status.toUpperCase(),
                            style: TextStyle(color: _statusColor(c.status)),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Submitting report for ${c.title}')));
                  },
                  icon: const Icon(Icons.note_add, size: 16),
                  label: const Text('Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A28FF),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Follow-up for ${c.title} logged')));
                  },
                  icon: const Icon(Icons.update, size: 16),
                  label: const Text('Follow Up'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ],
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
      height: 160,
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF3F51B5)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SafeHaven',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('User + Volunteer Dashboard',
            style: GoogleFonts.poppins(color: Colors.white70)),
      ]),
    );

    final activeCases =
        allCases.where((c) => c.status == 'active').toList();
    final pastCases = allCases
        .where((c) =>
            c.status == 'resolved' || c.status == 'in-progress')
        .toList();

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
                // --- SOS BUTTON (User section) ---
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Emergency SOS',
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          '🚨 SOS sent! Authorities alerted.')));
                            },
                            icon: const Icon(Icons.emergency, size: 24),
                            label: const Text('Send SOS'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ]),
                  ),
                ),

                const SizedBox(height: 24),

                // --- Volunteer section ---
                Text('⚠️ Active Help Requests',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                if (activeCases.isEmpty)
                  const Text('No active help requests.')
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
      bottomNavigationBar:
          const BottomNav(currentRoute: '/combined_home', role: 'combined'),
    );
  }
}
