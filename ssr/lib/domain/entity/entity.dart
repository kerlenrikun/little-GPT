/// 将表格数据的每个行化作一个实体，实现实体与表格
/// 表格每列信息化为实体的一个属性 - [有如下类型的属性] - 所有属性都标记为有值
    // 文本 - string
    // time - DateTime
    // 选择器 - Map [在表格中表现为feature1;feature2;feature3, 每个feature为0代表没选中，1代表选中，在选择器表现为{feature1: 0, feature2: 1, feature3: 0}]
/// 构造函数
/// copyWith函数 - 用于保留自己大部分属性，只修改一小部分属性的情况
/// fromDbMap 函数 - 从数据库中读取为Map，将其转换为实体
/// toDbMap 函数 - 将实体转换为Map，用于存储到数据库
/// toCloudMap 函数 - 将实体转换为Map，用于存储到云端
/// fromCloudMap 函数 - 从云端读取为Map，将其转换为实体
/// 解析选择器 函数 - 从表格中读取为数值为0或1的feature，将其转换为选择器
/*
return Map<String, int>.fromEntries(
          feishuMap.entries
              .where((entry) {
                try {
                  final value = int.tryParse(entry.value.toString());
                  return value == 0 || value == 1;
                } catch (_) {
                  return false;
                }
              })
              .map((entry) => MapEntry(
                    entry.key.toString(),
                    int.tryParse(entry.value.toString()) ?? 0,
                  ))
        );

*/
/// isSame 函数 - 用于判断两个实体是否相同, 推荐使用toDbMap或toCloudMap进行比较


