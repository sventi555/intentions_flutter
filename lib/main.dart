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
      child: SafeArea(
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
              CreateTab(),
              Notifications(),
              Icon(Icons.account_circle),
            ],
          ),
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

class CreateTab extends StatelessWidget {
  const CreateTab({super.key});

  @override
  Widget build(BuildContext build) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => CreatePost()),
    );
  }
}

class CreatePost extends StatelessWidget {
  const CreatePost({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              DropdownMenu<String>(
                dropdownMenuEntries: [
                  for (var i in Iterable.generate(5))
                    DropdownMenuEntry<String>(
                      label: "intention $i",
                      value: "intention $i",
                    ),
                ],
                label: Text("Select an intention"),
              ),
              SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateIntention(),
                    ),
                  ),
                },
              ),
            ],
          ),
          GestureDetector(
            onTap: () => {},
            child: Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Icon(Icons.add_photo_alternate, size: 64),
                  Text("Select an image"),
                ],
              ),
            ),
          ),
          TextField(
            maxLines: null,
            minLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "description",
              alignLabelWithHint: true,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Text("Discard"),
                  onPressed: () => {},
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: FilledButton(child: Text("Post"), onPressed: () => {}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CreateIntention extends StatelessWidget {
  const CreateIntention({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hint: Text("e.g. touch grass"),
            ),
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => {Navigator.of(context).pop()},
                  style: FilledButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text("Cancel"),
                ),
              ),
              Expanded(
                child: FilledButton(onPressed: () => {}, child: Text("Create")),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (var _ in Iterable.generate(5))
          ListTile(
            title: Text("user requested to follow you"),
            leading: ProfilePic(),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.check), onPressed: () => {}),
                IconButton(icon: Icon(Icons.close), onPressed: () => {}),
              ],
            ),
          ),
      ],
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
