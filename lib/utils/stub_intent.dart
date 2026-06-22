class AndroidIntent {
  final String action;
  final String? package;
  final List<int>? flags;

  const AndroidIntent({required this.action, this.package, this.flags});

  Future<void> launch() async {}
}
