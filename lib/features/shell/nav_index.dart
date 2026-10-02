import 'package:flutter_riverpod/flutter_riverpod.dart';

final navIndexProvider = NotifierProvider<NavIndex, int>(NavIndex.new);

class NavIndex extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}
