import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AudioCacheManager {
  final Dio dio;
  final int partSize; // 每段大小（默认1MB）
  late final Directory baseDir;

  AudioCacheManager({required this.dio, this.partSize = 1 * 1024 * 1024});

  Future<void> init() async {
    baseDir = Directory(
      p.join((await getApplicationDocumentsDirectory()).path, "audio_cache"),
    );
    if (!await baseDir.exists()) await baseDir.create(recursive: true);
  }

  String _hash(String url) => url.hashCode.toString();

  Future<Map<String, dynamic>> _loadMeta(String url) async {
    final dir = Directory(p.join(baseDir.path, _hash(url)));
    if (!await dir.exists()) await dir.create(recursive: true);
    final metaFile = File(p.join(dir.path, "meta.json"));
    if (await metaFile.exists()) {
      return jsonDecode(await metaFile.readAsString());
    } else {
      return {"url": url, "downloaded_parts": [], "complete": false};
    }
  }

  Future<void> _saveMeta(String url, Map<String, dynamic> meta) async {
    final dir = Directory(p.join(baseDir.path, _hash(url)));
    final metaFile = File(p.join(dir.path, "meta.json"));
    await metaFile.writeAsString(jsonEncode(meta));
  }

  /// 主入口：下载（断点续传）
  Future<void> download(String url, {void Function(double)? onProgress}) async {
    final dir = Directory(p.join(baseDir.path, _hash(url)));
    if (!await dir.exists()) await dir.create(recursive: true);

    final meta = await _loadMeta(url);
    final downloadedParts = List<int>.from(meta["downloaded_parts"]);

    // 获取文件大小
    final response = await dio.head(url);
    final totalSize = int.parse(
      response.headers.value('content-length') ?? '0',
    );
    meta["total_size"] = totalSize;
    final totalParts = (totalSize / partSize).ceil();

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
        await _saveMeta(url, meta);

        final progress = downloadedParts.length / totalParts;
        if (onProgress != null) onProgress(progress);
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
    await _saveMeta(url, meta);
  }

  Future<File?> getCachedFile(String url) async {
    final meta = await _loadMeta(url);
    if (meta["complete"] == true) {
      return File(p.join(baseDir.path, _hash(url), "full.mp3"));
    }
    return null;
  }
}
