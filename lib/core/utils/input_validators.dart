import 'validators.dart';

abstract final class InputValidators {
  static String? email(String? value) => Validators.email(value);

  static String? password(String? value) => Validators.password(value);

  static String? requiredField(String? value, {required String fieldName}) {
    return Validators.requiredField(value, fieldName: fieldName);
  }

  static String? yearsOfExperience(String? value) {
    return Validators.yearsOfExperience(value);
  }
}
