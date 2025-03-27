import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

// --- 메인 페이지 ---
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        final NavigatorState? currentNavigator =
            _navigatorKeys[_currentIndex].currentState;
        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
        } else {
          if (_currentIndex != 0) {
            setState(() {
              _currentIndex = 0;
            });
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: <Widget>[
            // 각 탭에 대해 Navigator 위젯 생성
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          ],
        ),
      ),
    );
  }

  // 각 탭의 Navigator를 생성하는 메소드
  Widget _buildOffstageNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index], // PopScope에서 참조하기 위해 Key는 필수
      // onGenerateRoute는 초기 라우트('/')만 처리하도록 단순화
      onGenerateRoute: (routeSettings) {
        WidgetBuilder builder;
        switch (routeSettings.name) {
          case '/':
            // 각 탭의 루트 화면 반환
            builder = (BuildContext _) => TabRootScreen(tabIndex: index);
            break;
          default:
            // 혹시 모를 예외 처리 (기본적으로 '/'만 사용됨)
            builder =
                (BuildContext _) =>
                    Center(child: Text('Unknown route: ${routeSettings.name}'));
        }
        return MaterialPageRoute<dynamic>(
          builder: builder,
          settings: routeSettings,
        );
      },
    );
  }

  // _push 메소드는 제거됨
}

// --- 각 탭의 루트 화면 예시 (TabRootScreen) ---
class TabRootScreen extends StatelessWidget {
  final int tabIndex;

  const TabRootScreen({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    // Return SecondPage directly if tabIndex is 1
    if (tabIndex == 1) {
      return const SecondPage();
    }

    // Original code for tab 0
    final nestedNavigator = Navigator.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'First Tab',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tab $tabIndex Root Screen'),
            ElevatedButton(
              onPressed: () {
                nestedNavigator.push(
                  MaterialPageRoute(
                    builder:
                        (context) => DetailScreen(
                          detailId: 123 + tabIndex,
                          tabIndex: tabIndex,
                        ),
                  ),
                );
              },
              child: const Text('Go to Details (Push)'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 상세 화면 예시 (DetailScreen) ---
class DetailScreen extends StatelessWidget {
  final int detailId;
  final int tabIndex;

  const DetailScreen({
    super.key,
    required this.detailId,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    final nestedNavigator = Navigator.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tab $tabIndex Details'),
        //automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Detail Screen for ID: $detailId'),
            ElevatedButton(
              onPressed: () {
                // 현재 탭의 Navigator에서 pop
                nestedNavigator.pop();
              },
              child: Text('Go Back'),
            ),
            // 예시: 상세 화면에서 또 다른 화면으로 push
            ElevatedButton(
              onPressed: () {
                nestedNavigator.push(
                  MaterialPageRoute(
                    builder: (context) => AnotherScreen(tabIndex: tabIndex),
                  ),
                );
              },
              child: Text('Go Deeper'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 또 다른 화면 예시 ---
class AnotherScreen extends StatelessWidget {
  final int tabIndex;
  const AnotherScreen({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tab $tabIndex Another Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is another screen'),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Second Tab',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is the Second Tab'),
            ElevatedButton(
              onPressed: () {
                // Use Navigator.of(context, rootNavigator: true) to get the root navigator
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    //fullscreenDialog: true,
                    builder:
                        (context) =>
                            const DetailScreen(detailId: 123, tabIndex: 1),
                  ),
                );
              },
              child: const Text('Open Full Screen Page'),
            ),
          ],
        ),
      ),
    );
  }
}
