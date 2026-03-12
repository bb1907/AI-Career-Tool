import '../errors/app_exception.dart';
import '../errors/failure.dart';
import 'result.dart';

class ApiClient {
  const ApiClient();

  Future<Result<T>> guard<T>(Future<T> Function() request) async {
    try {
      return Success<T>(await request());
    } on AppException catch (error) {
      return Error<T>(Failure(error.message, cause: error));
    } catch (error) {
      return Error<T>(Failure('Unexpected network failure.', cause: error));
    }
  }
}
