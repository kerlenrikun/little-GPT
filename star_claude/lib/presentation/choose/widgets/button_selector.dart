import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:star_claude/core/configs/__init__.dart';
import 'button/id_button.dart';

/// 按钮选择器组件，实现按钮组合的循环切换
class ButtonSelector extends StatefulWidget {
  // 选中状态的回调
  final Function(int selectedId) onSelectionChanged;
  // 当前选中的ID
  final int currentSelectedId;

  const ButtonSelector({
    required this.onSelectionChanged,
    required this.currentSelectedId,
    super.key,
  });

  @override
  State<ButtonSelector> createState() => _ButtonSelectorState();
}

class _ButtonSelectorState extends State<ButtonSelector> {
  // 当前显示的按钮对索引
  int _currentPairIndex = 0;

  // 处理按钮点击
  void _handleButtonTap(int id) {
    widget.onSelectionChanged(id);
  }

  // 判断_isotherSelected
  bool _isOtherSelected(int id, List<int> currentPairIds) {
    return widget.currentSelectedId != id && 
           widget.currentSelectedId != 0 && 
           currentPairIds.contains(widget.currentSelectedId);
  }

  // 获取当前的按钮对
  List<IdButton> _getCurrentButtonPair() {
    switch (_currentPairIndex) {
      case 0:
        return [
          IdButton(
            appIcon: AppVectors.iconLl,
            appText: AppVectors.idLl,
            scale: 0.4,
            isSelected: widget.currentSelectedId == 1,
            otherSelected: _isOtherSelected(1, [1, 2]),
            onTap: () => _handleButtonTap(1),
          ),
          IdButton(
            appIcon: AppVectors.iconCj,
            appText: AppVectors.idCj,
            scale: 0.5,
            isSelected: widget.currentSelectedId == 2,
            otherSelected: _isOtherSelected(2, [1, 2]),
            onTap: () => _handleButtonTap(2),
          ),
        ];
      case 1:
        return [
          IdButton(
            appIcon: AppVectors.moon,
            appText: AppVectors.idZx,
            scale: 0.4,
            isSelected: widget.currentSelectedId == 3,
            otherSelected: _isOtherSelected(3, [3, 4]),
            onTap: () => _handleButtonTap(3),
          ),
          IdButton(
            appIcon: AppVectors.sun,
            appText: AppVectors.idZh,
            scale: 0.5,
            isSelected: widget.currentSelectedId == 4,
            otherSelected: _isOtherSelected(4, [3, 4]),
            onTap: () => _handleButtonTap(4),
          ),
        ];
      case 2:
        return [
          IdButton(
            appIcon: AppVectors.iconSj,
            appText: AppVectors.idSj,
            scale: 0.4,
            isSelected: widget.currentSelectedId == 5,
            otherSelected: _isOtherSelected(5, [5, 1]),
            onTap: () => _handleButtonTap(5),
          ),
          IdButton(
            appIcon: AppVectors.iconLl,
            appText: AppVectors.idLl,
            scale: 0.4,
            isSelected: widget.currentSelectedId == 1,
            otherSelected: _isOtherSelected(1, [5, 1]),
            onTap: () => _handleButtonTap(1),
          ),
        ];
      default:
        return _getCurrentButtonPair();
    }
  }

  // 处理切换按钮点击
  void _handleSwitchTap() {
    setState(() {
      // 循环切换按钮对
      _currentPairIndex = (_currentPairIndex + 1) % 3;
      // 获取当前按钮对的ID列表
      List<int> currentPairIds;
      switch (_currentPairIndex) {
        case 0:
          currentPairIds = [1, 2];
          break;
        case 1:
          currentPairIds = [3, 4];
          break;
        case 2:
          currentPairIds = [5, 1];
          break;
        default:
          currentPairIds = [1, 2];
      }

      // 如果当前选中的ID不在新的按钮对中，则清除选中状态
      if (!currentPairIds.contains(widget.currentSelectedId)) {
        widget.onSelectionChanged(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前显示的按钮对
    final currentPair = _getCurrentButtonPair();
    
    // 获取当前的两个按钮
    final firstButton = currentPair[0];
    final secondButton = currentPair[1];

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 为保证对称设计的占位Icon
          Icon(
            Icons.arrow_forward_ios,
            size: 24,
            color: Colors.transparent,
          ),
          const SizedBox(width: 10),
          firstButton,
          const SizedBox(width: 50, height: 150),
          secondButton,
          const SizedBox(width: 10),
          // 切换按钮组
          Column(
            children: [
              GestureDetector(
                onTap: _handleSwitchTap,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 24,
                  color: Colors.white24,
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 3), // 阴影位置
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
