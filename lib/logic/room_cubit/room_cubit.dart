import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/room_repository.dart';
import 'room_state.dart';

class RoomCubit extends Cubit<RoomState> {
  final RoomRepository _roomRepository;
  StreamSubscription? _roomsSubscription;

  RoomCubit(this._roomRepository) : super(RoomInitial());

  void listenToRooms() {
    emit(RoomLoading());
    _roomsSubscription?.cancel();
    _roomsSubscription = _roomRepository.getUserRoomsStream().listen(
      (rooms) {
        emit(RoomLoaded(rooms));
      },
      onError: (error) {
        emit(RoomError(error.toString()));
      },
    );
  }

  Future<void> createRoom(String roomName) async {
    try {
      await _roomRepository.createRoom(roomName);
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  Future<void> toggleSwitch(String roomId, String switchId, bool newState) async {
    try {
      await _roomRepository.toggleSwitch(
        roomId: roomId,
        switchId: switchId,
        newState: newState,
      );
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  Future<void> renameSwitch(String roomId, String switchId, String newName) async {
    try {
      await _roomRepository.renameSwitch(
        roomId: roomId,
        switchId: switchId,
        newName: newName,
      );
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  Future<String?> addMember(String roomId, String email) async {
    try {
      await _roomRepository.addMemberByEmail(roomId: roomId, email: email);
      return null; // null মানে কোনো এরর নেই, সফল হয়েছে
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> removeMember(String roomId, String memberUid) async {
    try {
      await _roomRepository.removeMember(roomId: roomId, memberUid: memberUid);
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _roomsSubscription?.cancel();
    return super.close();
  }
}