// 职业ID共享资源文件

// 职业ID映射表，用于ID与字符串之间的转换
class JobUtils {
  // ID到字符串的映射
  static String idToString(int id) {
    switch (id) {
      case 1:
        return '流量端';
      case 2:
        return '承接端';
      case 3:
        return '直销端';
      case 4:
        return '转化端';
      case 5:
        return '数据端';
      default:
        return '流量端'; // 默认返回第一个选项的ID
    }
  }

  // 字符串到ID的映射
  static int stringToId(String name) {
    switch (name) {
      case '流量端':
        return 1;
      case '承接端':
        return 2;
      case '直销端':
        return 3;
      case '转化端':
        return 4;
      case '数据端':
        return 5;
      default:
        return 0; // 默认返回第一个选项的ID
    }
  }
  
  // 字符串到ID的映射
  static List<String> job2Common(String job) {
    switch (job) {
      case '星穗':
        return ['请选择职业',''];
      case '流量端':
        return ['我推出','他加入',''];
      case '承接端':
        return ['我推微📲','我加粉:',''];
      case '直销端':
        return ['我talk','我直销',''];
      case '转化端':
        return ['学期带读','月训班','中级班'];
      case '数据端':
        return ['已填','未填'];
      default:
        return ['请选择职业','']; // 默认返回第一个选项的ID
    }
  }

  // 获取所有可用的职业名称列表
  static List<String> getAllJobNames() {
    return ['星穗', '流量端', '承接端', '直销端', '转化端', '数据端'];
  }

  // 获取所有可用的职业ID列表
  static List<int> getAllJobIds() {
    return [0, 1, 2, 3, 4, 5];
  }

  // 获取所有职业名称和ID的映射
  static Map<int, String> getAllJobs() {
    return {0: '星穗', 1: '流量端', 2: '承接端', 3: '直销端', 4: '转化端', 5: '数据端'};
  }
}

