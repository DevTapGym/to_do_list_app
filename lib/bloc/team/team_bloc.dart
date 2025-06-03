import 'package:to_do_list_app/models/team.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_list_app/services/team_service.dart';

// --- Team Events ---
abstract class TeamEvent {}

class LoadTeamsByUserId extends TeamEvent {
  final int userId;
  LoadTeamsByUserId(this.userId);
}

// --- Team States ---
abstract class TeamState {}

class TeamInitial extends TeamState {}

class TeamLoading extends TeamState {}

class TeamLoaded extends TeamState {
  final List<Team> teams;
  TeamLoaded(this.teams);
}

class TeamError extends TeamState {
  final String message;
  TeamError(this.message);
}

// --- Team Bloc ---
class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final TeamService teamService;

  TeamBloc(this.teamService) : super(TeamInitial()) {
    on<LoadTeamsByUserId>((event, emit) async {
      emit(TeamLoading());
      try {
        final teams = await teamService.getTeamsByUserId(event.userId);
        emit(TeamLoaded(teams));
      } catch (error) {
        emit(TeamError(error.toString()));
      }
    });
  }
}
