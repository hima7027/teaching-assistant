abstract class UseCases<T, Params>{
  const UseCases();
  T call(Params params);
}