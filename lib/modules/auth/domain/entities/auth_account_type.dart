enum AuthAccountType {
  owner,
  employee;

  String get apiValue => name.toUpperCase();
}
