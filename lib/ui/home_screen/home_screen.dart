import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:huwamemo/models/memo_model.dart';
import 'package:huwamemo/settings/text_theme.dart';
import 'package:huwamemo/ui/home_screen/home_screen_view_model.dart';
import 'package:huwamemo/ui/state/home_screen_state.dart';
import 'package:huwamemo/utils/app_lifecycle_state_provider.dart';
import 'package:huwamemo/widgets/cloud_container.dart';
import 'package:huwamemo/widgets/error_dialog.dart';
import 'package:huwamemo/widgets/two_way_dialog.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeScreenViewModelProvider);

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final selectedMeme = useState<MemoModel?>(null);
    final actionNumber = useState<int?>(null);
    final showTextInput = useState<bool>(false);
    final focusNode = useFocusNode(descendantsAreFocusable: false);
    final textEditingController = useTextEditingController();
    final inputText = useState<String>('');

    final inputAnimationController = useAnimationController(
      duration: const Duration(milliseconds: 700),
    );

    void initialize() async {
      ref.read(homeScreenViewModelProvider.notifier).initialize();
    }

    /// 画面からはみ出さなければtrue
    bool totalHeightCheck(List<HomeMemo> homeMemos) {
      final padding = MediaQuery.of(context).padding;
      double safeHeight = MediaQuery.of(context).size.height -
          padding.top -
          padding.bottom -
          kToolbarHeight;
      double totalHeight = 0;

      for (HomeMemo memo in homeMemos) {
        totalHeight += memo.height;
      }
      return totalHeight < safeHeight - 150;
    }

    bool updateTotalHeightCheck(List<HomeMemo> homeMemos) {
      final padding = MediaQuery.of(context).padding;
      double safeHeight = MediaQuery.of(context).size.height -
          padding.top -
          padding.bottom -
          kToolbarHeight;
      double totalHeight = 0;

      for (HomeMemo memo in homeMemos) {
        totalHeight += memo.height;
      }
      return totalHeight < safeHeight;
    }

    void handleTapAdd() {
      showTextInput.value = true;
      textEditingController.clear();
      inputText.value = '';
      inputAnimationController.reset();
      inputAnimationController.forward();
      FocusScope.of(context).requestFocus(focusNode);
    }

    void deleteMemo(String id) async {
      try {
        await ref.read(homeScreenViewModelProvider.notifier).deleteMemo(id);
        initialize();
        selectedMeme.value = null;
      } catch (e) {
        return;
      }
    }

    void handleTapDelete(String id) {
      showDialog(
          context: context,
          builder: (context) => TwoWayDialog(
                title: '削除しますか？',
                leftButtonText: '削除',
                rightButtonText: 'キャンセル',
                onLeftButtonPressed: () {
                  FocusScope.of(context).unfocus();
                  deleteMemo(id);
                },
                onRightButtonPressed: () {
                  FocusScope.of(context).unfocus();
                },
              ));
    }

    void handleUpdate(MemoModel memo) async {
      final updatedMemos = await ref
          .read(homeScreenViewModelProvider.notifier)
          .checkUpdatedMemos(memo);

      if (!updateTotalHeightCheck(updatedMemos)) {
        if (!context.mounted) return;
        ErrorDialog.show(
          context,
          'メモの削除が必要です',
        );
        return;
      }
      try {
        await ref.read(homeScreenViewModelProvider.notifier).updateMemo(memo);
        selectedMeme.value = null;
        if (!context.mounted) return;
        initialize();
      } catch (e) {
        return;
      }
    }

    void handleHiddenTextInput() {
      inputAnimationController.reverse(from: 0.8);
      FocusScope.of(context).unfocus();
      Future.delayed(const Duration(milliseconds: 500), () {
        showTextInput.value = false;
      });
    }

    void handleSaveText(String text) async {
      if (!totalHeightCheck(state.homeMemos)) {
        if (!context.mounted) return;
        ErrorDialog.show(
          context,
          'メモの削除が必要です',
        );
        return;
      }
      try {
        await ref.read(homeScreenViewModelProvider.notifier).insertMemo(text);

        // showTextInput.value = false;

        // /// input をしまう
        // inputAnimationController.reverse();
        // if (!context.mounted) return;
        // FocusScope.of(context).unfocus();
        inputAnimationController.reverse();
        FocusScope.of(context).unfocus();
        Future.delayed(const Duration(milliseconds: 500), () {
          showTextInput.value = false;
        });

        initialize();
      } catch (e) {
        return;
      }
    }

    useEffect(() {
      initialize();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleTapAdd();
      });

      return;
    }, []);

    ref.listen<AppLifecycleState>(
      appLifecycleStateProvider,
      (previous, next) {
        if (previous == AppLifecycleState.inactive &&
            next == AppLifecycleState.resumed) {
          FocusScope.of(context).unfocus();
          selectedMeme.value = null;
          handleTapAdd();
        }
      },
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _bg(),

          /// 隠しTextField
          IgnorePointer(
            child: TextField(
              focusNode: focusNode,
              controller: textEditingController,
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (String value) {
                inputText.value = value;
              },
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, '/settings');
                      },
                      icon: Icon(
                        Icons.settings,
                        size: 36,
                        color: Colors.grey.shade400,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (!totalHeightCheck(state.homeMemos)) {
                            ErrorDialog.show(
                              context,
                              'メモの削除が必要です',
                            );
                            return;
                          } else {
                            handleTapAdd();
                          }
                        },
                        icon: Icon(
                          Icons.add_circle_rounded,
                          size: 48,
                          color: Colors.red.shade200,
                        )),
                  )
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SizedBox(
                height: h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ...List.generate(
                      state.homeMemos.length,
                      (index) => GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          selectedMeme.value = state.homeMemos[index].memo;
                        },
                        child: CloudContainer(
                          waveCount: 30,
                          color: Color(int.parse(
                              state.homeMemos[index].memo.color
                                  .split('(0x')[1]
                                  .split(')')[0],
                              radix: 16)),
                          width: w,
                          height: state.homeMemos[index].height,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          waveRadius: 15 + 10 * (w > 500 ? 1 : 0),
                          touchStrength: 0.7,
                          wavePaddingVertical: 15.0 + 20 * (w > 500 ? 1 : 0),
                          wavePaddingHorizontal: 50.0,
                          actionNumber: actionNumber.value,
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AutoSizeText(
                                    state.homeMemos[index].memo.content,
                                    style: const TextStyle(
                                        fontSize: 30, height: 1.1),
                                    minFontSize: 16,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          selectedMeme.value != null
              ? DetailWidget(
                  selectedMeme.value!,
                  onTapModal: () {
                    selectedMeme.value = null;
                  },
                  onDelete: (String id) {
                    handleTapDelete(id);
                  },
                  onUpdate: (MemoModel memo) {
                    handleUpdate(memo);
                  },
                )
              : const SizedBox.shrink(),
          showTextInput.value
              ? TextInput(
                  inputText: inputText.value,
                  appearAnimationController: inputAnimationController,
                  onHidden: () {
                    handleHiddenTextInput();
                  },
                  onSave: () {
                    handleSaveText(inputText.value);
                  },
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _bg() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment(0.9, -1.0),
            end: Alignment(-0.5, 1.0),
            colors: [
              Color.fromARGB(255, 38, 96, 212),
              Color.fromARGB(255, 62, 62, 222),
              Color.fromARGB(255, 98, 48, 236),
            ]),
      ),
    );
  }
}

class DetailWidget extends HookWidget {
  final MemoModel memo;
  final Function() onTapModal;
  final Function(String) onDelete;
  final Function(MemoModel) onUpdate;
  const DetailWidget(this.memo,
      {super.key,
      required this.onTapModal,
      required this.onDelete,
      required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    const wavePaddingHorizontal = 50.0;
    const wavePaddingVertical = 50.0;

    final contentTextController = useTextEditingController(text: memo.content);
    final descriptionTextController =
        useTextEditingController(text: memo.description);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 250),
    );
    final animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut);

    final scaleTween = Tween(begin: 0.8, end: 1.0);
    final scaleAnimation = scaleTween.animate(CurvedAnimation(
        parent: animationController,
        curve: const Cubic(0.18, 1.40, 0.985, 1.15)));

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final size = Size(w * 0.9, h * 0.7);
    final initialRemainingDays = memo.finishDate.difference(DateTime.now());

    final remainingDays = useState<Duration>(initialRemainingDays);

    void handleBack() {
      animationController.reverse();
      Future.delayed(const Duration(milliseconds: 200), () {
        onTapModal();
      });
    }

    void handleDelete() {
      onDelete(memo.memoId);
    }

    void incrementRemainingDays() {
      if (remainingDays.value.inDays > 98) return;
      remainingDays.value = remainingDays.value + const Duration(days: 1);
    }

    void decrementRemainingDays() {
      if (remainingDays.value.inDays < 1) return;
      remainingDays.value = remainingDays.value - const Duration(days: 1);
    }

    void handleUpdate() {
      final updatedMemo = MemoModel(
        memoId: memo.memoId,
        content: contentTextController.text,
        description: descriptionTextController.text,
        color: memo.color,
        finishDate: DateTime.now().add(remainingDays.value),
        createdAt: memo.createdAt,
      );
      onUpdate(updatedMemo);
    }

    useEffect(() {
      animationController.forward();
      return () {};
    }, []);

    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.topCenter,
            transform: Matrix4.identity()
              ..translate(0.0, (1 - animation.value) * -10, 0.0)
              ..scale(scaleAnimation.value, scaleAnimation.value, 1.0),
            child: Opacity(
              opacity: animation.value,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      width: w,
                      height: h,
                      color: Colors.black.withOpacity(0.7 * animation.value),
                    ),
                  ),
                  Align(
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: CloudContainer(
                        waveCount: 35,
                        color: Color(int.parse(
                            memo.color.split('(0x')[1].split(')')[0],
                            radix: 16)),
                        width: size.width,
                        height: size.height,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 0),
                        waveRadius: 30,
                        touchStrength: 0.7,
                        wavePaddingVertical: wavePaddingVertical,
                        wavePaddingHorizontal: wavePaddingHorizontal,
                      ),
                    ),
                  ),
                  Align(
                    child: Container(
                      width: size.width,
                      height: size.height,
                      padding: const EdgeInsets.all(25),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 12.0, left: 16.0, right: 16.0, bottom: 4),
                        child: SizedBox(
                          height: size.height,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '内容',
                                      style: lightTextTheme.bodyLarge,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.blueGrey,
                                                width: 1)),
                                        child: TextField(
                                          // focusNode: focusNode,
                                          controller: contentTextController,
                                          style: const TextStyle(
                                              fontSize: 24, height: 1.1),
                                          maxLines: null,
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.all(8),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '説明',
                                      style: lightTextTheme.bodyLarge,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.blueGrey,
                                                width: 1)),
                                        child: TextField(
                                          // focusNode: focusNode,
                                          controller: descriptionTextController,
                                          style: const TextStyle(
                                              fontSize: 24, height: 1.1),
                                          maxLines: null,
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.all(8),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '記入日',
                                          style: lightTextTheme.bodyLarge,
                                        ),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.blueGrey,
                                                  width: 1)),
                                          child: Center(
                                            child: AutoSizeText(
                                              "${memo.createdAt.month}/${memo.createdAt.day}",
                                              style: const TextStyle(
                                                  fontSize: 30, height: 1.1),
                                              minFontSize: 16,
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '残り日数',
                                          style: lightTextTheme.bodyLarge,
                                        ),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.blueGrey,
                                                  width: 1)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Center(
                                                  child: Text(
                                                    remainingDays.value.inDays <
                                                            1
                                                        ? remainingDays
                                                            .value.inHours
                                                            .toString()
                                                        : remainingDays
                                                            .value.inDays
                                                            .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 30,
                                                        height: 1.1),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                remainingDays.value.inDays < 1
                                                    ? '時間'
                                                    : '日',
                                                style: const TextStyle(
                                                    fontSize: 20),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade400,
                                        foregroundColor: Colors.white),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      handleDelete();
                                    },
                                    child: const Text('削除'),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      incrementRemainingDays();
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      decrementRemainingDays();
                                    },
                                    icon: const Icon(Icons.remove),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      handleUpdate();
                                    },
                                    child: const Text('更新'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0.0, 0.85),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 83, 132, 155),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 6),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        handleBack();
                      },
                      child: const Text('戻る', style: TextStyle(fontSize: 28)),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}

class TextInput extends StatelessWidget {
  final AnimationController appearAnimationController;
  final String inputText;
  final Function() onHidden;
  final Function() onSave;
  const TextInput(
      {super.key,
      required this.inputText,
      required this.appearAnimationController,
      required this.onHidden,
      required this.onSave});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final appearAnimation = CurvedAnimation(
        parent: appearAnimationController, curve: Curves.easeInOut);
    final opacityTween = Tween(begin: 0.0, end: 0.3);
    final opacityAnimation = opacityTween.animate(appearAnimation);
    final scaleTween = Tween(begin: 0.5, end: 1.0);
    final scaleAnimation = scaleTween.animate(CurvedAnimation(
        parent: appearAnimation, curve: const Cubic(0.38, 0.10, 0.785, 1.45)));
    final moveTween = Tween(begin: -400.0, end: 0.0);
    final moveAnimation = moveTween.animate(
        CurvedAnimation(parent: appearAnimation, curve: Curves.easeInOut));

    // useEffect(() {
    //   void handleAnimationStatusChange() {
    //     if (appearAnimationController.status == AnimationStatus.completed) {
    //       FocusScope.of(context).requestFocus(focusNode);
    //     }
    //   }

    //   appearAnimationController.addListener(handleAnimationStatusChange);
    //   return () =>
    //       appearAnimationController.removeListener(handleAnimationStatusChange);
    // }, [appearAnimationController]);

    return AnimatedBuilder(
        animation: appearAnimation,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () {
                  onHidden();
                },
                child: Container(
                  width: w,
                  height: h,
                  color: Colors.black.withOpacity(opacityAnimation.value),
                ),
              ),
              SafeArea(
                child: Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.identity()
                    ..translate(0.0, moveAnimation.value, 0.0)
                    ..scale(scaleAnimation.value, scaleAnimation.value, 1.0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Align(
                        alignment: const Alignment(0.0, -0.9),
                        child: CloudContainer(
                          waveCount: 25,
                          color: Colors.white,
                          width: w,
                          height: 200,
                          isWaveMove: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          waveRadius: 28,
                          touchStrength: 0.7,
                          wavePaddingVertical: 50.0,
                          wavePaddingHorizontal: 50.0,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 200,
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, top: 52, bottom: 0),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  // color: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Center(
                                      child: AutoSizeText(
                                    inputText,
                                    style: const TextStyle(
                                        fontSize: 30, height: 1.1),
                                    minFontSize: 16,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                ),
                              ),
                              const SizedBox(height: 4),
                              ElevatedButton(
                                onPressed: () {
                                  if (inputText.isEmpty) return;
                                  HapticFeedback.lightImpact();
                                  onSave();
                                },
                                child: const Text('追加'),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
}
