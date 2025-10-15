// Domain模块导出管理文件
// 使用模块化导入方式，便于维护和管理

export 'entities/auth/user.dart';
export 'entities/data/account_data.dart';
export 'entities/data/common_data.dart';
export 'entities/data/succ_data.dart';

export 'provider/account_data_provider.dart';
export 'provider/common_data_provider.dart';
export 'provider/succ_data_provider.dart';
export 'provider/user_provider.dart';
export 'provider/date_provider.dart';

export 'repository/account_data_repository.dart';
export 'repository/base_repository.dart';
export 'repository/common_data_repository.dart';
export 'repository/succ_data_repository.dart';
export 'repository/user_repository.dart';

export 'usecases/job_resources.dart';