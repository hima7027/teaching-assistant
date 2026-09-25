import 'package:teaching_assistant/fearures/auth/domain/repository.dart';

class Login{
  final Repository _repository;

  Login(this._repository);

  Future<void> login(String id, String password,) async{
    return await _repository.login(id: id, password: password,);
  }
}