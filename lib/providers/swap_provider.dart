import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../models/swap_model.dart';

class SwapProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<SwapModel> _sentSwaps = [];
  List<SwapModel> _receivedSwaps = [];
  bool _isLoading = false;
  String? _error;

  List<SwapModel> get sentSwaps => _sentSwaps;
  List<SwapModel> get receivedSwaps => _receivedSwaps;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Stream for real-time updates on sent swaps
  Stream<List<SwapModel>> sentSwapsStream(String userId) =>
      _firestoreService.getUserSwapsStream(userId);

  // Stream for real-time updates on received swaps
  Stream<List<SwapModel>> receivedSwapsStream(String userId) =>
      _firestoreService.getReceivedSwapsStream(userId);

  // Initiate a swap
  Future<bool> initiateSwap(SwapModel swap) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.initiateSwap(swap);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to initiate swap: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Accept a swap
  Future<bool> acceptSwap(String swapId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.updateSwapStatus(swapId, 'Accepted');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to accept swap: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reject a swap
  Future<bool> rejectSwap(String swapId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.updateSwapStatus(swapId, 'Rejected');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to reject swap: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
