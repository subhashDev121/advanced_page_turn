import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../effects/index.dart';

class AdvancedPageTurnWidget extends StatefulWidget {
  const AdvancedPageTurnWidget({
    Key? key,
    this.amount,
    this.backgroundColor = const Color(0xFFFFFFCC),
    required this.child,
  }) : super(key: key);

  final Animation<double>? amount;
  final Color backgroundColor;
  final Widget child;

  @override
  _AdvancedPageTurnWidgetState createState() => _AdvancedPageTurnWidgetState();
}

class _AdvancedPageTurnWidgetState extends State<AdvancedPageTurnWidget> {
  final _boundaryKey = GlobalKey();
   var _image;

  @override
  void didUpdateWidget(AdvancedPageTurnWidget oldWidget) async{
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      _image = null;
    }
  }

  void _captureImage(Duration timeStamp) async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final boundary =
        _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    if (boundary.debugNeedsPaint) {
      await Future.delayed(const Duration(milliseconds: 20));
      return _captureImage(timeStamp);
    }
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    setState(() => _image = image);
  }

  @override
  Widget build(BuildContext context) {
    //var image = _image;
    if (_image != null) {
      return CustomPaint(
        painter: PageTurnEffect(
          amount: widget.amount ?? AlwaysStoppedAnimation<double>(1),
          image: _image ,
          backgroundColor: widget.backgroundColor,
        ),
        size: Size.infinite,
      );
    } else {
      WidgetsBinding.instance!.addPostFrameCallback(_captureImage);
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final size = constraints.biggest;
          return Stack(
            overflow: Overflow.clip,
            children: <Widget>[
              Positioned(
                left: 1 + size.width,
                top: 1 + size.height,
                width: size.width,
                height: size.height,
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: widget.child,
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
