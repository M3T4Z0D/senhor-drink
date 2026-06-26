import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/profile_model.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({super.key, required this.profile, this.radius = 36});

  final UserProfile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = profile.avatarUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(url),
      );
    }
    return CircleAvatar(
      radius: radius,
      child: Text(
        profile.username.isNotEmpty ? profile.username[0].toUpperCase() : '?',
        style: TextStyle(fontSize: radius * 0.7, fontWeight: FontWeight.bold),
      ),
    );
  }
}
