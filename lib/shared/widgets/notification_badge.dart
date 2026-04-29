import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final bool showBadge;
  final Color badgeColor;
  final Color textColor;
  final double badgeSize;

  const NotificationBadge({
    super.key,
    required this.child,
    this.count = 0,
    this.showBadge = true,
    this.badgeColor = Colors.red,
    this.textColor = Colors.white,
    this.badgeSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (showBadge && count > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              height: badgeSize,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(badgeSize / 2),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              constraints: BoxConstraints(
                minWidth: badgeSize,
                minHeight: badgeSize,
              ),
              child: Center(
                child: count <= 99
                    ? Text(
                        count.toString(),
                        style: TextStyle(
                          color: textColor,
                          fontSize: badgeSize * 0.6,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        '99+',
                        style: TextStyle(
                          color: textColor,
                          fontSize: badgeSize * 0.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}
