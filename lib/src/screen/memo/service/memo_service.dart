import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:notepad/src/screen/memo/dto/memo_dto.dart';
import 'package:notepad/src/screen/memo/repository/database_helper.dart';

class MemoService {
  static MemoService? _instance;

  factory MemoService() => _instance ??= MemoService._init();

  MemoService._init() {}

  final String title = '';
  final String deleteId = '';

  Future<List<MemoDTO>> loadMemos() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    return await dbHelper.selectMemos();
  }

  Future<void> deleteMemo(String id) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    return await dbHelper.deleteMemo(id);
  }

  Future<List<MemoDTO>> loadMemo(String id) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    return await dbHelper.selectMemo(id);
  }

  Future<void> saveDB(String text) async {
    DatabaseHelper helper = DatabaseHelper();
    var memo = MemoDTO(
        id: convertStr2Sha512(DateTime.now().toString()),
        title: title,
        text: text,
        createdTime: DateTime.now().toString(),
        editedTime: DateTime.now().toString());

    await helper.insertMemo(memo);
    print('저장하기');
  }

  String convertStr2Sha512(String text) {
    var bytes = utf8.encode(text);
    var digest = sha512.convert(bytes);
    print('[SHA512] ORG : $text');
    print('[SHA512] HASH : $digest');

    return digest.toString();
  }
}
