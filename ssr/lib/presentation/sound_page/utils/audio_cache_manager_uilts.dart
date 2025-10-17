import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioCacheManager {
  static final AudioCacheManager _instance = AudioCacheManager._internal();
  factory AudioCacheManager() => _instance;
  AudioCacheManager._internal();

  final Dio dio = Dio();
  late Directory _cacheDir;
  late File _indexFile;
  Map<String, dynamic> _index = {};
  final int partSize = 1 * 1024 * 1024; // 默认 1MB 分块

  // 初始化
  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    final parentDir = appDir.parent;
    _cacheDir = Directory(p.join(parentDir.path, "cache", "audio_cache"));
    if (!(await _cacheDir.exists())) await _cacheDir.create(recursive: true);

    _indexFile = File("${_cacheDir.path}/cache_index.json");
    if (await _indexFile.exists()) {
      try {
        _index = jsonDecode(await _indexFile.readAsString());
      } catch (_) {
        _index = {};
      }
    }
  }

  String _hash(String url) => url.hashCode.toString();

  Future<void> _saveIndex() async {
    await _indexFile.writeAsString(jsonEncode(_index));
  }

  // ========== 主入口：分段缓存音频（支持断点续传） ==========
  Future<File> cacheAudio(
    String url, {
    void Function(double)? onProgress,
  }) async {
    final dir = Directory(p.join(_cacheDir.path, _hash(url)));
    if (!await dir.exists()) await dir.create(recursive: true);

    final metaFile = File(p.join(dir.path, "meta.json"));
    Map<String, dynamic> meta = await _loadMeta(metaFile, url);
    List<int> downloadedParts = List<int>.from(meta["downloaded_parts"]);

    // 获取总大小
    final head = await dio.head(url);
    final totalSize = int.parse(head.headers.value('content-length') ?? '0');
    meta["total_size"] = totalSize;
    final totalParts = (totalSize / partSize).ceil();

    // 下载每个分段
    for (int i = 0; i < totalParts; i++) {
      if (downloadedParts.contains(i)) continue;

      final start = i * partSize;
      final end = ((i + 1) * partSize) - 1;
      final partFile = File(p.join(dir.path, "part_$i.tmp"));

      try {
        final res = await dio.get<List<int>>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {"Range": "bytes=$start-$end"},
          ),
        );

        await partFile.writeAsBytes(res.data!);
        downloadedParts.add(i);
        meta["downloaded_parts"] = downloadedParts;
        await metaFile.writeAsString(jsonEncode(meta));

        if (onProgress != null) {
          onProgress(downloadedParts.length / totalParts);
        }
      } catch (e) {
        print("❌ 分段 $i 下载失败: $e");
      }
    }

    // 合并所有分段
    final fullFile = File(p.join(dir.path, "full.mp3"));
    final sink = fullFile.openWrite();
    for (int i = 0; i < totalParts; i++) {
      final partFile = File(p.join(dir.path, "part_$i.tmp"));
      if (await partFile.exists()) {
        sink.add(await partFile.readAsBytes());
      }
    }
    await sink.close();

    meta["complete"] = true;
    meta["file_path"] = fullFile.path;
    meta["last_access"] = DateTime.now().toIso8601String();
    await metaFile.writeAsString(jsonEncode(meta));

    _index[url] = meta;
    await _saveIndex();

    return fullFile;
  }

  // 加载 meta.json
  Future<Map<String, dynamic>> _loadMeta(File metaFile, String url) async {
    if (await metaFile.exists()) {
      return jsonDecode(await metaFile.readAsString());
    } else {
      return {"url": url, "downloaded_parts": [], "complete": false};
    }
  }

  // ========== 获取缓存文件 ==========
  Future<File?> getCachedFile(String url) async {
    final info = _index[url];
    if (info == null) return null;
    final file = File(info["file_path"]);
    if (await file.exists()) {
      recordAccess(url);
      return file;
    }
    return null;
  }

  // 更新访问时间
  void recordAccess(String url) {
    if (_index[url] != null) {
      _index[url]["last_access"] = DateTime.now().toIso8601String();
      _saveIndex();
    }
  }

  // ========== 缓存清理逻辑 ==========
  Future<void> cleanOldCache({
    Duration maxAge = const Duration(days: 2),
  }) async {
    final now = DateTime.now();
    final toRemove = <String>[];

    for (final entry in _index.entries) {
      final last = DateTime.tryParse(entry.value["last_access"] ?? "");
      if (last == null || now.difference(last) > maxAge) {
        final file = File(entry.value["file_path"]);
        if (await file.exists()) await file.delete(recursive: true);
        final dir = Directory(p.join(_cacheDir.path, _hash(entry.key)));
        if (await dir.exists()) await dir.delete(recursive: true);
        toRemove.add(entry.key);
      }
    }

    for (final key in toRemove) {
      _index.remove(key);
    }
    await _saveIndex();
  }

  // 清理所有缓存
  Future<void> cleanAllCache() async {
    if (await _cacheDir.exists()) {
      await _cacheDir.delete(recursive: true);
      await _cacheDir.create(recursive: true);
    }
    _index.clear();
    await _saveIndex();
  }

  // 获取缓存统计
  Future<Map<String, dynamic>> getCacheInfo() async {
    int totalSize = 0;
    if (await _cacheDir.exists()) {
      final files = await _cacheDir.list(recursive: true).toList();
      for (final f in files) {
        if (f is File) totalSize += await f.length();
      }
    }
    return {
      "size": totalSize,
      "formattedSize": formatSize(totalSize),
      "count": _index.length,
    };
  }

  /// 动态缓冲：根据播放进度自动续缓存（保持领先 bufferPercent）
  Future<void> cacheUntilBufferAhead(
    String url, {
    required double playProgress, // 播放进度 [0.0 ~ 1.0]
    double bufferAheadPercent = 0.2, // 默认领先 20%
    void Function(double)? onProgress,
  }) async {
    final dir = Directory(p.join(_cacheDir.path, _hash(url)));
    if (!await dir.exists()) await dir.create(recursive: true);

    final metaFile = File(p.join(dir.path, "meta.json"));
    Map<String, dynamic> meta = await _loadMeta(metaFile, url);

    // 如果总大小未知则先获取
    int totalSize = meta["total_size"] ?? 0;
    if (totalSize == 0) {
      final head = await dio.head(url);
      totalSize = int.parse(head.headers.value('content-length') ?? '0');
      meta["total_size"] = totalSize;
    }

    final totalParts = (totalSize / partSize).ceil();
    List<int> downloadedParts = List<int>.from(meta["downloaded_parts"]);
    final bufferedPercent = downloadedParts.length / totalParts;

    // 若缓冲已经足够，则不再下载
    if (bufferedPercent >= playProgress + bufferAheadPercent) return;

    // 计算目标缓冲终点（例如 播放0.3 -> 目标缓冲到0.5）
    final targetPercent = (playProgress + bufferAheadPercent).clamp(0.0, 1.0);
    final targetPart = (targetPercent * totalParts).ceil();

    print(
      "🎧 当前进度 ${(playProgress * 100).toStringAsFixed(1)}%，"
      "缓冲到 ${(bufferedPercent * 100).toStringAsFixed(1)}%，"
      "目标缓冲 ${(targetPercent * 100).toStringAsFixed(1)}%",
    );

    // 依次下载目标区间内的分段
    for (int i = 0; i < targetPart; i++) {
      if (downloadedParts.contains(i)) continue;

      final start = i * partSize;
      final end = ((i + 1) * partSize) - 1;
      final partFile = File(p.join(dir.path, "part_$i.tmp"));

      try {
        final res = await dio.get<List<int>>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {"Range": "bytes=$start-$end"},
          ),
        );

        await partFile.writeAsBytes(res.data!);
        downloadedParts.add(i);
        meta["downloaded_parts"] = downloadedParts;
        await metaFile.writeAsString(jsonEncode(meta));

        if (onProgress != null) {
          onProgress(downloadedParts.length / totalParts);
        }
      } catch (e) {
        print("❌ 动态分段 $i 下载失败: $e");
        break;
      }

      // 每下载完一段就检查是否超过目标缓冲区
      final nowBuffered = downloadedParts.length / totalParts;
      if (nowBuffered >= targetPercent) {
        print("✅ 达到目标缓冲 ${(targetPercent * 100).toStringAsFixed(1)}%，暂停下载");
        break;
      }
    }

    // 更新索引
    meta["last_access"] = DateTime.now().toIso8601String();
    _index[url] = meta;
    await _saveIndex();
  }

  /// 创建临时缓存文件路径（未完成的下载）
  Future<File> createTempFile(String url) async {
    final dir = Directory(p.join(_cacheDir.path, _hash(url)));
    if (!await dir.exists()) await dir.create(recursive: true);
    return File(p.join(dir.path, "partial.tmp"));
  }

  /// 创建目标缓存文件路径（最终完整音频）
  Future<File> createTargetFile(String url) async {
    final dir = Directory(p.join(_cacheDir.path, _hash(url)));
    if (!await dir.exists()) await dir.create(recursive: true);
    final ext = p.extension(url);
    // 如果没有后缀，就默认用 .mp3
    final safeExt = ext.isEmpty ? ".mp3" : ext;
    return File(p.join(dir.path, "final$safeExt"));
  }

  Future<void> updateAccessTime(String url) async {
    if (_index[url] != null) {
      _index[url]["last_access"] = DateTime.now().toIso8601String();
      await _saveIndex();
    }
  }

  String formatSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(2)} KB";
    if (bytes < 1024 * 1024 * 1024)
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
  }

  // ========== 定期自动清理任务 ==========
  static Future<void> scheduledCleanup() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "last_cache_cleanup";
    final lastStr = prefs.getString(key);
    final now = DateTime.now();

    final manager = AudioCacheManager();
    await manager.init();

    if (lastStr == null) {
      await manager.cleanOldCache(maxAge: const Duration(days: 3));
      await prefs.setString(key, now.toIso8601String());
    } else {
      final last = DateTime.tryParse(lastStr);
      if (last == null || now.difference(last).inDays >= 1) {
        await manager.cleanOldCache(maxAge: const Duration(days: 2));
        await prefs.setString(key, now.toIso8601String());
      }
    }
  }
}
