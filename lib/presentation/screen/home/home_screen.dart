import 'package:custom_reaction_widget/presentation/screen/home/components/reaction_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_color.dart';
import '../../../core/assets/design_assets.dart';
import '../../../core/widgets/design_image.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeUI();
  }
}

class HomeUI extends StatefulWidget {
  const HomeUI({super.key});

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  final _reactionNotifier = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _reactionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(16),
          width: MediaQuery.sizeOf(context).width - 64,
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: AppColor.blackGrey.withValues(alpha: 0.25),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.neutral[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ValueListenableBuilder(
                  valueListenable: _reactionNotifier,
                  builder: (context, reaction, _) {
                    if (reaction == null) return const SizedBox();

                    return DesignImage(
                      PngAssets(reaction),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select your Reaction",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              // widget reactions
              ReactionsWidget(
                onSelected: (icon) {
                  _reactionNotifier.value = icon;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
