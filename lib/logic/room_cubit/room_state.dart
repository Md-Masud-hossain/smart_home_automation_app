import 'package:equatable/equatable.dart';
import 'package:smart_home_automation_app/data/modals/room_model.dart';

abstract class RoomState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class RoomLoaded extends RoomState {
  final List<RoomModel> rooms;
  RoomLoaded(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class RoomError extends RoomState {
  final String message;
  RoomError(this.message);

  @override
  List<Object?> get props => [message];
}