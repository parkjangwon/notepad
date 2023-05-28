import 'package:notepad/src/screen/memo/dto/memo_dto.dart';
import 'package:notepad/src/screen/memo/repository/database_helper.dart';
import 'package:notepad/src/screen/memo/util/encrypt.dart';

class MemoService {
  static MemoService? _instance;

  factory MemoService() => _instance ??= MemoService._init();

  MemoService._init() {}

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

  Future<void> saveDB(String title, String text) async {
    DatabaseHelper helper = DatabaseHelper();
    var memo = MemoDTO(
        id: Encrypt.convertStr2Sha512(DateTime.now().toString()),
        title: title,
        text: text,
        createdTime: DateTime.now().toString(),
        editedTime: DateTime.now().toString());

    await helper.insertMemo(memo);
    print('저장하기');
  }
}
