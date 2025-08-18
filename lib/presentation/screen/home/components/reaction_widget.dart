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
  final iconSize = 42.0;
  final iconSpacing = 8.0;

  final reactions = [
    {"icon": "assets/icon/like.png", "text": "Like"},
    {"icon": "assets/icon/love.png", "text": "Love"},
    {"icon": "assets/icon/care.png", "text": "Care"},
    {"icon": "assets/icon/haha.png", "text": "Haha"},
    {"icon": "assets/icon/wow.png", "text": "Wow"},
    {"icon": "assets/icon/sad.png", "text": "Sad"},
    {"icon": "assets/icon/angry.png", "text": "Angry"},
  ];

  final _hoveredIndex = ValueNotifier<int?>(null);
  OverlayEntry? _overlayEntry;

  int _selectedIndex = 0; // ✅ Keep track of selected reaction

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
          children: [
            // ✅ Show the selected reaction icon
            DesignImage(
              PngAssets(reactions[_selectedIndex]["icon"]!),
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 10),
            Text("Hold for other Reactions"),
          ],
        ),
      ),
    );
  }

  void onTap() {
    // Default action → Like
    setState(() => _selectedIndex = 0);
    widget.onSelected(reactions[0]["icon"]!);
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
            GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                width: sWidth,
                height: sHeight,
                color: Colors.transparent,
              ),
            ),

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
                      children: List.generate(reactions.length, (index) {
                        final reaction = reactions[index];
                        final icon = reaction["icon"]!;
                        final text = reaction["text"]!;
                        final isHovered = hovered == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedIndex = index); // ✅ Update selected
                            widget.onSelected(icon);
                            _removeOverlay();
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isHovered)
                                Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              if (isHovered) const SizedBox(height: 4),

                              AnimatedScale(
                                scale: isHovered ? 1.5 : 1,
                                duration: const Duration(milliseconds: 150),
                                child: DesignImage(
                                  PngAssets(icon),
                                  width: iconSize,
                                  height: iconSize,
                                ),
                              ),
                            ],
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

    if (index >= 0 && index < reactions.length) {
      _hoveredIndex.value = index;
    } else {
      _hoveredIndex.value = null;
    }
  }

  void onLongPressEnd(LongPressEndDetails _) {
    final index = _hoveredIndex.value;
    if (index != null) {
      setState(() => _selectedIndex = index); // ✅ Update selected
      widget.onSelected(reactions[index]["icon"]!);
      _removeOverlay();
      _hoveredIndex.value = null;
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

