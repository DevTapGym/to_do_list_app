import 'package:to_do_list_app/models/auth_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_list_app/services/team_service.dart';

abstract class TeamMemberEvent {}

class LoadTeamMembersByTeamId extends TeamMemberEvent {
  final int teamId;
  LoadTeamMembersByTeamId(this.teamId);
}

abstract class TeamMemberState {}

class TeamMemberInitial extends TeamMemberState {}

class TeamMemberLoading extends TeamMemberState {}

class TeamMemberLoaded extends TeamMemberState {
  final List<User> members;
  TeamMemberLoaded(this.members);
}

class TeamMemberError extends TeamMemberState {
  final String message;
  TeamMemberError(this.message);
}

class TeamMemberBloc extends Bloc<TeamMemberEvent, TeamMemberState> {
  final TeamService teamService;

  TeamMemberBloc(this.teamService) : super(TeamMemberInitial()) {
    on<LoadTeamMembersByTeamId>((event, emit) async {
      emit(TeamMemberLoading());
      try {
        final member = await teamService.getMembersByTeamId(event.teamId);
        emit(TeamMemberLoaded(member));
      } catch (error) {
        emit(TeamMemberError(error.toString()));
      }
    });
  }
}
