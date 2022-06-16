part of 'deeproute_cubit.dart';

enum DeepRouteType {
  chat,
}

class DeepRouteState extends Equatable {
  const DeepRouteState({required this.type, required this.route});

  final DeepRouteType? type;
  final String? route;

  @override
  List<Object?> get props => [route];
}

class DeepRouteInitial extends DeepRouteState {
  const DeepRouteInitial() : super(type: null, route: null);
}
