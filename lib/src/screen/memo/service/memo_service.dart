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
}
