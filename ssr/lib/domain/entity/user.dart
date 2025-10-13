/// 将表格数据的每个行化作一个实体，实现实体与表格
/// 表格每列信息化为实体的一个属性 - [有如下类型的属性]
    // 文本 - string
    // time - DateTime
    // 选择器 - Map [在表格中表现为feature1;feature2;feature3, 每个feature为0代表没选中，1代表选中，在选择器表现为{feature1: 0, feature2: 1, feature3: 0}]
/// copyWith函数 - 用于保留自己大部分属性，只修改一小部分属性的情况
/// fromDbMap 函数 - 从数据库中读取为Map，将其转换为实体
/// toDbMap 函数 - 将实体转换为Map，用于存储到数据库


