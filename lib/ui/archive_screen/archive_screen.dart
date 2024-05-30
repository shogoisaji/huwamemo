import 'package:flutter/material.dart';
import 'package:huwamemo/models/memo_model.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memos = <MemoModel>[];
    return Scaffold(
      appBar: AppBar(
        title: const Text('アーカイブ'),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          itemCount: memos.length,
          itemBuilder: (context, index) => Card(
            child: ListTile(
              title: Text(memos[index].content),
            ),
          ),
        ),
      ),
    );
  }
}
