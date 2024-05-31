import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class CloudContainer extends StatefulWidget {
  /// [waveCount] - 波の数,
  /// [color] - コンテナの色,
  /// [width] - コンテナの幅,
  /// [height] - コンテナの高さ,
  /// [waveRadius] - 波の半径,
  /// [touchStrength] - タッチの強さ,
  /// [child] - 子ウィジェット,
  /// [borderWidth] - 境界線の幅,
  /// [borderColor] - 境界線の色（デフォルトは黒）
  const CloudContainer(
      {super.key,
      required this.waveCount,
      required this.color,
      required this.width,
      required this.height,
      required this.waveRadius,
      required this.touchStrength,
      this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      this.child,
      this.isWaveMove = false,
      this.borderWidth,
      this.borderColor = Colors.black,
      this.wavePaddingVertical = 0.0,
      this.wavePaddingHorizontal = 0.0,
      this.actionNumber});

  final int waveCount;
  final Color color;
  final double width;
  final double height;
  final double waveRadius;
  final double touchStrength;
  final EdgeInsets padding;
  final Widget? child;
  final bool isWaveMove;
  final double? borderWidth;
  final Color borderColor;
  final double wavePaddingVertical;
  final double wavePaddingHorizontal;
  final int? actionNumber;

  @override
  State<CloudContainer> createState() => _CloudContainerState();
}

class _CloudContainerState extends State<CloudContainer>
    with TickerProviderStateMixin {
  /// wave animation controller and animation
  late AnimationController _waveAnimationController;
  late Animation _waveAnimation;

  /// tap animation controller and animation
  late AnimationController _touchAnimationController;
  late Animation _touchAnimation;

  /// wave radius add random value
  final List<double> randomRadiusAdjustList = [];

  /// is show base line
  ///
  /// for TEST
  ///
  // bool isShowBaseLine = true;
  bool isShowBaseLine = false;

  /// touch position management numbering clockwise
  int touchIndex = 0;

  /// wave shape base point list
  final List<Offset> basePointList = [];

  /// touch move point delta list : touch to change delta
  final touchPointDeltas = List.generate(12, (_) => const Offset(0.0, 0.0));

  /// variable
  double waveBaseRectWidth = 0.0;
  double waveBaseRectHeight = 0.0;
  Path cloudPath = Path();

  Path createCloudPath() {
    final path = CloudPath(
      waveBaseRectWidth: waveBaseRectWidth,
      waveBaseRectHeight: waveBaseRectHeight,
      animationValue: _waveAnimation.value,
      waveRadius: widget.waveRadius + waveBaseRectWidth / 40,
      waveCount: widget.waveCount,
      pointDeltas: touchPointDeltas,
      basePointList: basePointList,
      randomRadiusList: randomRadiusAdjustList,
    );
    return path.createPath();
  }

  void setWaveBaseRectSize() {
    setState(() {
      waveBaseRectWidth = widget.width - widget.wavePaddingHorizontal;
      waveBaseRectHeight = widget.height - widget.wavePaddingVertical;
    });
  }

  void setBasePointList() {
    basePointList.clear();
    basePointList.addAll([
      const Offset(0, 0),
      Offset(waveBaseRectWidth / 4, 0),
      Offset(waveBaseRectWidth / 2, 0),
      Offset(waveBaseRectWidth * 3 / 4, 0),
      Offset(waveBaseRectWidth, 0),
      Offset(waveBaseRectWidth, waveBaseRectHeight / 2),
      Offset(waveBaseRectWidth, waveBaseRectHeight),
      Offset(waveBaseRectWidth * 3 / 4, waveBaseRectHeight),
      Offset(waveBaseRectWidth / 2, waveBaseRectHeight),
      Offset(waveBaseRectWidth / 4, waveBaseRectHeight),
      Offset(0, waveBaseRectHeight),
      Offset(0, waveBaseRectHeight / 2),
    ]);
  }

  /// set random radius adjust list
  void setRandomList() {
    final oneLength =
        (waveBaseRectWidth * 2 + waveBaseRectHeight * 2) / widget.waveCount;
    randomRadiusAdjustList.clear();
    randomRadiusAdjustList.addAll(
      List.generate(widget.waveCount, (_) => 0),
      // widget.waveCount, (_) => Random().nextDouble() * oneLength / 8),
    );
  }

  // void touchAction() {
  //   if (widget.actionNumber == null) return;
  //   _touchAnimationController.reset();
  //   setState(() {
  //     if (widget.actionNumber != null) {
  //       if (widget.actionNumber! < 5) {
  //         touchIndex = widget.actionNumber!;
  //       } else if (widget.actionNumber == 5) {
  //         touchIndex = 11;
  //       } else if (widget.actionNumber == 9) {
  //         touchIndex = 5;
  //       } else {
  //         touchIndex = 10 - (1 + (widget.actionNumber! - 11));
  //       }

  //       _touchAnimationController.forward().then((value) {
  //         _touchAnimationController.reverse();
  //       });
  //     }
  //   });
  // }

  void downAction() {
    final List<Offset> newTouchPointDeltas = [
      /// 0
      Offset(waveBaseRectWidth / 20 * _touchAnimation.value,
              waveBaseRectHeight / 10 * _touchAnimation.value) *
          widget.touchStrength,

      /// 1
      Offset(0, waveBaseRectHeight / 10 * _touchAnimation.value) *
          widget.touchStrength,

      /// 2
      Offset(0, waveBaseRectHeight / 10 * _touchAnimation.value) *
          widget.touchStrength,

      /// 3
      Offset(0, waveBaseRectHeight / 10 * _touchAnimation.value) *
          widget.touchStrength,

      /// 4
      Offset(-waveBaseRectWidth / 20 * _touchAnimation.value,
              waveBaseRectHeight / 10 * _touchAnimation.value) *
          widget.touchStrength,

      /// 5
      Offset(waveBaseRectWidth / 20 * _touchAnimation.value, 0) *
          widget.touchStrength,

      /// 6
      Offset(-waveBaseRectWidth / 20 * _touchAnimation.value,
              -waveBaseRectHeight / 10 * _touchAnimation.value) *
          widget.touchStrength,

      /// 7
      Offset(0, -waveBaseRectHeight / 10 * _touchAnimation.value) *
          widget.touchStrength,

      /// 8
      Offset(0, -waveBaseRectHeight / 10 * _touchAnimation.value) *
          widget.touchStrength,

      /// 9
      Offset(0, -waveBaseRectHeight / 10 * _touchAnimation.value) *
          widget.touchStrength,

      /// 10
      Offset(waveBaseRectWidth / 20 * _touchAnimation.value,
              -waveBaseRectHeight / 10 * _touchAnimation.value) *
          widget.touchStrength,

      /// 11
      Offset(-waveBaseRectWidth / 20 * _touchAnimation.value, 0) *
          widget.touchStrength,
    ];
    touchPointDeltas.clear();
    touchPointDeltas.addAll(newTouchPointDeltas);
    _touchAnimationController.reset();
    _touchAnimationController.forward();
  }

  /// point をタッチした時のデルタを計算
  void setPointDelta(
    int index,
  ) {
    switch (index) {
      case 0:
        touchPointDeltas[index] = Offset(
                waveBaseRectWidth / 10 * _touchAnimation.value,
                waveBaseRectHeight / 7 * _touchAnimation.value) *
            widget.touchStrength;
      case 1:
        touchPointDeltas[index] = Offset(
                waveBaseRectWidth / 15 * _touchAnimation.value,
                waveBaseRectHeight / 5 * _touchAnimation.value) *
            widget.touchStrength;
      case 2:
        touchPointDeltas[index] = Offset(0 * _touchAnimation.value as double,
                waveBaseRectHeight / 4 * _touchAnimation.value) *
            widget.touchStrength;
      case 3:
        touchPointDeltas[index] = Offset(
                -waveBaseRectWidth / 15 * _touchAnimation.value,
                waveBaseRectHeight / 5 * _touchAnimation.value) *
            widget.touchStrength;
      case 4:
        touchPointDeltas[index] = Offset(
                -waveBaseRectWidth / 10 * _touchAnimation.value,
                waveBaseRectHeight / 7 * _touchAnimation.value) *
            widget.touchStrength;
      case 5:
        // touchPointDeltas[index] = Offset(
        //         -waveBaseRectWidth / 10 * _touchAnimation.value,
        //         0 * _touchAnimation.value as double) *
        //     widget.touchStrength;
        touchPointDeltas[index] = const Offset(0.0, 0.0);
      case 6:
        touchPointDeltas[index] = Offset(
                -waveBaseRectWidth / 10 * _touchAnimation.value,
                -waveBaseRectHeight / 7 * _touchAnimation.value) *
            widget.touchStrength;
      case 7:
        touchPointDeltas[index] = Offset(
                -waveBaseRectWidth / 15 * _touchAnimation.value,
                -waveBaseRectHeight / 5 * _touchAnimation.value) *
            widget.touchStrength;
      case 8:
        touchPointDeltas[index] = Offset(0 * _touchAnimation.value as double,
                -waveBaseRectHeight / 4 * _touchAnimation.value) *
            widget.touchStrength;
      case 9:
        touchPointDeltas[index] = Offset(
                waveBaseRectWidth / 15 * _touchAnimation.value,
                -waveBaseRectHeight / 5 * _touchAnimation.value) *
            widget.touchStrength;
      case 10:
        touchPointDeltas[index] = Offset(
                waveBaseRectWidth / 10 * _touchAnimation.value,
                -waveBaseRectHeight / 7 * _touchAnimation.value) *
            widget.touchStrength;
      case 11:
        // touchPointDeltas[index] = Offset(
        //         waveBaseRectWidth / 10 * _touchAnimation.value,
        //         0 * _touchAnimation.value as double) *
        //     widget.touchStrength;
        touchPointDeltas[index] = const Offset(0.0, 0.0);
      default:
    }
  }

  @override
  void initState() {
    super.initState();

    /// wave animation
    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _waveAnimation = Tween<double>(begin: 0, end: 0.01).animate(CurvedAnimation(
        parent: _waveAnimationController, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {
          cloudPath = createCloudPath();
        });
      });

    /// touch animation
    _touchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _touchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _touchAnimationController, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {
          setPointDelta(touchIndex);
        });
      });

    setWaveBaseRectSize();
    setRandomList();
    setBasePointList();

    cloudPath = createCloudPath();
    if (widget.isWaveMove) {
      _waveAnimationController.repeat(reverse: true);
    } else {
      Future.delayed(Duration(milliseconds: Random().nextInt(2000)), () {
        _waveAnimationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    _touchAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CloudContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.width != oldWidget.width || widget.height != oldWidget.height) {
      setWaveBaseRectSize();
      setRandomList();
      setBasePointList();
    }
    if (widget.actionNumber != oldWidget.actionNumber &&
        widget.actionNumber != null) {
      downAction();
    }
    if (widget.height != oldWidget.height) {
      setWaveBaseRectSize();
      setRandomList();
      setBasePointList();

      cloudPath = createCloudPath();
      if (widget.isWaveMove) {
        _waveAnimationController.repeat(reverse: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        color: Colors.transparent,
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: CustomPaint(
                painter: CloudPainter(
                    path: cloudPath,
                    color: widget.color,
                    isShowBaseLine: isShowBaseLine,
                    borderWidth: widget.borderWidth,
                    borderColor: widget.borderColor),
                size: Size(waveBaseRectWidth, waveBaseRectHeight),
              ),
            ),
            Center(
              child: SizedBox(
                width: widget.width,
                height: widget.height,
                child: ClipPath(
                  clipper: CloudClipper(
                    path: cloudPath,
                    paddingHorizontal: widget.wavePaddingHorizontal / 2,
                    paddingVertical: widget.wavePaddingVertical / 2,
                  ),
                  child: OverflowBox(
                    maxHeight: widget.height * 2,
                    maxWidth: widget.width * 2,
                    child: Container(
                        width: widget.width * 2,
                        height: widget.height * 2,
                        color: widget.color,
                        child: OverflowBox(
                            // maxHeight: widget.height * 2,
                            child: Center(
                          child: widget.child,
                        ))),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: widget.height,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: widget.width / widget.height * 3 / 5,
                  mainAxisSpacing: 0.0,
                  crossAxisSpacing: 0.0,
                ),
                itemCount: 15,
                itemBuilder: (context, index) {
                  /// touch action object
                  return GestureDetector(
                    // onTap: () {
                    //   // onTap(index);
                    // },

                    /// 確認用
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isShowBaseLine
                                ? Colors.black
                                : Colors.transparent),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CloudPath {
  CloudPath({
    required this.waveBaseRectWidth,
    required this.waveBaseRectHeight,
    required this.animationValue,
    required this.waveRadius,
    required this.waveCount,
    required this.randomRadiusList,
    required this.pointDeltas,
    required this.basePointList,
  });
  final double waveBaseRectWidth;
  final double waveBaseRectHeight;
  final double animationValue;
  final double waveRadius;
  final int waveCount;
  final List<double> randomRadiusList;
  final List<Offset> pointDeltas;
  final List<Offset> basePointList;

  final Path _cloudPath = Path();
  final pointList = <Offset>[];

  Offset? getOffset(Path path, double progress) {
    List<PathMetric> pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) {
      return null;
    }
    double pathLength = pathMetrics.first.length;
    final distance = pathLength * progress;
    final Tangent? tangent = pathMetrics.first.getTangentForOffset(distance);
    final offset = tangent?.position;
    if (offset == null) {
      return null;
    }
    return Offset(offset.dx, offset.dy);
  }

  Path createPath() {
    final adjustedBpList = List<Offset>.generate(basePointList.length, (i) {
      return basePointList[i] + pointDeltas[i];
    });
    final basePath1 = Path();
    for (int i = 0; i < adjustedBpList.length; i++) {
      if (i == 0) {
        basePath1.moveTo(adjustedBpList[i].dx, adjustedBpList[i].dy);
        continue;
      } else {
        basePath1.lineTo(adjustedBpList[i].dx, adjustedBpList[i].dy);
      }
    }
    basePath1.close();

    /// 動く点ををリストに追加
    for (int i = 0; i < waveCount; i++) {
      final progress = (i / waveCount + animationValue) % 1
          //  +0.02
          -
          randomRadiusList[i] / 500; // ランダムを加える

      final offset = getOffset(basePath1, progress) ?? const Offset(0, 0);
      pointList.add(offset);
    }
    for (int i = 0; i < waveCount; i++) {
      if (i == 0) {
        _cloudPath.moveTo(pointList[i].dx, pointList[i].dy);
        continue;
      }
      _cloudPath.arcToPoint(
        Offset(pointList[i].dx, pointList[i].dy),
        radius: Radius.circular(waveRadius - randomRadiusList[i]),
        // largeArc: true,
        clockwise: true,
      );
      if (i == waveCount - 1) {
        _cloudPath.arcToPoint(
          Offset(pointList[0].dx, pointList[0].dy),
          radius: Radius.circular(waveRadius - randomRadiusList[0]),
          // largeArc: true,
          clockwise: true,
        );
      }
    }
    _cloudPath.close();

    return _cloudPath;
  }
}

class CloudClipper extends CustomClipper<Path> {
  CloudClipper({
    required this.path,
    required this.paddingHorizontal,
    required this.paddingVertical,
  });
  final Path path;
  final double paddingHorizontal;
  final double paddingVertical;

  @override
  Path getClip(Size size) {
    return path.shift(Offset(paddingHorizontal, paddingVertical));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class CloudPainter extends CustomPainter {
  CloudPainter({
    required this.path,
    required this.color,
    required this.isShowBaseLine,
    required this.borderWidth,
    required this.borderColor,
  });
  final Path path;
  final Color color;
  final bool isShowBaseLine;
  final double? borderWidth;
  final Color borderColor;

  void _drawCloud(Canvas canvas, Path cloudPath) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    /// shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    /// shadow paint
    canvas.drawPath(cloudPath.shift(const Offset(3, 3)), shadowPaint);

    /// fill paint
    // canvas.drawPath(cloudPath, fillPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawCloud(canvas, path);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
