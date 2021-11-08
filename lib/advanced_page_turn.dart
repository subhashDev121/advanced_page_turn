import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'src/builders/index.dart';

class AdvancedPageTurn extends StatefulWidget {
  const AdvancedPageTurn({
    Key? key,
    this.duration = const Duration(milliseconds: 450),
    this.cutoff = 0.6,
    this.backgroundColor = const Color(0xFFFFFFCC),
    required this.children,
    this.initialIndex = 0,
    this.lastPage,
    this.showDragCutoff = false,
    this.onPageChanged
  }) : super(key: key);

  final ValueChanged<int>? onPageChanged;

  final Color backgroundColor;
  final List<Widget> children;
  final Duration duration;
  final int initialIndex;
  final Widget? lastPage;
  final bool showDragCutoff;
  final double cutoff;

  @override
  AdvancedPageTurnState createState() => AdvancedPageTurnState();
}

class AdvancedPageTurnState extends State<AdvancedPageTurn> with TickerProviderStateMixin {
  int pageNumber = 0;
  List<Widget> pages = [];

  List<AnimationController> _controllers = [];
  bool? _isForward;

  @override
  void didUpdateWidget(AdvancedPageTurn oldWidget) {
    if (oldWidget.children != widget.children) {
      _setUp();
    }
    if (oldWidget.duration != widget.duration) {
      _setUp();
    }
    if (oldWidget.backgroundColor != widget.backgroundColor) {
      _setUp();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controllers.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setUp();
  }

  void _setUp() {
    _controllers.clear();
    pages.clear();
    for (var i = 0; i < widget.children.length; i++) {
      final _controller = AnimationController(
        value: 1,
        duration: widget.duration,
        vsync: this,
      );
      _controllers.add(_controller);
      final _child = Container(
        child: AdvancedPageTurnWidget(
          backgroundColor: widget.backgroundColor,
          amount: _controller,
          child: widget.children[i],
        ),
      );
      pages.add(_child);
    }
    pages = pages.reversed.toList();
    pageNumber = widget.initialIndex;
  }

  bool get _isLastPage => pages != null && (pages.length - 1) == pageNumber;

  bool get _isFirstPage => pageNumber == 0;

  void _turnPage(DragUpdateDetails details, BoxConstraints dimens) {
    final _ratio = details.delta.dx / dimens.maxWidth;
    if (_isForward == null) {
      if (details.delta.dx > 0) {
        _isForward = false;
      } else {
        _isForward = true;
      }
    }
    if (_isForward ?? false || pageNumber == 0) {
      _controllers[pageNumber].value += _ratio;
    } else {
      if( pageNumber!=0){
        _controllers[pageNumber - 1].value += _ratio;
      }
    }
  }

  Future _onDragFinish() async {
    if (_isForward != null) {
      if (_isForward ?? false) {
        if (!_isLastPage &&
            _controllers[pageNumber].value <= (widget.cutoff + 0.15)) {
          await nextPage();
        } else {
          await _controllers[pageNumber].forward();
        }
      } else {
        if (!_isFirstPage &&
            _controllers[pageNumber - 1].value >= widget.cutoff) {
          await previousPage();
        } else {
          if (_isFirstPage) {
            await _controllers[pageNumber].forward();
          } else {
            if(pageNumber!=1){
              await _controllers[pageNumber - 1].reverse();
            }else{
              print("page in 0");
            }
          }
        }
      }
    }
    _isForward = null;
  }

  Future nextPage() async {
    print('Next Page..');
    await _controllers[pageNumber].reverse();
    if (mounted)
      setState(() {
        pageNumber++;
      });
  }

  Future previousPage() async {
    print('Previous Page..');
    if( pageNumber!=0){
      await _controllers[pageNumber - 1].forward();
      if (mounted) print("current page $pageNumber");
      setState(() {
        pageNumber--;
      });
    }
  }

  Future goToPage(int index) async {
    print('Navigate Page ${index + 1}..');
    if (mounted)
      setState(() {
        pageNumber = index;
      });
    for (var i = 0; i < _controllers.length; i++) {
      if (i == index) {
        _controllers[i].forward();
      } else if (i < index) {
        // _controllers[i].value = 0;
        _controllers[i].reverse();
      } else {
        if (_controllers[i].status == AnimationStatus.reverse)
          _controllers[i].value = 1;
      }
    }
  }

  _onPageIndexChanged(int currentPage){
    if(widget.onPageChanged!=null){
      setState(() {
        widget.onPageChanged!(currentPage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context, dimens) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragCancel: () => _isForward = null,
          onHorizontalDragUpdate: (details) {
            print("page turned $pageNumber");
            _onPageIndexChanged(pageNumber);
            return _turnPage(details, dimens);
          },
          onHorizontalDragEnd: (details) => {
            _onDragFinish()
          },
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (widget.lastPage != null) ...[
                widget.lastPage ?? Container(),
              ],
              if (pages != null)
                ...pages
              else ...[
                Container(child: CircularProgressIndicator()),
              ],
              Positioned.fill(
                child: Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Flexible(
                      flex: (widget.cutoff * 10).round(),
                      child: Container(
                        color: widget.showDragCutoff
                            ? Colors.blue.withAlpha(100)
                            : null,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _isFirstPage ? null : previousPage,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 10 - (widget.cutoff * 10).round(),
                      child: Container(
                        color: widget.showDragCutoff
                            ? Colors.red.withAlpha(100)
                            : null,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _isLastPage ? null : nextPage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
