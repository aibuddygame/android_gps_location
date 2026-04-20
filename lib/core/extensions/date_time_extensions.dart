extension DebugDateTime on DateTime {
  String toDebugTime() {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    final second = this.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
