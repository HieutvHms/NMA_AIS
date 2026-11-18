import 'package:get_it/get_it.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../features/member_management/data/datasources/member_remote_data_source_impl.dart';
import '../../../features/member_management/data/datasources/member_remote_datasource.dart';
import '../../../features/member_management/data/repositories/member_repository_impl.dart';
import '../../../features/member_management/domain/repositories/member_repository.dart';
import '../../../features/member_management/domain/usecases/create_member_usecase.dart';
import '../../../features/member_management/domain/usecases/delete_member_usecase.dart';
import '../../../features/member_management/domain/usecases/get_members_usecase.dart';
import '../../../features/member_management/domain/usecases/update_member_usecase.dart';
import '../../../features/member_management/presentation/cubit/member_management_cubit.dart';

void registerMemberManagementModule(GetIt sl) {
  // DataSource
  sl.registerLazySingleton<MemberRemoteDataSource>(
    () => MemberRemoteDataSourceImpl(sl<DioClient>().dio, sl<LocalStorage>()),
  );

  // Repository
  sl.registerLazySingleton<MemberRepository>(
    () => MemberRepositoryImpl(sl<MemberRemoteDataSource>()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetMembersUseCase(sl<MemberRepository>()));
  sl.registerLazySingleton(() => CreateMemberUseCase(sl<MemberRepository>()));
  sl.registerLazySingleton(() => UpdateMemberUseCase(sl<MemberRepository>()));
  sl.registerLazySingleton(() => DeleteMemberUseCase(sl<MemberRepository>()));

  // Cubit
  sl.registerFactory<MemberManagementCubit>(
    () => MemberManagementCubit(
      getMembersUseCase: sl<GetMembersUseCase>(),
      createMemberUseCase: sl<CreateMemberUseCase>(),
      updateMemberUseCase: sl<UpdateMemberUseCase>(),
      deleteMemberUseCase: sl<DeleteMemberUseCase>(),
    ),
  );
}
