import 'package:huwamemo/models/memo_model.dart';

class HomeScreenState {
  final List<HomeMemo> homeMemos;

  HomeScreenState({required this.homeMemos});
}

class HomeMemo {
  const HomeMemo(
      {required this.memo, required this.height, required this.remainingDays});

  final MemoModel memo;
  final double height;
  final Duration remainingDays;
}
