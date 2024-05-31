import 'package:huwamemo/models/memo_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sqflite_repository.g.dart';

@Riverpod(keepAlive: true)
SqfliteRepository sqfliteRepository(
  SqfliteRepositoryRef ref,
) {
  // throw UnimplementedError();
  return SqfliteRepository.instance;
}

class SqfliteRepository {
  static const _databaseName = "sqflite_Database_dest1.db";
  static const _databaseVersion = 1;
  static const table = 'MemoTable';

  static const memoId = 'memo_id';
  static const content = 'content';
  static const color = 'color';
  static const description = 'description';
  static const finishDate = 'finish_date';
  static const createdAt = 'created_at';

  SqfliteRepository._();
  static final SqfliteRepository instance = SqfliteRepository._();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $memoId TEXT PRIMARY KEY,
            $content TEXT NOT NULL,
            $color TEXT NOT NULL,
            $description TEXT,
            $finishDate TEXT NOT NULL,
            $createdAt TEXT NOT NULL
          )
          ''');
  }

  Future<int> insertMemo(MemoModel memo) async {
    Database db = await instance.database;
    try {
      final row = memo.toJson();
      int result = await db.insert(
        table,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace, // 上書き
      );
      return result;
    } catch (e) {
      throw Exception('保存に失敗しました');
    }
  }

  Future<List<MemoModel>> loadAllMemos() async {
    try {
      Database db = await instance.database;
      List<Map<String, Object?>> loadData =
          await db.query(table, orderBy: '$createdAt DESC');
      if (loadData.isEmpty) {
        return [];
      }
      final List<MemoModel> allData = loadData.map((e) {
        return MemoModel.fromJson(e);
      }).toList();
      return allData;
    } catch (e) {
      throw Exception('ロードに失敗しました');
    }
  }

  Future<MemoModel?> findById(String id) async {
    try {
      Database db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        table,
        where: '$memoId = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return MemoModel.fromJson(maps.first);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> updateMemo(MemoModel memo) async {
    try {
      Database db = await instance.database;
      await db.update(
        table,
        memo.toJson(),
        where: '$memoId = ?',
        whereArgs: [memo.memoId],
      );
    } catch (e) {
      throw Exception('更新に失敗しました');
    }
  }

  Future<void> deleteMemoById(String id) async {
    try {
      Database db = await instance.database;
      await db.delete(
        table,
        where: '$memoId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('削除に失敗しました');
    }
  }
}
