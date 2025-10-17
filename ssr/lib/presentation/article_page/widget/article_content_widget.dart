// article_content_widget.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ssr/presentation/article_page/article_provider.dart';

/// 数据模型：高亮（用户收藏）
class HighlightRange {
  final int start;
  final int end;
  final Color color;
  final String text;

  HighlightRange({
    required this.start,
    required this.end,
    required this.color,
    required this.text,
  });
}

/// 数据模型：评论（公共）
class CommentData {
  final int start;
  final int end;
  final String text;
  final String comment;

  CommentData({
    required this.start,
    required this.end,
    required this.text,
    required this.comment,
  });
}

class ArticleContentPage extends StatefulWidget {
  const ArticleContentPage({Key? key}) : super(key: key);

  @override
  State<ArticleContentPage> createState() => _ArticleContentPageState();
}

class _ArticleContentPageState extends State<ArticleContentPage> {
  final List<HighlightRange> highlights = [];
  final List<CommentData> comments = [];
  TextSelection? currentSelection;
  final ArticleInfoProvider articleInfoProvider = ArticleInfoProvider();
  late String articleText;

  // overlay
  OverlayEntry? _overlayEntry;
  Offset? _lastGlobalTap; // 记录用户最后一次点击/长按位置（全局坐标）
  final double _menuWidth = 220;

  @override
  void initState() {
    super.initState();
    articleText = articleInfoProvider.articleContent;
    articleInfoProvider.addListener(_updateTitle);
  }

  void _updateTitle() {
    setState(() {
      articleText = articleInfoProvider.articleContent;
    });
  }

  @override
  void dispose() {
    articleInfoProvider.removeListener(_updateTitle);
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOrUpdateOverlay() {
    // 如果没有选区或没有坐标，确保移除
    if (currentSelection == null || _lastGlobalTap == null) {
      _removeOverlay();
      return;
    }

    // 确保使用当前选区数据（若后续打开 bottomSheet 会清空系统选区）
    final start = currentSelection!.start;
    final end = currentSelection!.end;
    final selectedText = (start < end && end <= articleText.length)
        ? articleText.substring(start, end)
        : '';

    // 屏幕尺寸用于边界处理
    final media = MediaQuery.of(context);
    final screenW = media.size.width;
    final screenH = media.size.height;
    final tap = _lastGlobalTap!;

    // 计算菜单的左上角位置（尽量让菜单显示在 tap 上方）
    double dx = tap.dx - _menuWidth / 2;
    double dy = tap.dy - 120; // 默认显示在 tap 上方 48 px

    // 边界修正
    if (dx < 8) dx = 8;
    if (dx + _menuWidth > screenW - 8) dx = screenW - _menuWidth - 8;
    if (dy < 8) dy = tap.dy + 20; // 如果顶部放不下，就放在下方

    // 构造 overlay
    final newEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: dx,
        top: dy,
        width: _menuWidth,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    selectedText.length > 20
                        ? '${selectedText.substring(0, 20)}...'
                        : selectedText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: '收藏',
                  onPressed: () {
                    // 可能选区已被系统清掉，使用保存的 currentSelection
                    if (currentSelection != null) {
                      final s = currentSelection!;
                      final txt =
                          (s.start < s.end && s.end <= articleText.length)
                          ? articleText.substring(s.start, s.end)
                          : '';
                      setState(() {
                        highlights.add(
                          HighlightRange(
                            start: s.start,
                            end: s.end,
                            color: Colors.redAccent,
                            text: txt,
                          ),
                        );
                        currentSelection = null;
                      });
                    }
                    _removeOverlay();
                  },
                  icon: const Icon(Icons.star_border, size: 20),
                ),
                IconButton(
                  tooltip: '评论',
                  onPressed: () {
                    if (currentSelection != null) {
                      final s = currentSelection!;
                      final txt =
                          (s.start < s.end && s.end <= articleText.length)
                          ? articleText.substring(s.start, s.end)
                          : '';
                      _removeOverlay();
                      _showCommentDialog(s.start, s.end, txt);
                    } else {
                      _removeOverlay();
                    }
                  },
                  icon: const Icon(Icons.comment_outlined, size: 20),
                ),
                IconButton(
                  tooltip: '关闭',
                  onPressed: () {
                    setState(() => currentSelection = null);
                    _removeOverlay();
                  },
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // replace existing overlay if exists
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = newEntry;
      Overlay.of(context)?.insert(_overlayEntry!);
    } else {
      _overlayEntry = newEntry;
      Overlay.of(context)?.insert(_overlayEntry!);
    }
  }

  Widget _buildRichTextWithHighlights() {
    final spans = <TextSpan>[];

    // 1️⃣ 收集高亮与评论区间
    final marks = <_RangeMark>[];
    for (final h in highlights) {
      marks.add(_RangeMark(h.start, h.end, isHighlight: true));
    }
    for (final c in comments) {
      marks.add(_RangeMark(c.start, c.end, isComment: true));
    }

    // 2️⃣ 合并区间，确保重叠部分拆分干净
    final merged = _mergeRanges(marks, articleText.length, debug: kDebugMode);

    // 3️⃣ 构建 spans
    for (final m in merged) {
      final text = articleText.substring(m.start, m.end);

      // 颜色判定（精确区分三种状态）
      Color? bg;
      if (m.isHighlight && m.isComment) {
        bg = Colors.purpleAccent.withOpacity(0.35); // 混合区
      } else if (m.isHighlight) {
        bg = Colors.blueAccent.withOpacity(0.3); // 收藏区
      } else if (m.isComment) {
        bg = Colors.redAccent.withOpacity(0.3); // 评论区
      }

      TapGestureRecognizer? tap;

      if (m.isComment) {
        // 当前片段属于评论或重叠区，点击显示评论
        tap = TapGestureRecognizer()
          ..onTap = () {
            // 找出所有与该片段有交集的评论
            final related = comments
                .where((c) => c.start < m.end && c.end > m.start)
                .toList();
            if (related.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('此段暂无评论')));
            } else {
              _showCommentsForRanges(related);
            }
          };
      } else if (m.isHighlight) {
        // 当前片段属于纯收藏
        tap = TapGestureRecognizer()
          ..onTap = () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('这是您收藏的段落')));
          };
      }

      spans.add(
        TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            backgroundColor: bg,
          ),
          recognizer: tap,
        ),
      );
    }

    // 4️⃣ 可选中文本组件（自定义菜单）
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (d) => _lastGlobalTap = d.globalPosition,
      onLongPressStart: (d) => _lastGlobalTap = d.globalPosition,
      child: SelectionArea(
        contextMenuBuilder: (context, editableState) => const SizedBox.shrink(),
        child: SelectableText.rich(
          TextSpan(children: spans),
          onSelectionChanged: (selection, cause) {
            if (selection.start != selection.end) {
              setState(() => currentSelection = selection);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showOrUpdateOverlay();
              });
            } else {
              setState(() => currentSelection = null);
              _removeOverlay();
            }
          },
        ),
      ),
    );
  }

  void _showCommentsForRanges(List<CommentData> related) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: related.length,
        itemBuilder: (_, i) {
          final c = related[i];
          return ListTile(
            leading: const Icon(Icons.comment, color: Colors.blue),
            title: Text(c.comment),
            subtitle: Text('「${c.text}」'),
          );
        },
      ),
    );
  }

  void _showCommentDialog(int start, int end, String selectedText) {
    final controller = TextEditingController();
    // 因为打开 bottom sheet 可能会清除系统选区，我们已经把 start/end/selectedText 作为参数传入
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '评论选中内容：\n「$selectedText」',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '请输入评论内容',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    comments.add(
                      CommentData(
                        start: start,
                        end: end,
                        text: selectedText,
                        comment: text,
                      ),
                    );
                    // 也可以为评论的范围同时高亮（可选）
                    // highlights.add(
                    //   HighlightRange(
                    //     start: start,
                    //     end: end,
                    //     color: Colors.yellowAccent,
                    //     text: selectedText,
                    //   ),
                    // );
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('提交评论'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      // bottom sheet 关闭后清理 overlay 和选区
      _removeOverlay();
      setState(() {
        currentSelection = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: _buildRichTextWithHighlights(),
    );
  }
}

/// 本地类：存储区间状态
class _RangeMark {
  final int start;
  final int end;
  final bool isHighlight;
  final bool isComment;

  _RangeMark(
    this.start,
    this.end, {
    this.isHighlight = false,
    this.isComment = false,
  });

  @override
  String toString() => 'Range[$start,$end,h=$isHighlight,c=$isComment]';
}

/// 合并/拆分文本区间（确保重叠部分正确分色）
/// 合并/拆分文本区间（确保单独评论/收藏及重叠部分都正确分色）
List<_RangeMark> _mergeRanges(
  List<_RangeMark> input,
  int textLength, {
  bool debug = false,
}) {
  if (input.isEmpty) return [_RangeMark(0, textLength)];

  // 收集所有边界点
  final points = <int>{0, textLength};
  for (final r in input) {
    points.add(r.start.clamp(0, textLength));
    points.add(r.end.clamp(0, textLength));
  }
  final sorted = points.toList()..sort();

  final result = <_RangeMark>[];

  for (int i = 0; i < sorted.length - 1; i++) {
    final s = sorted[i];
    final e = sorted[i + 1];
    if (e <= s) continue;

    bool isHighlight = false;
    bool isComment = false;

    for (final r in input) {
      // 只算片段被原区间覆盖的部分
      if (s >= r.start && e <= r.end) {
        if (r.isHighlight) isHighlight = true;
        if (r.isComment) isComment = true;
      }
    }

    final mark = _RangeMark(
      s,
      e,
      isHighlight: isHighlight,
      isComment: isComment,
    );
    result.add(mark);

    if (debug) {
      debugPrint('DEBUG _RangeMark: $mark');
    }
  }

  return result;
}
