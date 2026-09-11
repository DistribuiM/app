import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}
