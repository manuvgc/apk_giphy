import 'package:flutter/material.dart';

class GiphyPage extends StatelessWidget {
  final Map _gifData;
  const GiphyPage(this._gifData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('GIF', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Center(
        // antes estava "iamges" (typo), o que quebrava ao abrir o GIF
        child: Image.network(_gifData["images"]["original"]["url"]),
      ),
    );
  }
}
