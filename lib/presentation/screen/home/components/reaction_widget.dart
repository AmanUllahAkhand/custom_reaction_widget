import 'package:flutter/material.dart';
import '../../../../core/config/app_color.dart';
import '../../../../core/assets/design_assets.dart';
import '../../../../core/widgets/design_image.dart';

class ReactionsWidget extends StatefulWidget {
  const ReactionsWidget({
    super.key,
    required this.onSelected,
  });

  final void Function(String icon) onSelected;

  @override
  State<ReactionsWidget> createState() => _ReactionsWidgetState();
}

class _ReactionsWidgetState extends State<ReactionsWidget> {
  // initial state
  final iconSize = 42.0;
  final iconSpacing = 8.0;

  final icons = [
    "assets/icon/romance.png",
    "assets/icon/dead.png",
    "assets/icon/spooky.png",
    "assets/icon/superstar.png",
    "assets/icon/confusion.png",
  ];

  final _hoveredIndex = ValueNotifier<int?>(null);
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      onLongPressMoveUpdate: onLongPressMove,
      onLongPressEnd: onLongPressEnd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            DesignImage(
              PngAssets(icons[0]),
              width: 32,
              height: 32,
            ),
            Text("Hold for other Reactions"),
          ],
        ),
      ),
    );
  }

  void onTap() {
    widget.onSelected(icons[0]);
  }

  void onLongPressStart(LongPressStartDetails _) {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final sWidth = MediaQuery.sizeOf(context).width;
        final sHeight = MediaQuery.sizeOf(context).height;

        return Stack(
          children: [
            // barrier dismissible
            GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                width: sWidth,
                height: sHeight,
                color: Colors.transparent,
              ),
            ),

            // popup
            Positioned(
              left: offset.dx,
              bottom: sHeight - offset.dy + 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: AppColor.blackGrey.withValues(alpha: 0.25),
                    ),
                  ],
                ),
                child: ValueListenableBuilder(
                  valueListenable: _hoveredIndex,
                  builder: (context, hovered, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: iconSpacing,
                      children:
                      List.generate(icons.length, (index) {
                        final icon = icons[index];
                        final isHovered = hovered == index;

                        return GestureDetector(
                          onTap: () {
                            widget.onSelected(icon);
                            _removeOverlay();
                          },
                          child: AnimatedScale(
                            scale: isHovered ? 1.5 : 1,
                            duration: const Duration(milliseconds: 150),
                            child: DesignImage(
                              PngAssets(icon),
                              width: iconSize,
                              height: iconSize,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void onLongPressMove(LongPressMoveUpdateDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;

    final offsetX =
        details.globalPosition.dx - renderBox.localToGlobal(Offset.zero).dx;

    final iconFullWidth = iconSize + iconSpacing;
    final index = (offsetX / iconFullWidth).floor();

    if (index >= 0 && index < icons.length) {
      _hoveredIndex.value = index;
    } else {
      _hoveredIndex.value = null;
    }
  }

  void onLongPressEnd(LongPressEndDetails _) {
    final index = _hoveredIndex.value;

    if (index != null) {
      widget.onSelected(icons[index]);

      _removeOverlay();
      _hoveredIndex.value = null;
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
