import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiver/time.dart';

const _lorem =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean dictum ligula sem, ut commodo diam gravida eu. Donec at mollis ex. Duis vel nisi non neque accumsan lacinia eu eget velit. Nam ac lorem sem. Nulla pretium sodales ultricies. Morbi elementum enim vel nisi lacinia, eget auctor nisi congue. Interdum et malesuada fames ac ante ipsum primis in faucibus. Donec egestas neque sed imperdiet malesuada.';

class DetailScreen extends StatefulWidget {
  final int itemIndex;
  final String title;
  final MaterialColor color;
  final double screenHeight;

  const DetailScreen({
    Key key,
    this.itemIndex,
    this.color,
    this.title,
    this.screenHeight,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with TickerProviderStateMixin {
  AnimationController transitionOutController;

  /// boat transitionOut
  Animation<double> boatTransitionOut;

  /// background transition part 1 : to top
  Animation<FractionalOffset> backgroundTransitionOut1;

  /// background transition part 2 : to Boo
  Animation<FractionalOffset> backgroundTransitionOut2;

  Offset backgroundPosition = Offset(0, 150); //
  double backgroundOpacity = 1;

  final initialBoatOffset = Offset(0, 100);

  @override
  void initState() {
    _initAnimations();
    super.initState();
  }

  void _initAnimations() {
    transitionOutController =
        AnimationController(duration: aMillisecond * 1200, vsync: this)
          ..addStatusListener((status) {
            // pop the screen after transitionOut animation
            if (status == AnimationStatus.completed)
              Navigator.of(context).pop();
          });

    boatTransitionOut = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: transitionOutController,
        curve: Interval(0.0, 0.4, curve: Curves.easeInExpo),
      ),
    );

    backgroundTransitionOut1 = FractionalOffsetTween(
      begin: FractionalOffset(0, 150),
      end: FractionalOffset(0, -80),
    ).animate(
      CurvedAnimation(
        parent: transitionOutController,
        curve: Interval(0, 0.6, curve: Curves.bounceOut),
      ),
    )..addListener(() {
        setState(
          () => backgroundPosition =
              Offset(0, backgroundTransitionOut1.value?.dy ?? 150),
        );
      });

    backgroundTransitionOut2 = FractionalOffsetTween(
      begin: FractionalOffset(0, 10),
      end: FractionalOffset(0, widget.screenHeight),
    ).animate(
      CurvedAnimation(
        parent: transitionOutController,
        curve: Interval(0.6, 1, curve: Curves.easeOutExpo),
      ),
    )..addListener(() {
        if (transitionOutController.value > 0.6) {
          setState(() {
            backgroundOpacity = max(1 - transitionOutController.value, 0);
            backgroundPosition = Offset(
              backgroundTransitionOut2.value.dx,
              backgroundTransitionOut2.value.dy,
            );
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        overflow: Overflow.clip,
        children: <Widget>[
          _AnimatedBackground(
            color: widget.color,
            itemIndex: widget.itemIndex,
            transition: transitionOutController,
            rectPosition: Rect.fromPoints(
              backgroundPosition,
              size.bottomRight(Offset.zero),
            ),
            opacity: backgroundOpacity,
          ),
          _AnimatedBoat(
            boatOutAnimation: boatTransitionOut,
            itemIndex: widget.itemIndex,
          ),
          AnimatedOpacity(
            opacity: transitionOutController.status == AnimationStatus.dismissed
                ? 1
                : 0,
            duration: aMillisecond * 300,
            child: _TextContent(title: widget.title),
          ),
          _buildCloseButton()
        ],
      ),
    );
  }

  Padding _buildCloseButton() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.grey.shade400,
          onPressed: () => transitionOutController.forward(),
        ),
      );
}

class _AnimatedBoat extends StatelessWidget {
  const _AnimatedBoat({
    Key key,
    @required this.boatOutAnimation,
    @required this.itemIndex,
  }) : super(key: key);

  final Animation<double> boatOutAnimation;
  final finalBoatOffset = const Offset(0, -400);
  final int itemIndex;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // implicit transition in
      tween: Tween(begin: -700, end: 0),
      curve: Curves.easeInOutBack,
      duration: aMillisecond * 500,
      builder: (context, top, w) => AnimatedBuilder(
        animation: boatOutAnimation, // animated transition out
        builder: (context, _) => Transform.translate(
          offset: finalBoatOffset * boatOutAnimation.value - Offset(0, -top),
          child: Align(
            alignment: Alignment.topRight,
            child: _BigBoat(itemIndex: itemIndex),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  final Color color;
  final int itemIndex;
  final Rect rectPosition;
  final Animation transition;
  final double opacity;

  const _AnimatedBackground({
    Key key,
    this.color,
    this.itemIndex,
    this.rectPosition,
    this.transition,
    this.opacity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: transition,
      child: Opacity(
        opacity: opacity,
        child: Hero(
          tag: 'BG$itemIndex',
          child: AnimatedContainer(
            duration: Duration.zero,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              color: color,
            ),
            constraints: BoxConstraints.expand(),
          ),
        ),
      ),
      builder: (context, child) => Positioned.fromRect(
        rect: rectPosition,
        child: child,
      ),
    );
  }
}

class _BigBoat extends StatelessWidget {
  const _BigBoat({Key key, @required this.itemIndex}) : super(key: key);

  final int itemIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      width: 180,
      height: 400,
      child: Hero(tag: 'img$itemIndex', child: Image.asset('assets/big.png')),
    );
  }
}

class _TextContent extends StatelessWidget {
  final String title;

  const _TextContent({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).accentTextTheme;
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 80),
        child: Text.rich(
          TextSpan(
            text: '$title\n\n',
            style: textTheme.title,
            children: [TextSpan(text: _lorem, style: textTheme.body2)],
          ),
        ),
      ),
    );
  }
}
