import 'package:teaching_assistant/core/use_cases/uses.dart';
import 'package:teaching_assistant/fearures/auth/domain/repository/repository.dart';

class Register implements UseCases<Future<void>, RegisterParams>{
  final Repository _repository;

  Register(this._repository);


  @override
  Future<void> call(RegisterParams params) async{
    await _repository.register(id: params.id, password: params.password, email: params.email);
  }
}

class RegisterParams{
  final String id;
  final String email;
  final String password;

  RegisterParams({required this.id, required this.password, required this.email});
}