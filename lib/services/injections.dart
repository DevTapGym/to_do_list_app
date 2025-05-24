import 'package:get_it/get_it.dart';
import 'package:to_do_list_app/Repositories/Team/teamMemberRepository.dart';
import 'package:to_do_list_app/Repositories/Team/teamRepository.dart';
import 'package:to_do_list_app/Repositories/Team/teamTaskRepository.dart';
import 'package:to_do_list_app/Repositories/UserRepository.dart';
import 'package:to_do_list_app/bloc/Team/teamMember_bloc.dart';
import 'package:to_do_list_app/bloc/Team/teamTask_bloc.dart';
import 'package:to_do_list_app/bloc/Team/team_bloc.dart';
import 'package:to_do_list_app/models/auth_response.dart';
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
  getIt.registerSingleton<UserRepository>(UserRepository(getIt<AuthService>()));
  getIt.registerSingletonAsync<User>(() async {
    final userRepo = getIt<UserRepository>();
    final user = await userRepo.getUserbyEmail('quang123@gmail.com');
    return user;
  });
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
