/// 字符串截断工具类
class StringUtils {
  /// 截断字符串，如果超过指定长度，移除末尾字符, 不足最小长度补空格
  /// [text] 要截断的文本
  /// [maxLength] 最大字符长度
  /// [minLength] 最小字符长度
  /// [ellipsis] 省略符号，默认为'...'
  static String truncate(String text, int maxLength, {int minLength = 0, String ellipsis = ''}) {
    if (text.isEmpty) return '';
    if (text.length >= maxLength) text = text.substring(maxLength);
    if (text.length <= minLength) return text.padRight(minLength-text.length);
    return  text+ellipsis;
  }
}   