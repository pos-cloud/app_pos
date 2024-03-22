import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBlocState {
  final List<String> selectedItems;
  const HomeBlocState({this.selectedItems = const []});

  HomeBlocState copyWith({List<String>? selectedItems}) {
    return HomeBlocState(selectedItems: selectedItems ?? this.selectedItems);
  }
}

class HomeBloc extends Cubit<HomeBlocState> {
  HomeBloc() : super(const HomeBlocState());

  void addSelectedItem(String id) {
    emit(state.copyWith(selectedItems: [...state.selectedItems, id]));
  }
}
