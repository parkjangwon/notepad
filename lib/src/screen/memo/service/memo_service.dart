import 'package:notepad/src/screen/memo/dto/memo_dto.dart';
import 'package:notepad/src/screen/memo/repository/database_helper.dart';
import 'package:notepad/src/screen/memo/util/encrypt.dart';

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
}
