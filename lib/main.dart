import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentions_flutter/firebase.dart';
import 'package:intentions_flutter/pages/create/post.dart';
import 'package:intentions_flutter/pages/feed.dart';
import 'package:intentions_flutter/pages/notifications.dart';
import 'package:intentions_flutter/pages/profile.dart';
import 'package:intentions_flutter/pages/search.dart';

void main() async {
  await firebase.init();

  runApp(ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intentions',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        bottomNavigationBar: SafeArea(top: false, child: HomeTabBar()),
        body: SafeArea(
          bottom: false,
          child: TabBarView(
            children: [
              FeedTab(),
              SearchTab(),
              CreateTab(),
              NotificationsTab(),
              ProfileTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTabBar extends ConsumerWidget {
  const HomeTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedRouter = ref.watch(feedRouterProvider);
    final searchRouter = ref.watch(searchRouterProvider);
    final createRouter = ref.watch(createRouterProvider);
    final notificationsRouter = ref.watch(notificationsRouterProvider);
    final profileRouter = ref.watch(profileRouterProvider);

    return TabBar(
      onTap: (tabIndex) {
        final changingTab = DefaultTabController.of(context).indexIsChanging;

        if (!changingTab) {
          switch (tabIndex) {
            case 0:
              feedRouter.goNamed('/');
            case 1:
              searchRouter.goNamed('/');
            case 2:
              createRouter.goNamed('/');
            case 3:
              notificationsRouter.goNamed('/');
            case 4:
              profileRouter.goNamed('/');
          }
        }
      },
      tabs: [
        Tab(icon: Icon(Icons.home)),
        Tab(icon: Icon(Icons.search)),
        Tab(icon: Icon(Icons.create)),
        Tab(icon: Icon(Icons.notifications)),
        Tab(icon: Icon(Icons.account_circle)),
      ],
    );
  }
}
