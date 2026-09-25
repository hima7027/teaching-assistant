import 'package:teaching_assistant/core/use_cases/uses.dart';
import 'package:teaching_assistant/fearures/auth/domain/repository/repository.dart';

class Login implements UseCases<Future<void>, LoginParams>{
  final Repository _repository;

  Login(this._repository);


  @override
  Future<void> call(LoginParams params) async{
    await _repository.login(id: params.id, password: params.password);
  }
}

class LoginParams{
  final String id;
  final String password;

  LoginParams({required this.id, required this.password});
}