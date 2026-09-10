typedef Validator = String? Function(String? value);

Validator combineValidators(List<Validator> validators){
  return (value) {
    for (final validator in validators){
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  };
}

class Validators {
  Validators._();

  static String? required(String? value, [String message= 'This field is required']){
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value){
    if (value == null || value.isEmpty) return null;
    final emailPattern = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if(!emailPattern.hasMatch(value.trim())){
      return "Enter a valid email address";
    }
    return null;
  }
  static String? minLength(String? value, int length){
    if (value == null || value.length < length){
      return "Must be at least $length characters";
    }
    return null;
  }
}