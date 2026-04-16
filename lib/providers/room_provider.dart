import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/room_model.dart';
import '../core/repositories/room_repository.dart';

/// Provider for managing real-time room vacancy state
class RoomProvider extends ChangeNotifier {
  final RoomRepository _roomRepository;

  RoomProvider({RoomRepository? roomRepository})
      : _roomRepository = roomRepository ?? RoomRepository();

  List<RoomModel> _vacantRooms = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<RoomModel>>? _vacancySubscription;

  // Getters
  List<RoomModel> get vacantRooms => _vacantRooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Subscribe to the real-time vacancy stream
  /// Updates the internal list whenever a room becomes available or changed
  void subscribeToVacancies() {
    _vacancySubscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _vacancySubscription = _roomRepository.getVacancyStream().listen(
      (rooms) {
        _vacantRooms = rooms;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Vacancy stream error: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Explicit pre-check for room availability to prevent race conditions
  /// Used before initiating a booking flow
  Future<bool> checkAvailability(String roomId) async {
    try {
      return await _roomRepository.checkRoomAvailability(roomId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Check if a specific property has any live vacancies
  bool hasVacancyForProperty(String propertyId) {
    return _vacantRooms.any((room) => room.propertyId == propertyId);
  }

  /// Update vacancy status for a room (Owner action)
  Future<void> toggleVacancy(String roomId, RoomStatus status) async {
    try {
      await _roomRepository.updateRoomStatus(roomId, status);
    } catch (e) {
      _errorMessage = 'Failed to update vacancy: $e';
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _vacancySubscription?.cancel();
    super.dispose();
  }
}
