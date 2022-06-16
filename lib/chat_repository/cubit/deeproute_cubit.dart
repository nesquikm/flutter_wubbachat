import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'deeproute_state.dart';

class DeepRouteCubit extends Cubit<DeepRouteState> {
  DeepRouteCubit() : super(const DeepRouteInitial());

  void setRoute({required DeepRouteType type, required String route}) {
    emit(DeepRouteState(type: type, route: route));
  }

  void clear() {
    emit(const DeepRouteInitial());
  }
}
