import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/src/extension.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Widget which shows channel info
class ChannelInfo extends StatelessWidget {
  /// Constructor which creates a [ChannelInfo] widget
  const ChannelInfo({
    Key? key,
    required this.channel,
    this.textStyle,
    this.showTypingIndicator = true,
    this.parentId,
  }) : super(key: key);

  /// The channel about which the info is to be displayed
  final Channel channel;

  /// The style of the text displayed
  final TextStyle? textStyle;

  /// If true the typing indicator will be rendered if a user is typing
  final bool showTypingIndicator;

  /// Id of the parent message in case of a thread
  final String? parentId;

  @override
  Widget build(BuildContext context) {
    final client = StreamChat.of(context).client;
    return BetterStreamBuilder<List<Member>>(
      stream: channel.state!.membersStream,
      initialData: channel.state!.members,
      builder: (context, data) => ConnectionStatusBuilder(
        statusBuilder: (context, status) {
          switch (status) {
            case ConnectionStatus.connected:
              return _ConnectedTitleState(
                channel: channel,
                showTypingIndicator: showTypingIndicator,
                textStyle: textStyle,
                members: data,
                parentId: parentId,
              );
            case ConnectionStatus.connecting:
              return _ConnectingTitleState(textStyle: textStyle);
            case ConnectionStatus.disconnected:
              return _DisconnectedTitleState(
                client: client,
                textStyle: textStyle,
              );
            default:
              return const Offstage();
          }
        },
      ),
    );
  }
}

class _ConnectedTitleState extends StatelessWidget {
  const _ConnectedTitleState({
    Key? key,
    required this.channel,
    required this.showTypingIndicator,
    this.members,
    this.textStyle,
    this.parentId,
  }) : super(key: key);

  final Channel channel;
  final List<Member>? members;
  final TextStyle? textStyle;
  final bool showTypingIndicator;
  final String? parentId;

  @override
  Widget build(BuildContext context) {
    Widget? alternativeWidget;

    final memberCount = channel.memberCount;
    if (memberCount != null && memberCount > 2) {
      var text = context.translations.membersCountText(memberCount);
      final onlineCount =
          members?.where((m) => m.user?.online == true).length ?? 0;
      if (onlineCount > 0) {
        text += ', ${context.translations.watchersCountText(onlineCount)}';
      }
      alternativeWidget = Text(
        text,
        style: ChannelHeaderTheme.of(context).subtitleStyle,
      );
    } else {
      final userId = StreamChat.of(context).currentUser?.id;
      final otherMember = members?.firstWhereOrNull(
        (element) => element.userId != userId,
      );

      if (otherMember != null) {
        if (otherMember.user?.online == true) {
          alternativeWidget = Text(
            context.translations.userOnlineText,
            style: textStyle,
          );
        } else {
          alternativeWidget = Text(
            '${context.translations.userLastOnlineText} '
            '${Jiffy(otherMember.user?.lastActive).fromNow()}',
            style: textStyle,
          );
        }
      }
    }

    if (!showTypingIndicator) {
      return alternativeWidget ?? const Offstage();
    }

    return TypingIndicator(
      parentId: parentId,
      alignment: Alignment.center,
      alternativeWidget: alternativeWidget,
      style: textStyle,
    );
  }
}

class _ConnectingTitleState extends StatelessWidget {
  const _ConnectingTitleState({
    Key? key,
    this.textStyle,
  }) : super(key: key);

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 16,
          width: 16,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          context.translations.searchingForNetworkText,
          style: textStyle,
        ),
      ],
    );
  }
}

class _DisconnectedTitleState extends StatelessWidget {
  const _DisconnectedTitleState({
    Key? key,
    required this.client,
    this.textStyle,
  }) : super(key: key);

  final StreamChatClient client;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.translations.offlineLabel,
          style: textStyle,
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(
              horizontal: VisualDensity.minimumDensity,
              vertical: VisualDensity.minimumDensity,
            ),
          ),
          onPressed: () => client
            ..closeConnection()
            ..openConnection(),
          child: Text(
            context.translations.tryAgainLabel,
            style: textStyle?.copyWith(
              color: StreamChatTheme.of(context).colorTheme.accentPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
