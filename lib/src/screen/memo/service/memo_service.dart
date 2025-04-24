import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:notepad/src/screen/memo/dto/memo_dto.dart';
import 'package:notepad/src/screen/memo/repository/database_helper.dart';
import 'package:notepad/src/screen/memo/util/encrypt.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class MemoService {
  static MemoService? _instance;

  factory MemoService() => _instance ??= MemoService._init();

  MemoService._init() {}

  DatabaseHelper dbHelper = DatabaseHelper();

  Future<List<MemoDTO>> loadMemos() async {
    return await dbHelper.selectMemos();
  }

  Future<List<MemoDTO>> loadMemo(String id) async {
    return await dbHelper.selectMemo(id);
  }

  Future<void> deleteMemo(String id) async {
    return await dbHelper.deleteMemo(id);
  }

  Future<void> updateMemo(MemoDTO memo) async {
    return await dbHelper.updateMemo(memo);
  }

  Future<void> saveDB(String title, String text) async {
    var memo = MemoDTO(
      id: Encrypt.convertStr2Sha512(DateTime.now().toString()),
      title: title,
      text: text,
      createdTime: DateTime.now().toString(),
      editedTime: DateTime.now().toString(),
    );

    await dbHelper.insertMemo(memo);
  }

  backupDB() async {
    final dbFolder = await getDatabasesPath();
    File source1 = File('$dbFolder/memos.db');

    // TODO 현재는 안드로이드만 지원
    Directory copyTo = Directory("storage/emulated/0/Download/");
    if ((await copyTo.exists())) {
      // print("Path exist");
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    } else {
      if (await Permission.storage.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
        await copyTo.create();
      }
    }

    String newPath = "${copyTo.path}/memos.db";
    await source1.copy(newPath);
  }

  restoreDB() async {
    var databasesPath = await getDatabasesPath();
    var dbPath = join(databasesPath, 'memos.db');

    final typeGroup = XTypeGroup(
      label: 'databases',
      extensions: ['db'],
    );
    
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      if (file.name == 'memos.db') {
        File source = File(file.path);
        await source.copy(dbPath);
      } else {
        print('잘못된 파일입니다.');
      }
    }
  }
}
