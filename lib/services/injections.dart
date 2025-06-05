import 'package:get_it/get_it.dart';
import 'package:to_do_list_app/repositories/team/team_member_repository.dart';
import 'package:to_do_list_app/repositories/team/team_repository.dart';
import 'package:to_do_list_app/repositories/team/team_task_repository.dart';
import 'package:to_do_list_app/bloc/Team/teamMember_bloc.dart';
import 'package:to_do_list_app/bloc/Team/teamTask_bloc.dart';
import 'package:to_do_list_app/bloc/Team/team_bloc.dart';
import 'package:to_do_list_app/services/auth_service.dart';
import 'package:to_do_list_app/services/team_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Đăng ký các dependency với registerSingleton
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<TeamRepository>(TeamRepository(getIt<AuthService>()));
  getIt.registerSingleton<TeamMemberRepository>(
    TeamMemberRepository(getIt<AuthService>()),
  );
  getIt.registerSingleton<TeamTaskRepository>(
    TeamTaskRepository(getIt<AuthService>()),
  );
  //getIt.registerSingleton<UserRepository>(UserRepository(getIt<AuthService>()));
  getIt.registerSingleton<TeamService>(
    TeamService(
      teamRepository: getIt<TeamRepository>(),
      teamMemberRepository: getIt<TeamMemberRepository>(),
      teamTaskRepository: getIt<TeamTaskRepository>(),
    ),
  );
  getIt.registerFactory<TeamBloc>(() => TeamBloc(getIt<TeamService>()));
  getIt.registerFactory<TeamMemberBloc>(
    () => TeamMemberBloc(getIt<TeamService>()),
  );
  getIt.registerFactory<TeamTaskBloc>(() => TeamTaskBloc(getIt<TeamService>()));
}
