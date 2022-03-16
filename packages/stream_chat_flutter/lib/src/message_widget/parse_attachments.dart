import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/src/message_widget/message_widget_content_components.dart';
import 'package:stream_chat_flutter/src/utils/utils.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// {@template parseAttachments}
/// Parses the attachments of a [MessageWidget].
///
/// Used in [MessageCard]. Should not be used elsewhere.
/// {@endtemplate}
class ParseAttachments extends StatelessWidget {
  /// {@macro parseAttachments}
  const ParseAttachments({
    Key? key,
    required this.message,
    required this.attachmentBuilders,
    required this.attachmentPadding,
  }) : super(key: key);

  /// {@macro message}
  final Message message;

  /// {@macro attachmentBuilders}
  final Map<String, AttachmentBuilder> attachmentBuilders;

  /// {@macro attachmentPadding}
  final EdgeInsetsGeometry attachmentPadding;

  @override
  Widget build(BuildContext context) {
    final attachmentGroups = <String, List<Attachment>>{};

    message.attachments
        .where((element) =>
            (element.titleLink == null && element.type != null) ||
            element.type == 'giphy')
        .forEach((e) {
      if (attachmentGroups[e.type] == null) {
        attachmentGroups[e.type!] = [];
      }

      attachmentGroups[e.type]?.add(e);
    });

    final attachmentList = <Widget>[];

    attachmentGroups.forEach((type, attachments) {
      final attachmentBuilder = attachmentBuilders[type];

      if (attachmentBuilder == null) return;
      final attachmentWidget = attachmentBuilder(
        context,
        message,
        attachments,
      );
      attachmentList.add(attachmentWidget);
    });

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 300,
      ),
      child: Padding(
        padding: attachmentPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: attachmentList.insertBetween(
            SizedBox(
              height: attachmentPadding.vertical / 2,
            ),
          ),
        ),
      ),
    );
  }
}
