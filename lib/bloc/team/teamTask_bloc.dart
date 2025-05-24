import 'package:to_do_list_app/models/team.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_list_app/services/team_service.dart';

abstract class TeamTaskEvent {}

class LoadTeamTasksByTeamId extends TeamTaskEvent {
  final int teamId;
  LoadTeamTasksByTeamId(this.teamId);
}

abstract class TeamTaskState {}

class TeamTaskInitial extends TeamTaskState {}

class TeamTaskLoading extends TeamTaskState {}

class TeamTaskLoaded extends TeamTaskState {
  final List<TeamTask> tasks;
  TeamTaskLoaded(this.tasks);
}

class TeamTaskError extends TeamTaskState {
  final String message;
  TeamTaskError(this.message);
}

class TeamTaskBloc extends Bloc<TeamTaskEvent, TeamTaskState> {
  final TeamService teamService;

  TeamTaskBloc(this.teamService) : super(TeamTaskInitial()) {
    on<LoadTeamTasksByTeamId>((event, emit) async {
      emit(TeamTaskLoading());
      try {
        final tasks = await teamService.getTeamTasksByTeamId(event.teamId);
        emit(TeamTaskLoaded(tasks));
      } catch (error) {
        emit(TeamTaskError(error.toString()));
      }
    });
  }
}
