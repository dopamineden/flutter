// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

Key firstKey = const Key('first');
Key secondKey = const Key('second');
Key thirdKey = const Key('third');

Key homeRouteKey = const Key('homeRoute');
Key routeTwoKey = const Key('routeTwo');
Key routeThreeKey = const Key('routeThree');

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  '/': (BuildContext context) => new Material(
    child: new ListView(
      key: homeRouteKey,
      children: <Widget>[
        new Container(height: 100.0, width: 100.0),
        new Card(child: new Hero(tag: 'a', child: new Container(height: 100.0, width: 100.0, key: firstKey))),
        new Container(height: 100.0, width: 100.0),
        new FlatButton(
          child: new Text('two'),
          onPressed: () { Navigator.pushNamed(context, '/two'); }
        ),
      ]
    )
  ),
  '/two': (BuildContext context) => new Material(
    child: new ListView(
      key: routeTwoKey,
      children: <Widget>[
        new FlatButton(
          child: new Text('pop'),
          onPressed: () { Navigator.pop(context); }
        ),
        new Container(height: 150.0, width: 150.0),
        new Card(child: new Hero(tag: 'a', child: new Container(height: 150.0, width: 150.0, key: secondKey))),
        new Container(height: 150.0, width: 150.0),
        new FlatButton(
          child: new Text('three'),
          onPressed: () { Navigator.push(context, new ThreeRoute()); },
        ),
      ]
    )
  ),
};

class ThreeRoute extends MaterialPageRoute<Null> {
  ThreeRoute() : super(builder: (BuildContext context) {
    return new Material(
      key: routeThreeKey,
      child: new ListView(
        children: <Widget>[
          new Container(height: 200.0, width: 200.0),
          new Card(child: new Hero(tag: 'a', child: new Container(height: 200.0, width: 200.0, key: thirdKey))),
          new Container(height: 200.0, width: 200.0),
        ]
      )
    );
  });
}

class MutatingRoute extends MaterialPageRoute<Null> {
  MutatingRoute() : super(builder: (BuildContext context) {
    return new Hero(tag: 'a', child: new Text('MutatingRoute'), key: new UniqueKey());
  });

  void markNeedsBuild() {
    setState(() {
      // Trigger a rebuild
    });
  }
}

void main() {
  testWidgets('Heroes animate', (WidgetTester tester) async {

    await tester.pumpWidget(new MaterialApp(routes: routes));

    // the initial setup.

    expect(find.byKey(firstKey), isOnstage);
    expect(find.byKey(firstKey), isInCard);
    expect(find.byKey(secondKey), findsNothing);

    await tester.tap(find.text('two'));
    await tester.pump(); // begin navigation

    // at this stage, the second route is offstage, so that we can form the
    // hero party.

    expect(find.byKey(firstKey), isOnstage);
    expect(find.byKey(firstKey), isInCard);
    expect(find.byKey(secondKey, skipOffstage: false), isOffstage);
    expect(find.byKey(secondKey, skipOffstage: false), isInCard);

    await tester.pump();

    // at this stage, the heroes have just gone on their journey, we are
    // seeing them at t=16ms. The original page no longer contains the hero.

    expect(find.byKey(firstKey), findsNothing);
    expect(find.byKey(secondKey), isOnstage);
    expect(find.byKey(secondKey), isNotInCard);

    await tester.pump();

    // t=32ms for the journey. Surely they are still at it.

    expect(find.byKey(firstKey), findsNothing);
    expect(find.byKey(secondKey), isOnstage);
    expect(find.byKey(secondKey), isNotInCard);

    await tester.pump(const Duration(seconds: 1));

    // t=1.032s for the journey. The journey has ended (it ends this frame, in
    // fact). The hero should now be in the new page, onstage. The original
    // widget will be back as well now (though not visible).

    expect(find.byKey(firstKey), findsNothing);
    expect(find.byKey(secondKey), isOnstage);
    expect(find.byKey(secondKey), isInCard);

    await tester.pump();

    // Should not change anything.

    expect(find.byKey(firstKey), findsNothing);
    expect(find.byKey(secondKey), isOnstage);
    expect(find.byKey(secondKey), isInCard);

    // Now move on to view 3

    await tester.tap(find.text('three'));
    await tester.pump(); // begin navigation

    // at this stage, the second route is offstage, so that we can form the
    // hero party.

    expect(find.byKey(secondKey), isOnstage);
    expect(find.byKey(secondKey), isInCard);
    expect(find.byKey(thirdKey, skipOffstage: false), isOffstage);
    expect(find.byKey(thirdKey, skipOffstage: false), isInCard);

    await tester.pump();

    // at this stage, the heroes have just gone on their journey, we are
    // seeing them at t=16ms. The original page no longer contains the hero.

    expect(find.byKey(secondKey), findsNothing);
    expect(find.byKey(thirdKey), isOnstage);
    expect(find.byKey(thirdKey), isNotInCard);

    await tester.pump();

    // t=32ms for the journey. Surely they are still at it.

    expect(find.byKey(secondKey), findsNothing);
    expect(find.byKey(thirdKey), isOnstage);
    expect(find.byKey(thirdKey), isNotInCard);

    await tester.pump(const Duration(seconds: 1));

    // t=1.032s for the journey. The journey has ended (it ends this frame, in
    // fact). The hero should now be in the new page, onstage.

    expect(find.byKey(secondKey), findsNothing);
    expect(find.byKey(thirdKey), isOnstage);
    expect(find.byKey(thirdKey), isInCard);

    await tester.pump();

    // Should not change anything.

    expect(find.byKey(secondKey), findsNothing);
    expect(find.byKey(thirdKey), isOnstage);
    expect(find.byKey(thirdKey), isInCard);
  });

  testWidgets('Heroes animate', (WidgetTester tester) async {
    final MutatingRoute route = new MutatingRoute();

    await tester.pumpWidget(new MaterialApp(
      home: new Material(
        child: new ListView(
          children: <Widget>[
            new Hero(tag: 'a', child: new Text('foo')),
            new Builder(builder: (BuildContext context) {
              return new FlatButton(child: new Text('two'), onPressed: () => Navigator.push(context, route));
            })
          ]
        )
      )
    ));

    await tester.tap(find.text('two'));
    await tester.pump(const Duration(milliseconds: 10));

    route.markNeedsBuild();

    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Heroes animation is fastOutSlowIn', (WidgetTester tester) async {
    await tester.pumpWidget(new MaterialApp(routes: routes));
    await tester.tap(find.text('two'));
    await tester.pump(); // begin navigation

    // Expect the height of the secondKey Hero to vary from 100 to 150
    // over duration and according to curve.

    final Duration duration = const Duration(milliseconds: 300);
    final Curve curve = Curves.fastOutSlowIn;
    final double initialHeight = tester.getSize(find.byKey(firstKey, skipOffstage: false)).height;
    final double finalHeight = tester.getSize(find.byKey(secondKey, skipOffstage: false)).height;
    final double deltaHeight = finalHeight - initialHeight;
    final double epsilon = 0.001;

    await tester.pump(duration * 0.25);
    expect(
      tester.getSize(find.byKey(secondKey)).height,
      closeTo(curve.transform(0.25) * deltaHeight + initialHeight, epsilon)
    );

    await tester.pump(duration * 0.25);
    expect(
      tester.getSize(find.byKey(secondKey)).height,
      closeTo(curve.transform(0.50) * deltaHeight + initialHeight, epsilon)
    );

    await tester.pump(duration * 0.25);
    expect(
      tester.getSize(find.byKey(secondKey)).height,
      closeTo(curve.transform(0.75) * deltaHeight + initialHeight, epsilon)
    );

    await tester.pump(duration * 0.25);
    expect(
      tester.getSize(find.byKey(secondKey)).height,
      closeTo(curve.transform(1.0) * deltaHeight + initialHeight, epsilon)
    );
  });

  testWidgets('Heroes are not interactive', (WidgetTester tester) async {
    final List<String> log = <String>[];

    await tester.pumpWidget(new MaterialApp(
      home: new Center(
        child: new Hero(
          tag: 'foo',
          child: new GestureDetector(
            onTap: () {
              log.add('foo');
            },
            child: new Container(
              width: 100.0,
              height: 100.0,
              child: new Text('foo')
            )
          )
        )
      ),
      routes: <String, WidgetBuilder>{
        '/next': (BuildContext context) {
          return new Align(
            alignment: FractionalOffset.topLeft,
            child: new Hero(
              tag: 'foo',
              child: new GestureDetector(
                onTap: () {
                  log.add('bar');
                },
                child: new Container(
                  width: 100.0,
                  height: 150.0,
                  child: new Text('bar')
                )
              )
            )
          );
        }
      }
    ));

    expect(log, isEmpty);
    await tester.tap(find.text('foo'));
    expect(log, equals(<String>['foo']));
    log.clear();

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.pushNamed('/next');

    expect(log, isEmpty);
    await tester.tap(find.text('foo', skipOffstage: false));
    expect(log, isEmpty);

    await tester.pump(const Duration(milliseconds: 10));
    await tester.tap(find.text('foo', skipOffstage: false));
    expect(log, isEmpty);
    await tester.tap(find.text('bar', skipOffstage: false));
    expect(log, isEmpty);

    await tester.pump(const Duration(milliseconds: 10));
    expect(find.text('foo'), findsNothing);
    await tester.tap(find.text('bar', skipOffstage: false));
    expect(log, isEmpty);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('foo'), findsNothing);
    await tester.tap(find.text('bar'));
    expect(log, equals(<String>['bar']));
  });

  testWidgets('Popping on first frame does not cause hero observer to crash', (WidgetTester tester) async {
    await tester.pumpWidget(new MaterialApp(
      onGenerateRoute: (RouteSettings settings) {
        return new MaterialPageRoute<Null>(
          settings: settings,
          builder: (BuildContext context) => new Hero(tag: 'test', child: new Container()),
        );
      },
    ));
    await tester.pump();

    final Finder heroes = find.byType(Hero);
    expect(heroes, findsOneWidget);

    Navigator.pushNamed(heroes.evaluate().first, 'test');
    await tester.pump(); // adds the new page to the tree...

    Navigator.pop(heroes.evaluate().first);
    await tester.pump(); // ...and removes it straight away (since it's already at 0.0)

    // this is verifying that there's no crash

    // TODO(ianh): once https://github.com/flutter/flutter/issues/5631 is fixed, remove this line:
    await tester.pump(const Duration(hours: 1));
  });

  testWidgets('Overlapping starting and ending a hero transition works ok', (WidgetTester tester) async {
    await tester.pumpWidget(new MaterialApp(
      onGenerateRoute: (RouteSettings settings) {
        return new MaterialPageRoute<Null>(
          settings: settings,
          builder: (BuildContext context) => new Hero(tag: 'test', child: new Container()),
        );
      },
    ));
    await tester.pump();

    final Finder heroes = find.byType(Hero);
    expect(heroes, findsOneWidget);

    Navigator.pushNamed(heroes.evaluate().first, 'test');
    await tester.pump();
    await tester.pump(const Duration(hours: 1));

    Navigator.pushNamed(heroes.evaluate().first, 'test');
    await tester.pump();
    await tester.pump(const Duration(hours: 1));

    Navigator.pop(heroes.evaluate().first);
    await tester.pump();
    Navigator.pop(heroes.evaluate().first);
    await tester.pump(const Duration(hours: 1)); // so the first transition is finished, but the second hasn't started
    await tester.pump();

    // this is verifying that there's no crash

    // TODO(ianh): once https://github.com/flutter/flutter/issues/5631 is fixed, remove this line:
    await tester.pump(const Duration(hours: 1));
  });

  testWidgets('One route, two heroes, same tag, throws', (WidgetTester tester) async {
    await tester.pumpWidget(new MaterialApp(
      home: new Material(
        child: new ListView(
          children: <Widget>[
            new Hero(tag: 'a', child: new Text('a')),
            new Hero(tag: 'a', child: new Text('a too')),
            new Builder(
              builder: (BuildContext context) {
                return new FlatButton(
                  child: new Text('push'),
                  onPressed: () {
                    Navigator.push(context, new PageRouteBuilder<Null>(
                      pageBuilder: (BuildContext context, Animation<double> _, Animation<double> __) {
                        return new Text('fail');
                      },
                    ));
                  },
                );
              },
            ),
          ],
        ),
      ),
    ));

    await tester.tap(find.text('push'));
    await tester.pump();
    expect(tester.takeException(), isFlutterError);
  });

  testWidgets('Hero push transition interrupted by a pop', (WidgetTester tester) async {
    await tester.pumpWidget(new MaterialApp(
      routes: routes
    ));

    // Initially the firstKey Card on the '/' route is visible
    expect(find.byKey(firstKey), isOnstage);
    expect(find.byKey(firstKey), isInCard);
    expect(find.byKey(secondKey), findsNothing);

    // Pushes MaterialPageRoute '/two'.
    await tester.tap(find.text('two'));

    // Start the flight of Hero 'a' from route '/' to route '/two'. Route '/two'
    // is now offstage.
    await tester.pump();

    final double initialHeight = tester.getSize(find.byKey(firstKey)).height;
    final double finalHeight = tester.getSize(find.byKey(secondKey, skipOffstage: false)).height;
    expect(finalHeight, greaterThan(initialHeight)); // simplify the checks below

    // Build the first hero animation frame in the navigator's overlay.
    await tester.pump();

    // At this point the hero widgets have been replaced by placeholders
    // and the destination hero has been moved to the overlay.
    expect(find.descendant(of: find.byKey(homeRouteKey), matching: find.byKey(firstKey)), findsNothing);
    expect(find.descendant(of: find.byKey(routeTwoKey), matching: find.byKey(secondKey)), findsNothing);
    expect(find.byKey(firstKey), findsNothing);
    expect(find.byKey(secondKey), isOnstage);

    // The duration of a MaterialPageRoute's transition is 300ms.
    // At 150ms Hero 'a' is mid-flight.
    await tester.pump(const Duration(milliseconds: 150));
    final double height150ms = tester.getSize(find.byKey(secondKey)).height;
    expect(height150ms, greaterThan(initialHeight));
    expect(height150ms, lessThan(finalHeight));

    // Pop route '/two' before the push transition to '/two' has finished.
    await tester.tap(find.text('pop'));

    // Restart the flight of Hero 'a'. Now it's flying from route '/two' to
    // route '/'.
    await tester.pump();

    // After flying in the opposite direction for 50ms Hero 'a' will
    // be smaller than it was, but bigger than its initial size.
    await tester.pump(const Duration(milliseconds: 50));
    final double height100ms = tester.getSize(find.byKey(secondKey)).height;
    expect(height100ms, lessThan(height150ms));
    expect(finalHeight, greaterThan(height100ms));

    // Hero a's return flight at 149ms. The outgoing (push) flight took
    // 150ms so we should be just about back to where Hero 'a' started.
    final double epsilon = 0.001;
    await tester.pump(const Duration(milliseconds: 99));
    closeTo(tester.getSize(find.byKey(secondKey)).height - initialHeight, epsilon);

    // The flight is finished. We're back to where we started.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(firstKey), isOnstage);
    expect(find.byKey(firstKey), isInCard);
    expect(find.byKey(secondKey), findsNothing);
  });

  testWidgets('Hero pop transition interrupted by a push', (WidgetTester tester) async {
    await tester.pumpWidget(
      new MaterialApp(routes: routes)
    );

    // Pushes MaterialPageRoute '/two'.
    await tester.tap(find.text('two'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Now the secondKey Card on the '/2' route is visible
    expect(find.byKey(secondKey), isOnstage);
    expect(find.byKey(secondKey), isInCard);
    expect(find.byKey(firstKey), findsNothing);

    // Pop MaterialPageRoute '/two'.
    await tester.tap(find.text('pop'));

    // Start the flight of Hero 'a' from route '/two' to route '/'. Route '/two'
    // is now offstage.
    await tester.pump();

    final double initialHeight = tester.getSize(find.byKey(secondKey)).height;
    final double finalHeight = tester.getSize(find.byKey(firstKey, skipOffstage: false)).height;
    expect(finalHeight, lessThan(initialHeight)); // simplify the checks below

    // Build the first hero animation frame in the navigator's overlay.
    await tester.pump();

    // At this point the hero widgets have been replaced by placeholders
    // and the destination hero has been moved to the overlay.
    expect(find.descendant(of: find.byKey(homeRouteKey), matching: find.byKey(firstKey)), findsNothing);
    expect(find.descendant(of: find.byKey(routeTwoKey), matching: find.byKey(secondKey)), findsNothing);
    expect(find.byKey(firstKey), isOnstage);
    expect(find.byKey(secondKey), findsNothing);

    // The duration of a MaterialPageRoute's transition is 300ms.
    // At 150ms Hero 'a' is mid-flight.
    await tester.pump(const Duration(milliseconds: 150));
    final double height150ms = tester.getSize(find.byKey(firstKey)).height;
    expect(height150ms, lessThan(initialHeight));
    expect(height150ms, greaterThan(finalHeight));

    // Push route '/two' before the pop transition from '/two' has finished.
    await tester.tap(find.text('two'));

    // Restart the flight of Hero 'a'. Now it's flying from route '/' to
    // route '/two'.
    await tester.pump();

    // After flying in the opposite direction for 50ms Hero 'a' will
    // be smaller than it was, but bigger than its initial size.
    await tester.pump(const Duration(milliseconds: 50));
    final double height100ms = tester.getSize(find.byKey(firstKey)).height;
    expect(height100ms, greaterThan(height150ms));
    expect(finalHeight, lessThan(height100ms));

    // Hero a's return flight at 149ms. The outgoing (push) flight took
    // 150ms so we should be just about back to where Hero 'a' started.
    final double epsilon = 0.001;
    await tester.pump(const Duration(milliseconds: 99));
    closeTo(tester.getSize(find.byKey(firstKey)).height - initialHeight, epsilon);

    // The flight is finished. We're back to where we started.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(secondKey), isOnstage);
    expect(find.byKey(secondKey), isInCard);
    expect(find.byKey(firstKey), findsNothing);
  });
}
