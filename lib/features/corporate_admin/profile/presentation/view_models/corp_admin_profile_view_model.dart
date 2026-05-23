import 'package:flutter/foundation.dart';
import '../../data/repositories/corp_admin_profile_repository.dart';

class CorpAdminProfileViewModel extends ChangeNotifier {
  CorpAdminProfileViewModel({required CorpAdminProfileRepository repository})
      : _repository = repository;
  final CorpAdminProfileRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Client / company fields
  String get clientName => _client['name'] as String? ?? '—';
  String get clientEmail =>
      _client['contactEmail'] as String? ??
      _client['email'] as String? ??
      '—';
  String get clientPhone =>
      _client['contactPhone'] as String? ??
      _client['phone'] as String? ??
      '—';
  String get clientIndustry =>
      _client['industry'] as String? ??
      _client['sector'] as String? ??
      '';
  String get clientAddress => _client['address'] as String? ?? '';

  // User name from /me response or Auth state
  String get userName {
    if (_me == null) return '—';
    final first = _me!['firstName'] as String? ?? '';
    final last = _me!['lastName'] as String? ?? '';
    final full = '$first $last'.trim();
    return full.isEmpty ? (_me!['name'] as String? ?? '—') : full;
  }

  Map<String, dynamic> _client = {};
  Map<String, dynamic>? _me;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _repository.fetchProfile();
      _client = (data['client'] as Map<String, dynamic>?) ?? {};
      _me = data['me'] as Map<String, dynamic>?;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
