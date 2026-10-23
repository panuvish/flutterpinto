part of 'websocket_bloc.dart';

sealed class WebsocketState extends Equatable {
  const WebsocketState();

  @override
  List<Object> get props => [];
}

final class WebsocketInitial extends WebsocketState {}

final class WebsocketLoadMessage extends WebsocketState {
  final List<String> messages;

  const WebsocketLoadMessage(this.messages);

  @override
  List<Object> get props => [messages];
}
