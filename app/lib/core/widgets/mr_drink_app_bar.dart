import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../../features/profile/data/profile_repository.dart';

/// Shared glass AppBar used by all top-level shell screens.
/// Shows [user avatar] | "Mr. Drink" | [settings gear].
class MrDrinkAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const MrDrinkAppBar({
    super.key,
    this.showAvatar = true,
    this.leading,
    this.title = 'Mr. Drink',
    this.actions,
  });

  final bool showAvatar;
  final Widget? leading;
  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final profile = profileAsync.valueOrNull;

    Widget? leadingWidget = leading;
    if (leadingWidget == null && showAvatar) {
      leadingWidget = Padding(
        padding: const EdgeInsets.all(10),
        child: _AvatarCircle(
          url: profile?.avatarUrl,
          name: profile?.presentationName ?? '',
        ),
      );
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: !showAvatar,
      leading: leadingWidget,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        ...(actions ?? []),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.primary, size: 22),
          onPressed: () {},
          tooltip: 'Configurações',
        ),
      ],
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassNavBg,
              border: Border(
                bottom: BorderSide(color: AppColors.glassBorder, width: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({this.url, required this.name});
  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withAlpha(77), width: 1.5),
      ),
      child: ClipOval(
        child: url != null && url!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (ctx, _) => _Initials(name),
                errorWidget: (ctx, e, s) => _Initials(name),
              )
            : _Initials(name),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials(this.name);
  final String name;

  String get _initial =>
      name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.stoneMid,
      child: Center(
        child: Text(
          _initial,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
