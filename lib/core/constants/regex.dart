abstract final class AppRegex {
  static final RegExp email = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  static final RegExp phone = RegExp(r'^\+?[0-9]{9,15}$');

  static final RegExp numericOnly = RegExp(r'^[0-9]+$');

  static final RegExp alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');

  static final RegExp url = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );
}
