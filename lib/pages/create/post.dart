import 'package:flutter/material.dart';
import 'package:intentions_flutter/pages/create/intention.dart';

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
    return Container(
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
