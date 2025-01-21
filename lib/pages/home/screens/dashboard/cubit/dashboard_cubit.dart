import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kontrolle_keyreg/pages/home/screens/dashboard/dashboard.dart';
import 'package:kontrolle_keyreg/repositories/list_repository.dart';

part 'dashboard_state.dart';

class ListCubit extends Cubit<ListState> {
  ListCubit({required this.repository}) : super(const ListState.loading());

  final ListRepository repository;

  Future<void> fetchList() async {
    try {} on Exception {
      emit(const ListState.failure());
    }
  }
}
