import 'dart:async';
import '../models/case_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CasesService {
  CasesService._internal() {
    _initMockData();
  }
  static final CasesService _instance = CasesService._internal();
  factory CasesService() => _instance;

  final StreamController<List<CaseModel>> _controller = StreamController.broadcast();
  final List<CaseModel> _cases = [];

  Stream<List<CaseModel>> get stream => _controller.stream;

  // Example: load from Node backend (replace URL)
  Future<void> fetchFromServer() async {
    try {
      // TODO: replace with your Node backend endpoint
      // final res = await http.get(Uri.parse('http://localhost:3000/api/cases'));
      // if (res.statusCode == 200) {
      //   final List list = jsonDecode(res.body);
      //   _cases.clear();
      //   _cases.addAll(list.map((e) => CaseModel.fromJson(e)).toList());
      // }

      // For now use local list:
      _controller.add(List.unmodifiable(_cases));
    } catch (e) {
      _controller.addError(e);
    }
  }

  // Accept a case (volunteer action)
  Future<void> acceptCase(String id) async {
    final idx = _cases.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    _cases[idx].accepted = true;
    _cases[idx].status = 'in-progress';
    _controller.add(List.unmodifiable(_cases));

    // TODO: call backend to persist accept
    // await http.post(Uri.parse('http://.../accept'), body: {...});
  }

  // Submit report for a case (could mark resolved)
  Future<void> submitReport(String id, {String? newStatus}) async {
    final idx = _cases.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    if (newStatus != null) _cases[idx].status = newStatus;
    _controller.add(List.unmodifiable(_cases));

    // TODO: persist change to backend
  }

  // Follow up (just a sample)
  Future<void> followUp(String id) async {
    // maybe add a log or ping backend
    // For now no-op aside from notifying listeners
    _controller.add(List.unmodifiable(_cases));
  }

  // Add new case (for SOS)
  Future<void> addCase(CaseModel c) async {
    _cases.insert(0, c); // newest at top
    _controller.add(List.unmodifiable(_cases));
    // TODO: send to backend
  }

  void _initMockData() {
    // initial mock cases
    _cases.addAll([
      CaseModel(id: '101', title: 'Help Request #101', location: 'MG Road', status: 'active'),
      CaseModel(id: '099', title: 'Help Request #099', location: 'City Center', status: 'in-progress', accepted: true),
      CaseModel(id: '097', title: 'Help Request #097', location: 'Near Park', status: 'resolved'),
    ]);
    // push initial
    _controller.add(List.unmodifiable(_cases));
  }

  void dispose() {
    _controller.close();
  }
}
