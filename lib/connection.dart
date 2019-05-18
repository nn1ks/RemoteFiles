class Connection {
  final String address;
  final String port;
  final String username;
  final String passwordOrKey;
  final String path;

  Connection({
    this.address,
    this.port,
    this.username,
    this.passwordOrKey,
    this.path,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      address: json["address"],
      port: json["port"],
      username: json["username"],
      passwordOrKey: json["passwordOrKey"],
      path: json["path"],
    );
  }
}
