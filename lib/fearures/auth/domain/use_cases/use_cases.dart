import 'package:teaching_assistant/fearures/auth/domain/repository/repository.dart';

class Login{
  final Repository _repository;

  Login(this._repository);

  Future<void> login({required String id, required String password}) async{
     await _repository.login(id: id, password: password,);
  }
}