abstract class Repository {
  Repository();

  Future<void> register({required String id, required String password,required String email});
  Future<void> login({required String id, required String password});
}