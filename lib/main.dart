import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_memo_app/edit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memo App',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: MemoList(),
    );
  }
}

class MemoList extends StatefulWidget {
  @override
  MemoListState createState() => MemoListState();
}

class MemoListState extends State<MemoList> {

  // var _memoList = new List<String>();
  List<String> _memoList = [];

  int _currentIndex = -1;
  bool _loading = true;

  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    this.loadMemoList();
  }

  @override
  Widget build(BuildContext context) {
    final title = "Home";
    if (_loading) {
      return Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _buildList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMemo,
        tooltip: 'New Memo',
        child: Icon(Icons.add),
      ),
    );
  }

  void loadMemoList() {
    SharedPreferences.getInstance().then((prefs) {
      const key = 'memo-list';
      if (prefs.containsKey(key)) {
        _memoList = prefs.getStringList(key) ?? [];
      }
      setState(() {
        _loading = false;
      });
    });
  }

  void _addMemo() {
    debugPrint("_addMemo");

    setState(() {
      _memoList.add("");
      _currentIndex = _memoList.length - 1;
      storeMemoList();
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Edit(_memoList[_currentIndex], _onChanged);
        },
      ));
    });
  }

  void _onChanged(String text) {
    debugPrint("_onChanged");

    setState(() {
      _memoList[_currentIndex] = text;
      storeMemoList();
    });
  }

  void storeMemoList() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'memo-list';
    final success = await prefs.setStringList(key, _memoList);
    if (!success) {
      debugPrint("Failed to store value");
    }
  }

  Widget _buildList() {
    final itemCount = _memoList.length == 0 ? 0 : _memoList.length * 2 - 1;
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      // padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
      itemCount: itemCount,
      itemBuilder: /*1*/ (context, i) {
        if (i.isOdd) return Divider(height: 2);
        final index = (i / 2).floor();
        final memo = _memoList[index];
        final m = memo == "" ? "[Empty]" : memo;
        return _buildWrappedRow(m, index);
      }
    );
  }

  Widget _buildWrappedRow(String content, int index) {
    return Dismissible(
      background: Container(color: Colors.red),
      key: Key(content),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _memoList.removeAt(index);
          storeMemoList();
        });
      },
      child: _buildRow(content, index),
    );
  }

  Widget _buildRow(String content, int index) {
    return ListTile(
      title: Text(
        content,
        style: _biggerFont,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        _currentIndex = index;
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (BuildContext context) {
          return new Edit(_memoList[_currentIndex], _onChanged);
        }));
      },
    );
  }

}