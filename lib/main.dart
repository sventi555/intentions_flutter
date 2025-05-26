import 'package:flutter/material.dart';

void main() {
  runApp(const App());
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
      home: const Preview(),
    );
  }
}

class Preview extends StatelessWidget {
  const Preview({super.key});

  @override
  Widget build(BuildContext context) {
    return Home();
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.search)),
            Tab(icon: Icon(Icons.create)),
            Tab(icon: Icon(Icons.notifications)),
            Tab(icon: Icon(Icons.account_circle)),
          ],
        ),
        body: const TabBarView(
          children: [
            Feed(),
            Search(),
            Icon(Icons.create),
            Icon(Icons.notifications),
            Icon(Icons.account_circle),
          ],
        ),
      ),
    );
  }
}

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(children: [for (var _ in Iterable.generate(10)) Post()]);
  }
}

class Post extends StatelessWidget {
  const Post({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ProfilePic(),
                      SizedBox(width: 8),
                      Text("username"),
                    ],
                  ),
                  Text("1 day ago"),
                ],
              ),
              SizedBox(height: 8),
              Chip(label: Text("intention"), padding: EdgeInsets.all(0)),
            ],
          ),
        ),
        Image(
          image: NetworkImage("https://placehold.co/400/png"),
          fit: BoxFit.fill,
        ),
        Padding(padding: EdgeInsets.all(8), child: Text("description")),
      ],
    );
  }
}

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Search username",
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (var _ in Iterable.generate(10))
                  ListTile(leading: ProfilePic(), title: Text("username")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage("https://placehold.co/48/png"),
        ),
      ),
      width: 32,
      height: 32,
    );
  }
}
