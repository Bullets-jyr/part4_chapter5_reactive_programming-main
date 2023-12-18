import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../common/common.dart';

class TossAppBar extends StatefulWidget {
  final double appBarHeight;

  const TossAppBar({
    Key? key,
    required this.appBarHeight,
  }) : super(key: key);

  @override
  State<TossAppBar> createState() => _TossAppBarState();
}

class _TossAppBarState extends State<TossAppBar> {
  /// [문제점]
  /// 토글 형태의 버튼을 유저가 짧은 시간 내에 다수 클릭
  /// 토글 값에 따라 처리 로직 시간이 소요 되는 경우(네트워킹, 무거운 작업)
  ///
  /// 로그인을 하면 로그인 API 시간이 걸림. 2초

  StreamSubscription? _subscription;
  final PublishSubject<bool> _isOnSubject = PublishSubject<bool>();
  bool _isRequesting = false;

  int _count = 0;

  @override
  void initState() {
    super.initState();

    /// TODO: Throttle time 1s
    _subscription = _isOnSubject.throttleTime(const Duration(seconds: 1)).listen(
      (value) {
        _listen(value);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _isOnSubject.close();

    super.dispose();
  }

  Future<void> _listen(bool value) async {
    try {
      _isRequesting = true;

      _count++;
      debugPrint('count - $_count');

      /// TODO: 가정 - 로그인 / 로그아웃, 2초 걸림
      await Future.delayed(const Duration(seconds: 2));

      /// 실패할 수도 있음.
      // if (Random().nextBool()) {
      //   debugPrint('로그인 성공');
      // } else {
      //   throw '로그인 실패';
      // }
    } catch (e, s) {
      /// 실패할 경우, 이전 값 되돌림.
      _isOnSubject.add(!value);

      debugPrint('Error: $e, StackTrace: $s');
    } finally {
      _isRequesting = false;
    }

    /// 완벽하게 에러를 막기 위한 방법
    /// 1. dialog 같은 팝업 활용 (로그아웃을 하시겠습니까?)
    /// 2. isRequesting 네트워킹 bool 변수로 현재 API 요청 중이면, 무시하는 로직 추가
  }

  Future<void> _onTap(bool current) async {
    if (_isRequesting) return;

    _isOnSubject.add(!current);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.appColors.appbarBackground,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: widget.appBarHeight,
            child: Row(
              children: [
                width5,
                StreamBuilder<bool>(
                  stream: _isOnSubject.stream,
                  builder: (context, snapshot) {
                    final value = snapshot.data ?? false;

                    return GestureDetector(
                      onTap: () => _onTap(value),
                      behavior: HitTestBehavior.translucent,
                      child: Opacity(
                        opacity: value ? 1 : 0.5,
                        child: Image.asset(
                          '$basePath/icon/toss.png',
                          height: 30,
                        ),
                      ),
                    );
                  },
                ),
                emptyExpanded,
                Image.asset(
                  '$basePath/icon/map_point.png',
                  height: 30,
                ),
                width10,
                Image.asset(
                  '$basePath/icon/notification.png',
                  height: 30,
                ),
                width10,
              ],
            ),
          ),
          const Line(),
        ],
      ),
    );
  }
}
