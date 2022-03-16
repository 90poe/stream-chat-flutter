import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// {@template attachmentButton}
/// A button for adding attachments to a chat on mobile.
/// {@endtemplate}
class AttachmentButton extends StatelessWidget {
  /// {@macro attachmentButton}
  const AttachmentButton({
    Key? key,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  /// The color of the button.
  final Color color;

  /// The callback to perform when the button is tapped or clicked.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: StreamSvgIcon.attach(
        color: color,
      ),
      padding: const EdgeInsets.all(0),
      constraints: const BoxConstraints.tightFor(
        height: 24,
        width: 24,
      ),
      splashRadius: 24,
      onPressed: onPressed,
    );
  }
}
