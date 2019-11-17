import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';
import 'package:quiver/time.dart';
import 'package:rent_a_boat/details_screen.dart';

import 'fade_route.dart';

const items = [
  'Bora Hora, 2 days',
  'Sun Island, 3 days',
  'Mana Huri, 4 days',
  'Hanalulu 5 days',
  'Mana Hini, 7 days',
];

class ScrollingState {
  final bool scrolling;
  final VerticalDirection direction;

  ScrollingState(this.scrolling, this.direction);
}

const colors = [
  Colors.teal,
  Colors.lightBlue,
  Colors.cyan,
  Colors.orange,
  Colors.amber
];

final Matrix4 perspective = _pmat(1.0);

Matrix4 _pmat(num pv) => Matrix4(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, pv * 0.001, 0.0, 0.0, 0.0, 1.0);

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController scrollController;

  ScrollingState scrollingState = ScrollingState(false, null);

  double scrollRef;
  Timer timer;

  @override
  void initState() {
    scrollController = ScrollController()..addListener(_onScroll);
    super.initState();
  }

  /// scroll listener
  void _onScroll() {
    setState(() {
      if (scrollRef != scrollController.offset) {
        scrollingState = ScrollingState(
            true,
            (scrollRef ?? 0) > scrollController.offset
                ? VerticalDirection.up
                : VerticalDirection.down);
        scrollRef = scrollController.offset;
        if (timer != null) timer.cancel();
        timer = Timer(
          aMillisecond * 50,
          () => setState(
            () => scrollingState = ScrollingState(
              !(scrollRef == scrollController.offset),
              (scrollRef ?? 0) > scrollController.offset
                  ? VerticalDirection.up
                  : VerticalDirection.down,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        semanticChildCount: items.length,
        controller: scrollController,
        slivers: <Widget>[
          _buildAppBar(textTheme),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              enumerate(items)
                  .map((item) => _ListItem(
                        title: item.value,
                        index: item.index,
                        color: colors[item.index],
                        scrollingState: scrollingState,
                      ))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(TextTheme textTheme) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      title: _AppName(),
      elevation: 0,
      expandedHeight: 192,
      flexibleSpace: Container(
        height: 192,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.cyan,
          Colors.white,
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      ),
    );
  }
}

class _AppName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Icon(
          Icons.wb_sunny,
          size: 36,
          color: Colors.orange,
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Kayaa',
            style: textTheme.display1.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  final int index;
  final ScrollingState scrollingState;
  final Matrix4 perspective = _pmat(1.0);
  final MaterialColor color;

  bool get isScrolling => scrollingState.scrolling;

  bool get isUp => scrollingState.direction == VerticalDirection.up;

  _ListItem({
    Key key,
    this.title,
    this.index,
    this.scrollingState,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final transform = perspective.scaled(1.0, 1.0, 1.0)
      ..rotateX(pi / 10 * (isUp ? -1 : 1))
      ..rotateY(0.0)
      ..rotateZ(0.0);

    final textTheme = Theme.of(context).accentTextTheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        onTap: () => _openDetails(context, size),
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(height: 130),
          child: Stack(
            children: <Widget>[
              Transform(
                transform:
                    isScrolling && !kIsWeb ? transform : Matrix4.rotationX(0),
                alignment: FractionalOffset.center,
                child: Hero(
                  tag: 'BG$index',
                  child: AnimatedContainer(
                    constraints: BoxConstraints.expand(),
                    color: isScrolling ? color.shade400 : color,
                    duration: aMillisecond * 100,
                  ),
                ),
              ),
              Transform.translate(
                  offset: Offset(size.width - 140, -10),
                  child: Hero(
                      tag: 'img$index', child: Image.asset('assets/mini.png'))),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '$title',
                    style: textTheme.title,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _openDetails(context, size) => Navigator.of(context).push(
        FadeRoute(
          page: DetailScreen(
            itemIndex: index,
            title: '$title',
            color: color,
            screenHeight: size.height,
          ),
        ),
      );
}
