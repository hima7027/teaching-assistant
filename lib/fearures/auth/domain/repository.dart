abstract class Repository {
  Repository();

  Future<void> login({required String id, required String password});
}