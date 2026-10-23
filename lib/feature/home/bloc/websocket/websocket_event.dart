part of 'websocket_bloc.dart';

sealed class WebsocketEvent extends Equatable {
  const WebsocketEvent();

  @override
  List<Object> get props => [];
}

class InitialEvent extends WebsocketEvent {
  const InitialEvent();
}

class ReceiveEvent extends WebsocketEvent {
  final String message;
  const ReceiveEvent(this.message);
}

class SendEvent extends WebsocketEvent {
  final String message;
  const SendEvent(this.message);
}
