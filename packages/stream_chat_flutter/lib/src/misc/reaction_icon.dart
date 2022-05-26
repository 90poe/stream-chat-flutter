import 'package:flutter/material.dart';

/// {@macro streamReactionIcon}
@Deprecated("Use 'StreamReactionIcon' instead")
typedef ReactionIcon = StreamReactionIcon;

/// {@template streamReactionIcon}
/// Reaction icon data
/// {@endtemplate}
class StreamReactionIcon {
  /// {@macro streamReactionIcon}
  StreamReactionIcon({
    required this.type,
    required this.builder,
  });

  /// Type of reaction
  final String type;

  /// Asset to display for reaction
  final Widget Function(
    BuildContext,
    bool highlighted,
    double size,
  ) builder;
}