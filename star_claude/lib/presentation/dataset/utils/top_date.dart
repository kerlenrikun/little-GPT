import 'package:flutter/material.dart';
import 'package:star_claude/core/configs/theme/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';

// 定义时间单元类型
enum TimeUnit { week, range }

class TopDate extends StatefulWidget {
  final Function(DateTime) onDateSelected; // 回调函数，用于通知父组件日期选择变化
  final Function(DateTime, DateTime)? onRangeSelected; // 可选回调函数，用于通知父组件范围选择变化

  const TopDate({Key? key, required this.onDateSelected, this.onRangeSelected})
    : super(key: key);

  @override
  State<TopDate> createState() => _TopDateState();

  // 静态GlobalKey，用于外部访问State中的数据
  static final GlobalKey<_TopDateState> dateKey = GlobalKey<_TopDateState>();
}

class _TopDateState extends State<TopDate> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime _rangeStart = DateTime.now();
  DateTime _rangeEnd = DateTime.now();
  TimeUnit _selectedUnit = TimeUnit.week; // 默认选择周单元
  bool _isRangeSelecting = false; // 是否处于范围选择模式
  DateTime? _tempRangeStart; // 临时保存范围选择的起点

  // 初始化时设置为当前日范围
  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _rangeStart = _selectedDay;
    _rangeEnd = _selectedDay;
  }

  /// 更新周范围（简化了原来的_setCurrentWeekRange和_getWeekRange）
  void _updateWeekRange(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    setState(() {
      _rangeStart = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );
      _rangeEnd = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);
    });
  }

  /// 导航时间单元（合并了上一个和下一个方法）
  void _navigateTimeUnit(int daysToAdd) {
    setState(() {
      // 更新focusedDay
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month,
        _focusedDay.day + daysToAdd,
      );

      if (_selectedUnit == TimeUnit.week ||
          (_selectedUnit == TimeUnit.range &&
              !_isRangeSelecting &&
              (_rangeEnd.difference(_rangeStart).inDays == 6 ||
                  _rangeEnd.difference(_rangeStart).inDays == 0))) {
        // 周模式或日范围模式：更新范围
        if (_rangeEnd.difference(_rangeStart).inDays == 0) {
          // 日范围模式：直接移动日期
          _selectedDay = _focusedDay;
          _rangeStart = _selectedDay;
          _rangeEnd = _selectedDay;
        } else {
          // 周模式：更新周范围
          _updateWeekRange(_focusedDay);
          // 检查选中日期是否在新范围内
          final isInRange =
              (_rangeStart.isBefore(_selectedDay) ||
                  _rangeStart.isAtSameMomentAs(_selectedDay)) &&
              (_rangeEnd.isAfter(_selectedDay) ||
                  _rangeEnd.isAtSameMomentAs(_selectedDay));
          // 如果不在范围内，默认选中范围的第一天
          if (!isInRange) {
            _selectedDay = _rangeStart;
          }
        }
        // 通知父组件范围选择更新
        if (widget.onRangeSelected != null) {
          widget.onRangeSelected!(_rangeStart, _rangeEnd);
        }
      }

      // 通知父组件
      widget.onDateSelected(_selectedDay);
    });
  }

  // 切换时间单元类型
  void _switchTimeUnit(TimeUnit unit) {
    setState(() {
      _selectedUnit = unit;
      _isRangeSelecting = false;
      _tempRangeStart = null;
      // 周模式下更新范围
      if (unit == TimeUnit.week) {
        _updateWeekRange(_focusedDay);
        // 通知父组件范围选择更新
        if (widget.onRangeSelected != null) {
          widget.onRangeSelected!(_rangeStart, _rangeEnd);
        }
      }
    });
  }

  // 长按日期进入范围选择模式
  void _startRangeSelection(DateTime date) {
    setState(() {
      _selectedUnit = TimeUnit.range;
      _isRangeSelecting = true;
      _tempRangeStart = date;
      _selectedDay = date;
    });
  }

  // 完成范围选择
  void _completeRangeSelection(DateTime date) {
    if (_tempRangeStart != null) {
      setState(() {
        if (date.isAfter(_tempRangeStart!)) {
          _rangeStart = _tempRangeStart!;
          _rangeEnd = date;
        } else {
          _rangeStart = date;
          _rangeEnd = _tempRangeStart!;
        }
        _selectedDay = date;
        _isRangeSelecting = false;
        _tempRangeStart = null;

        // 通知父组件范围选择完成
        if (widget.onRangeSelected != null) {
          widget.onRangeSelected!(_rangeStart, _rangeEnd);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190, // 容器高度
      padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.5))),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36.0),
          bottomRight: Radius.circular(36.0),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: TableCalendar(
              // 日期范围
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(DateTime.now().year + 10, 12, 31),
              focusedDay: _focusedDay,
              currentDay: DateTime.now(),
              selectedDayPredicate: (day) {
                // 范围选择模式下的显示逻辑
                if (_selectedUnit == TimeUnit.range) {
                  if (_isRangeSelecting && _tempRangeStart != null) {
                    // 正在选择范围时，高亮临时起点和当前鼠标悬停的范围
                    return isSameDay(_tempRangeStart, day) ||
                        (day.isAfter(_tempRangeStart!) &&
                            day.isBefore(_focusedDay)) ||
                        (day.isBefore(_tempRangeStart!) &&
                            day.isAfter(_focusedDay));
                  } else {
                    // 范围选择完成后，高亮整个范围
                    return (day.isAfter(_rangeStart) &&
                            day.isBefore(_rangeEnd)) ||
                        isSameDay(_rangeStart, day) ||
                        isSameDay(_rangeEnd, day);
                  }
                }
                // 周模式下选中范围的起点、终点和用户选中的具体日期
                return isSameDay(_selectedDay, day) ||
                    isSameDay(_rangeStart, day) ||
                    isSameDay(_rangeEnd, day);
              },
              onDayLongPressed: (selectedDay, focusedDay) {
                // 长按日期进入范围选择模式
                _startRangeSelection(selectedDay);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  _selectedDay = selectedDay;

                  // 范围选择模式下的处理逻辑
                  if (_selectedUnit == TimeUnit.range) {
                    if (_isRangeSelecting) {
                      // 完成范围选择
                      _completeRangeSelection(selectedDay);
                    } else {
                      // 选择单个日期作为范围
                      _rangeStart = selectedDay;
                      _rangeEnd = selectedDay;
                      // 通知父组件范围选择更新
                      if (widget.onRangeSelected != null) {
                        widget.onRangeSelected!(_rangeStart, _rangeEnd);
                      }
                    }
                  } else if (_selectedUnit == TimeUnit.week) {
                    // 周模式下，更新范围
                    _updateWeekRange(selectedDay);
                    // 通知父组件范围选择更新
                    if (widget.onRangeSelected != null) {
                      widget.onRangeSelected!(_rangeStart, _rangeEnd);
                    }
                  }
                });
                // 调用回调函数
                widget.onDateSelected(_selectedDay);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              // 日历格式始终为两周，因为月视图已移除
              calendarFormat: CalendarFormat.twoWeeks,
              // 隐藏头部
              headerVisible: false,
              // 显示星期
              daysOfWeekVisible: true,
              // 自适应容器高度
              shouldFillViewport: true,
              // 星期标题行高度
              daysOfWeekHeight: 24.0,
              // 日历样式设置
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: Color(0xff38B432),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: const Color(0xff38B432).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                cellPadding: const EdgeInsets.all(2.0),
                defaultTextStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff9e9e9e),
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                todayTextStyle: const TextStyle(
                  color: Color(0xff38B432),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
                weekendTextStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xff9e9e9e),
                ),
                withinRangeDecoration: BoxDecoration(
                  color: Color(0xff38B432).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                withinRangeTextStyle: const TextStyle(color: Colors.white),
                outsideDaysVisible: false,
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 12, color: Colors.white70),
                weekendStyle: TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 时间单元选择按钮区域
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedUnit = TimeUnit.range;
                        _isRangeSelecting = false;
                        _tempRangeStart = null;
                        // 设置为单日范围
                        _rangeStart = _selectedDay;
                        _rangeEnd = _selectedDay;
                        // 通知父组件范围选择
                        if (widget.onRangeSelected != null) {
                          widget.onRangeSelected!(_rangeStart, _rangeEnd);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedUnit == TimeUnit.range &&
                              !_isRangeSelecting &&
                              _rangeEnd.difference(_rangeStart).inDays ==
                                  0 // 0表示同一天
                          ? Color(0xff38B432).withOpacity(0.2)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      '日',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            _selectedUnit == TimeUnit.range &&
                                !_isRangeSelecting &&
                                _rangeEnd.difference(_rangeStart).inDays == 0
                            ? FontWeight.w900
                            : FontWeight.normal,
                        color:
                            _selectedUnit == TimeUnit.range &&
                                !_isRangeSelecting &&
                                _rangeEnd.difference(_rangeStart).inDays == 0
                            ? Color(0xff38B432)
                            : Colors.white70,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _switchTimeUnit(TimeUnit.week),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedUnit == TimeUnit.week
                          ? Color(0xff38B432)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: Text(
                      '周',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _selectedUnit == TimeUnit.week
                            ? FontWeight.w700
                            : FontWeight.normal,
                        color: _selectedUnit == TimeUnit.week
                            ? Colors.white
                            : Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 动态日期标识
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white70.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      // 日范围模式显示日期范围，其他模式显示选中日期
                      _rangeStart != _rangeEnd
                          ? '${_rangeStart.month}月${_rangeStart.day}日 - ${_rangeEnd.month}月${_rangeEnd.day}日'
                          : '${_selectedDay.year}年${_selectedDay.month}月${_selectedDay.day}日',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // 上一个单元按钮
                  IconButton(
                    onPressed: () => _navigateTimeUnit(
                      // 在日范围模式下导航1天，其他模式导航7天
                      (_selectedUnit == TimeUnit.range &&
                              _rangeEnd.difference(_rangeStart).inDays == 0)
                          ? -1
                          : -7,
                    ),
                    icon: const Icon(Icons.arrow_left, color: Colors.white),
                    iconSize: 20,
                  ),
                  // 下一个单元按钮
                  IconButton(
                    onPressed: () => _navigateTimeUnit(
                      // 在日范围模式下导航1天，其他模式导航7天
                      (_selectedUnit == TimeUnit.range &&
                              _rangeEnd.difference(_rangeStart).inDays == 0)
                          ? 1
                          : 7,
                    ),
                    icon: const Icon(Icons.arrow_right, color: Colors.white),
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
