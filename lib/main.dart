import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:word_app/databaseConfig.dart';
import 'package:word_app/word.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();

  final DatabaseService _databaseService = DatabaseService();

  Future<List<Word>> _wordList = DatabaseService()
      .databaseConfig()
      .then((_) => DatabaseService().selectWords());

  int currentCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter App"),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => addWordDialog(),
        );
      }),
      body: Container(
        child: FutureBuilder(
          future: _wordList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              currentCount = snapshot.data!.length;
              if (currentCount == 0) {
                return const Center(
                  child: Text("No data exists."),
                );
              } else {
                return ListView.builder(
                  itemCount: currentCount,
                  itemBuilder: (context, index) {
                    return wordBox(
                      snapshot.data![index].id,
                      snapshot.data![index].name,
                      snapshot.data![index].meaning,
                    );
                  },
                );
              }
            } else if (snapshot.hasError) {
              return const Center(
                child: Text("error occured"),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget wordBox(int id, String name, String meaning) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          child: Text("$id"),
        ),
        Container(
          padding: const EdgeInsets.all(15),
          child: Text(name),
        ),
        Container(
          padding: const EdgeInsets.all(15),
          child: Text(meaning),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              updateButton(id),
              const SizedBox(width: 10),
              deleteButton(id),
            ],
          ),
        ),
      ],
    );
  }

  Widget updateButton(int id) {
    return ElevatedButton(
      onPressed: () {
        Future<Word> word = _databaseService.selectWord(id);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => updateWordDialog(),
        );
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.green),
      ),
      child: const Icon(Icons.edit),
    );
  }

  Widget deleteButton(int id) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => deleteWordDialog(id),
        );
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.red),
      ),
      child: const Icon(Icons.delete),
    );
  }

  Widget addWordDialog() {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("단어 추가"),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: "단어를 입력하세요"),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _meaningController,
            decoration: const InputDecoration(hintText: "뜻을 입력하세요"),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              _databaseService
                  .insertWord(Word(
                      id: currentCount + 1,
                      name: _nameController.text,
                      meaning: _meaningController.text))
                  .then((result) {
                if (result) {
                  Navigator.of(context).pop();
                  setState(() {
                    _wordList = _databaseService.selectWords();
                  });
                } else {
                  print("insert error");
                }
              });
            },
            child: const Text("생성"),
          ),
        ],
      ),
    );
  }

  Widget updateWord(Future<Word> word) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("단어 수정"),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: FutureBuilder(
        future: word,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _nameController.text = snapshot.data!.name;
            _meaningController.text = snapshot.data!.meaning;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: "단어를 입력하세요"),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _meaningController,
                  decoration: const InputDecoration(hintText: "뜻을 입력하세요"),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    _databaseService
                        .updateWord(Word(
                            id: snapshot.data!.id,
                            name: _nameController.text,
                            meaning: _meaningController.text))
                        .then((result) {
                      if (result) {
                        Navigator.of(context).pop();
                        setState(() {
                          _wordList = _databaseService.selectWords();
                        });
                      } else {
                        print("update error");
                      }
                    });
                  },
                  child: const Text("수정"),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("error occured"),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }
        },
      ),
    );
  }
}
