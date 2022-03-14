import 'package:flutter/material.dart' hide ButtonStyle;
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:native_context_menu/native_context_menu.dart';
import 'package:stream_chat_flutter/src/bottom_sheets/edit_message_sheet.dart';
import 'package:stream_chat_flutter/src/context_menu_items/context_menu_items.dart';
import 'package:stream_chat_flutter/src/dialogs/delete_message_dialog.dart';
import 'package:stream_chat_flutter/src/dialogs/message_dialog.dart';
import 'package:stream_chat_flutter/src/extension.dart';
import 'package:stream_chat_flutter/src/image_group.dart';
import 'package:stream_chat_flutter/src/message_actions_modal/message_actions_modal.dart';
import 'package:stream_chat_flutter/src/message_widget/message_reactions_modal.dart';
import 'package:stream_chat_flutter/src/message_widget/message_widget_content.dart';
import 'package:stream_chat_flutter/src/platform_widgets/platform_widget_builder.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Widget builder for building attachments
typedef AttachmentBuilder = Widget Function(
  BuildContext,
  Message,
  List<Attachment>,
);

/// Callback for when quoted message is tapped
typedef OnQuotedMessageTap = void Function(String?);

/// The display behaviour of a widget
enum DisplayWidget {
  /// Hides the widget replacing its space with a spacer
  hide,

  /// Hides the widget not replacing its space
  gone,

  /// Shows the widget normally
  show,
}

/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/message_widget.png)
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/message_widget_paint.png)
///
/// {@template messageWidget}
/// Shows a message with reactions, replies and user avatar.
///
/// Usually you don't use this widget as it's the default message widget used by
/// [MessageListView].
///
/// The widget components render the ui based on the first ancestor of type
/// [StreamChatTheme].
/// Modify it to change the widget appearance.
/// {@endtemplate}
class MessageWidget extends StatefulWidget {
  /// {@macro messageWidget}
  MessageWidget({
    Key? key,
    required this.message,
    required this.messageTheme,
    this.reverse = false,
    this.translateUserAvatar = true,
    this.shape,
    this.attachmentShape,
    this.borderSide,
    this.attachmentBorderSide,
    this.borderRadiusGeometry,
    this.attachmentBorderRadiusGeometry,
    this.onMentionTap,
    this.onMessageTap,
    this.showReactionPickerIndicator = false,
    this.showUserAvatar = DisplayWidget.show,
    this.showSendingIndicator = true,
    this.showThreadReplyIndicator = false,
    this.showInChannelIndicator = false,
    this.onReplyTap,
    this.onThreadTap,
    this.showUsername = true,
    this.showTimestamp = true,
    this.showReactions = true,
    this.showDeleteMessage = true,
    this.showEditMessage = true,
    this.showReplyMessage = true,
    this.showThreadReplyMessage = true,
    this.showResendMessage = true,
    this.showCopyMessage = true,
    this.showFlagButton = true,
    this.showPinButton = true,
    this.showPinHighlight = true,
    this.onUserAvatarTap,
    this.onLinkTap,
    this.onMessageActions,
    this.onShowMessage,
    this.userAvatarBuilder,
    this.editMessageInputBuilder,
    this.textBuilder,
    this.bottomRowBuilder,
    this.deletedBottomRowBuilder,
    this.onReturnAction,
    this.customAttachmentBuilders,
    this.padding,
    this.textPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    this.attachmentPadding = EdgeInsets.zero,
    @Deprecated('''
    allRead is now deprecated and it will be removed in future releases. 
    The MessageWidget now listens for read events on its own.
    ''') this.allRead = false,
    @Deprecated('''
    readList is now deprecated and it will be removed in future releases. 
    The MessageWidget now listens for read events on its own.
    ''') this.readList,
    this.onQuotedMessageTap,
    this.customActions = const [],
    this.onAttachmentTap,
    this.usernameBuilder,
  })  : attachmentBuilders = {
          'image': (context, message, attachments) {
            final border = RoundedRectangleBorder(
              borderRadius: attachmentBorderRadiusGeometry ?? BorderRadius.zero,
            );

            final mediaQueryData = MediaQuery.of(context);
            if (attachments.length > 1) {
              return Padding(
                padding: attachmentPadding,
                child: WrapAttachmentWidget(
                  attachmentWidget: Material(
                    color: messageTheme.messageBackgroundColor,
                    child: ImageGroup(
                      size: Size(
                        mediaQueryData.size.width * 0.8,
                        mediaQueryData.size.height * 0.3,
                      ),
                      images: attachments,
                      message: message,
                      messageTheme: messageTheme,
                      onShowMessage: onShowMessage,
                      onReturnAction: onReturnAction,
                      onAttachmentTap: onAttachmentTap,
                    ),
                  ),
                  attachmentShape: border,
                  reverse: reverse,
                ),
              );
            }

            return WrapAttachmentWidget(
              attachmentWidget: ImageAttachment(
                attachment: attachments[0],
                message: message,
                messageTheme: messageTheme,
                size: Size(
                  mediaQueryData.size.width * 0.8,
                  mediaQueryData.size.height * 0.3,
                ),
                onShowMessage: onShowMessage,
                onReturnAction: onReturnAction,
                onAttachmentTap: onAttachmentTap != null
                    ? () {
                        onAttachmentTap.call(message, attachments[0]);
                      }
                    : null,
              ),
              attachmentShape: border,
              reverse: reverse,
            );
          },
          'video': (context, message, attachments) {
            final border = RoundedRectangleBorder(
              borderRadius: attachmentBorderRadiusGeometry ?? BorderRadius.zero,
            );

            return WrapAttachmentWidget(
              attachmentWidget: Column(
                children: attachments.map((attachment) {
                  final mediaQueryData = MediaQuery.of(context);
                  return VideoAttachment(
                    attachment: attachment,
                    messageTheme: messageTheme,
                    size: Size(
                      mediaQueryData.size.width * 0.8,
                      mediaQueryData.size.height * 0.3,
                    ),
                    message: message,
                    onShowMessage: onShowMessage,
                    onReturnAction: onReturnAction,
                    onAttachmentTap: onAttachmentTap != null
                        ? () {
                            onAttachmentTap(message, attachment);
                          }
                        : null,
                  );
                }).toList(),
              ),
              attachmentShape: border,
              reverse: reverse,
            );
          },
          'giphy': (context, message, attachments) {
            final border = RoundedRectangleBorder(
              borderRadius: attachmentBorderRadiusGeometry ?? BorderRadius.zero,
            );

            return WrapAttachmentWidget(
              attachmentWidget: Column(
                children: attachments.map((attachment) {
                  final mediaQueryData = MediaQuery.of(context);
                  return GiphyAttachment(
                    attachment: attachment,
                    message: message,
                    size: Size(
                      mediaQueryData.size.width * 0.8,
                      mediaQueryData.size.height * 0.3,
                    ),
                    onShowMessage: onShowMessage,
                    onReturnAction: onReturnAction,
                    onAttachmentTap: onAttachmentTap != null
                        ? () {
                            onAttachmentTap(message, attachment);
                          }
                        : null,
                  );
                }).toList(),
              ),
              attachmentShape: border,
              reverse: reverse,
            );
          },
          'file': (context, message, attachments) {
            final border = RoundedRectangleBorder(
              side: attachmentBorderSide ??
                  BorderSide(
                    color: StreamChatTheme.of(context).colorTheme.borders,
                  ),
              borderRadius: attachmentBorderRadiusGeometry ?? BorderRadius.zero,
            );

            return Column(
              children: attachments
                  .map<Widget>((attachment) {
                    final mediaQueryData = MediaQuery.of(context);
                    return WrapAttachmentWidget(
                      attachmentWidget: FileAttachment(
                        message: message,
                        attachment: attachment,
                        size: Size(
                          mediaQueryData.size.width * 0.8,
                          mediaQueryData.size.height * 0.3,
                        ),
                        onAttachmentTap: onAttachmentTap != null
                            ? () {
                                onAttachmentTap(message, attachment);
                              }
                            : null,
                      ),
                      attachmentShape: border,
                      reverse: reverse,
                    );
                  })
                  .insertBetween(SizedBox(
                    height: attachmentPadding.vertical / 2,
                  ))
                  .toList(),
            );
          },
        }..addAll(customAttachmentBuilders ?? {}),
        super(key: key);

  /// {@template onMentionTap}
  /// Function called on mention tap
  /// {@endtemplate}
  final void Function(User)? onMentionTap;

  /// {@template onThreadTap}
  /// The function called when tapping on threads
  /// {@endtemplate}
  final void Function(Message)? onThreadTap;

  /// {@template onReplyTap}
  /// The function called when tapping on replies
  /// {@endtemplate}
  final void Function(Message)? onReplyTap;

  /// {@template editMessageInputBuilder}
  /// Widget builder for edit message layout
  /// {@endtemplate}
  final Widget Function(BuildContext, Message)? editMessageInputBuilder;

  /// {@template textBuilder}
  /// Widget builder for building text
  /// {@endtemplate}
  final Widget Function(BuildContext, Message)? textBuilder;

  /// {@template usernameBuilder}
  /// Widget builder for building username
  /// {@endtemplate}
  final Widget Function(BuildContext, Message)? usernameBuilder;

  /// {@template onMessageActions}
  /// Function called on long press
  /// {@endtemplate}
  final void Function(BuildContext, Message)? onMessageActions;

  /// {@template bottomRowBuilder}
  /// Widget builder for building a bottom row below the message
  /// {@endtemplate}
  final Widget Function(BuildContext, Message)? bottomRowBuilder;

  /// {@template deletedBottomRowBuilder}
  /// Widget builder for building a bottom row below a deleted message
  /// {@endtemplate}
  final Widget Function(BuildContext, Message)? deletedBottomRowBuilder;

  /// {@template userAvatarBuilder}
  /// Widget builder for building user avatar
  /// {@endtemplate}
  final Widget Function(BuildContext, User)? userAvatarBuilder;

  /// {@template message}
  /// The message to display.
  /// {@endtemplate}
  final Message message;

  /// {@template messageTheme}
  /// The message theme
  /// {@endtemplate}
  final MessageThemeData messageTheme;

  /// {@template reverse}
  /// If true the widget will be mirrored
  /// {@endtemplate}
  final bool reverse;

  /// {@template shape}
  /// The shape of the message text
  /// {@endtemplate}
  final ShapeBorder? shape;

  /// {@template attachmentShape}
  /// The shape of an attachment
  /// {@endtemplate}
  final ShapeBorder? attachmentShape;

  /// {@template borderSide}
  /// The borderSide of the message text
  /// {@endtemplate}
  final BorderSide? borderSide;

  /// {@template attachmentBorderSide}
  /// The borderSide of an attachment
  /// {@endtemplate}
  final BorderSide? attachmentBorderSide;

  /// {@template borderRadiusGeometry}
  /// The border radius of the message text
  /// {@endtemplate}
  final BorderRadiusGeometry? borderRadiusGeometry;

  /// {@template attachmentBorderRadiusGeometry}
  /// The border radius of an attachment
  /// {@endtemplate}
  final BorderRadiusGeometry? attachmentBorderRadiusGeometry;

  /// {@template padding}
  /// The padding of the widget
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template textPadding}
  /// The internal padding of the message text
  /// {@endtemplate}
  final EdgeInsets textPadding;

  /// {@template attachmentPadding}
  /// The internal padding of an attachment
  /// {@endtemplate}
  final EdgeInsetsGeometry attachmentPadding;

  /// {@template showUserAvatar}
  /// It controls the display behaviour of the user avatar
  /// {@endtemplate}
  final DisplayWidget showUserAvatar;

  /// {@template showSendingIndicator}
  /// It controls the display behaviour of the sending indicator
  /// {@endtemplate}
  final bool showSendingIndicator;

  /// {@template showReactions}
  /// If `true` the message's reactions will be shown.
  /// {@endtemplate}
  final bool showReactions;

  ///
  final bool allRead;

  /// {@template showThreadReplyIndicator}
  /// If true the widget will show the thread reply indicator
  /// {@endtemplate}
  final bool showThreadReplyIndicator;

  /// {@template showInChannelIndicator}
  /// If true the widget will show the show in channel indicator
  /// {@endtemplate}
  final bool showInChannelIndicator;

  /// {@template onUserAvatarTap}
  /// The function called when tapping on UserAvatar
  /// {@endtemplate}
  final void Function(User)? onUserAvatarTap;

  /// {@template onLinkTap}
  /// The function called when tapping on a link
  /// {@endtemplate}
  final void Function(String)? onLinkTap;

  /// {@template showReactionPickerIndicator}
  /// Used in [MessageReactionsModal] and [MessageActionsModal]
  /// {@endtemplate}
  final bool showReactionPickerIndicator;

  /// {@template readList}
  /// List of users who have read the [message].
  /// {@endtemplate}
  final List<Read>? readList;

  /// {@template onShowMessage}
  /// Callback when show message is tapped
  /// {@endtemplate}
  final ShowMessageCallback? onShowMessage;

  /// {@template onReturnAction}
  /// Handle return actions like reply message
  /// {@endtemplate}
  final ValueChanged<ReturnActionType>? onReturnAction;

  /// {@template showUsername}
  /// If true show the users username next to the timestamp of the message
  /// {@endtemplate}
  final bool showUsername;

  /// {@template showTimestamp}
  /// Show message timestamp
  /// {@endtemplate}
  final bool showTimestamp;

  /// {@template showReplyMessage}
  /// Show reply action
  /// {@endtemplate}
  final bool showReplyMessage;

  /// {@template showThreadReplyMessage}
  /// Show thread reply action
  /// {@endtemplate}
  final bool showThreadReplyMessage;

  /// {@template showEditMessage}
  /// Show edit action
  /// {@endtemplate}
  final bool showEditMessage;

  /// {@template showCopyMessage}
  /// Show copy action
  /// {@endtemplate}
  final bool showCopyMessage;

  /// {@template showDeleteMessage}
  /// Show delete action
  /// {@endtemplate}
  final bool showDeleteMessage;

  /// {@template showResendMessage}
  /// Show resend action
  /// {@endtemplate}
  final bool showResendMessage;

  /// {@template showFlagButton}
  /// Show flag action
  /// {@endtemplate}
  final bool showFlagButton;

  /// {@template showPinButton}
  /// Show pin action
  /// {@endtemplate}
  final bool showPinButton;

  /// {@template showPinHighlight}
  /// Display Pin Highlight
  /// {@endtemplate}
  final bool showPinHighlight;

  /// {@template attachmentBuilders}
  /// Builder for respective attachment types
  /// {@endtemplate}
  final Map<String, AttachmentBuilder> attachmentBuilders;

  /// {@template customAttachmentBuilders}
  /// Builder for respective attachment types (user facing builder)
  /// {@endtemplate}
  final Map<String, AttachmentBuilder>? customAttachmentBuilders;

  /// {@template translateUserAvatar}
  /// Center user avatar with bottom of the message
  /// {@endtemplate}
  final bool translateUserAvatar;

  /// {@template onQuotedMessageTap}
  /// Function called when quotedMessage is tapped
  /// {@endtemplate}
  final OnQuotedMessageTap? onQuotedMessageTap;

  /// {@template onMessageTap}
  /// Function called when message is tapped
  /// {@endtemplate}
  final void Function(Message)? onMessageTap;

  /// {@template customActions}
  /// List of custom actions shown on message long tap
  /// {@endtemplate}
  final List<MessageAction> customActions;

  /// {@template onAttachmentTap}
  /// Customize onTap on attachment
  /// {@endtemplate}
  final void Function(Message message, Attachment attachment)? onAttachmentTap;

  /// {@template copyWith}
  /// Creates a copy of [MessageWidget] with specified attributes overridden.
  /// {@endtemplate}
  MessageWidget copyWith({
    Key? key,
    void Function(User)? onMentionTap,
    void Function(Message)? onThreadTap,
    void Function(Message)? onReplyTap,
    Widget Function(BuildContext, Message)? editMessageInputBuilder,
    Widget Function(BuildContext, Message)? textBuilder,
    Widget Function(BuildContext, Message)? usernameBuilder,
    Widget Function(BuildContext, Message)? bottomRowBuilder,
    Widget Function(BuildContext, Message)? deletedBottomRowBuilder,
    void Function(BuildContext, Message)? onMessageActions,
    Message? message,
    MessageThemeData? messageTheme,
    bool? reverse,
    ShapeBorder? shape,
    ShapeBorder? attachmentShape,
    BorderSide? borderSide,
    BorderSide? attachmentBorderSide,
    BorderRadiusGeometry? borderRadiusGeometry,
    BorderRadiusGeometry? attachmentBorderRadiusGeometry,
    EdgeInsetsGeometry? padding,
    EdgeInsets? textPadding,
    EdgeInsetsGeometry? attachmentPadding,
    DisplayWidget? showUserAvatar,
    bool? showSendingIndicator,
    bool? showReactions,
    bool? allRead,
    bool? showThreadReplyIndicator,
    bool? showInChannelIndicator,
    void Function(User)? onUserAvatarTap,
    void Function(String)? onLinkTap,
    bool? showReactionPickerIndicator,
    List<Read>? readList,
    ShowMessageCallback? onShowMessage,
    ValueChanged<ReturnActionType>? onReturnAction,
    bool? showUsername,
    bool? showTimestamp,
    bool? showReplyMessage,
    bool? showThreadReplyMessage,
    bool? showEditMessage,
    bool? showCopyMessage,
    bool? showDeleteMessage,
    bool? showResendMessage,
    bool? showFlagButton,
    bool? showPinButton,
    bool? showPinHighlight,
    Map<String, AttachmentBuilder>? customAttachmentBuilders,
    bool? translateUserAvatar,
    OnQuotedMessageTap? onQuotedMessageTap,
    void Function(Message)? onMessageTap,
    List<MessageAction>? customActions,
    void Function(Message message, Attachment attachment)? onAttachmentTap,
    Widget Function(BuildContext, User)? userAvatarBuilder,
  }) {
    return MessageWidget(
      key: key ?? this.key,
      onMentionTap: onMentionTap ?? this.onMentionTap,
      onThreadTap: onThreadTap ?? this.onThreadTap,
      onReplyTap: onReplyTap ?? this.onReplyTap,
      editMessageInputBuilder:
          editMessageInputBuilder ?? this.editMessageInputBuilder,
      textBuilder: textBuilder ?? this.textBuilder,
      usernameBuilder: usernameBuilder ?? this.usernameBuilder,
      bottomRowBuilder: bottomRowBuilder ?? this.bottomRowBuilder,
      deletedBottomRowBuilder:
          deletedBottomRowBuilder ?? this.deletedBottomRowBuilder,
      onMessageActions: onMessageActions ?? this.onMessageActions,
      message: message ?? this.message,
      messageTheme: messageTheme ?? this.messageTheme,
      reverse: reverse ?? this.reverse,
      shape: shape ?? this.shape,
      attachmentShape: attachmentShape ?? this.attachmentShape,
      borderSide: borderSide ?? this.borderSide,
      attachmentBorderSide: attachmentBorderSide ?? this.attachmentBorderSide,
      borderRadiusGeometry: borderRadiusGeometry ?? this.borderRadiusGeometry,
      attachmentBorderRadiusGeometry:
          attachmentBorderRadiusGeometry ?? this.attachmentBorderRadiusGeometry,
      padding: padding ?? this.padding,
      textPadding: textPadding ?? this.textPadding,
      attachmentPadding: attachmentPadding ?? this.attachmentPadding,
      showUserAvatar: showUserAvatar ?? this.showUserAvatar,
      showSendingIndicator: showSendingIndicator ?? this.showSendingIndicator,
      showReactions: showReactions ?? this.showReactions,
      showThreadReplyIndicator:
          showThreadReplyIndicator ?? this.showThreadReplyIndicator,
      showInChannelIndicator:
          showInChannelIndicator ?? this.showInChannelIndicator,
      onUserAvatarTap: onUserAvatarTap ?? this.onUserAvatarTap,
      onLinkTap: onLinkTap ?? this.onLinkTap,
      showReactionPickerIndicator:
          showReactionPickerIndicator ?? this.showReactionPickerIndicator,
      onShowMessage: onShowMessage ?? this.onShowMessage,
      onReturnAction: onReturnAction ?? this.onReturnAction,
      showUsername: showUsername ?? this.showUsername,
      showTimestamp: showTimestamp ?? this.showTimestamp,
      showReplyMessage: showReplyMessage ?? this.showReplyMessage,
      showThreadReplyMessage:
          showThreadReplyMessage ?? this.showThreadReplyMessage,
      showEditMessage: showEditMessage ?? this.showEditMessage,
      showCopyMessage: showCopyMessage ?? this.showCopyMessage,
      showDeleteMessage: showDeleteMessage ?? this.showDeleteMessage,
      showResendMessage: showResendMessage ?? this.showResendMessage,
      showFlagButton: showFlagButton ?? this.showFlagButton,
      showPinButton: showPinButton ?? this.showPinButton,
      showPinHighlight: showPinHighlight ?? this.showPinHighlight,
      customAttachmentBuilders:
          customAttachmentBuilders ?? this.customAttachmentBuilders,
      translateUserAvatar: translateUserAvatar ?? this.translateUserAvatar,
      onQuotedMessageTap: onQuotedMessageTap ?? this.onQuotedMessageTap,
      onMessageTap: onMessageTap ?? this.onMessageTap,
      customActions: customActions ?? this.customActions,
      onAttachmentTap: onAttachmentTap ?? this.onAttachmentTap,
      userAvatarBuilder: userAvatarBuilder ?? this.userAvatarBuilder,
    );
  }

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget>
    with AutomaticKeepAliveClientMixin<MessageWidget> {
  bool get showThreadReplyIndicator => widget.showThreadReplyIndicator;

  bool get showSendingIndicator => widget.showSendingIndicator;

  bool get isDeleted => widget.message.isDeleted;

  bool get showUsername => widget.showUsername;

  bool get showTimeStamp => widget.showTimestamp;

  bool get showInChannel => widget.showInChannelIndicator;

  /// {@template hasQuotedMessage}
  /// `true` if [MessageWidget.quotedMessage] is not null.
  /// {@endtemplate}
  bool get hasQuotedMessage => widget.message.quotedMessage != null;

  bool get isSendFailed => widget.message.status == MessageSendingStatus.failed;

  bool get isUpdateFailed =>
      widget.message.status == MessageSendingStatus.failed_update;

  bool get isDeleteFailed =>
      widget.message.status == MessageSendingStatus.failed_delete;

  /// {@template isFailedState}
  /// Whether the message has failed to be sent, updated, or deleted.
  /// {@endtemplate}
  bool get isFailedState => isSendFailed || isUpdateFailed || isDeleteFailed;

  /// {@template isGiphy}
  /// `true` if any of the [message]'s attachments are a giphy.
  /// {@endtemplate}
  bool get isGiphy =>
      widget.message.attachments.any((element) => element.type == 'giphy');

  /// {@template isOnlyEmoji}
  /// `true` if [message.text] contains only emoji.
  /// {@endtemplate}
  bool get isOnlyEmoji => widget.message.text?.isOnlyEmoji == true;

  /// {@template hasNonUrlAttachments}
  /// `true` if any of the [message]'s attachments are a giphy and do not
  /// have a [Attachment.titleLink].
  /// {@endtemplate}
  bool get hasNonUrlAttachments => widget.message.attachments
      .where((it) => it.titleLink == null || it.type == 'giphy')
      .isNotEmpty;

  /// {@template hasUrlAttachments}
  /// `true` if any of the [message]'s attachments are a giphy with a
  /// [Attachment.titleLink].
  /// {@endtemplate}
  bool get hasUrlAttachments => widget.message.attachments
      .any((it) => it.titleLink != null && it.type != 'giphy');

  /// {@template showBottomRow}
  /// Show the [BottomRow] widget if any of the following are `true`:
  /// * [MessageWidget.showThreadReplyIndicator]
  /// * [MessageWidget.showUsername]
  /// * [MessageWidget.showTimestamp]
  /// * [MessageWidget.showInChannelIndicator]
  /// * [MessageWidget.showSendingIndicator]
  /// * [MessageWidget.message.isDeleted]
  /// {@endtemplate}
  bool get showBottomRow =>
      showThreadReplyIndicator ||
      showUsername ||
      showTimeStamp ||
      showInChannel ||
      showSendingIndicator ||
      isDeleted;

  /// {@template isPinned}
  /// Whether [MessageWidget.message] is pinned or not.
  /// {@endtemplate}
  bool get isPinned => widget.message.pinned;

  /// {@template shouldShowReactions}
  /// Should show message reactions if [MessageWidget.showReactions] is
  /// `true`, if there are reactions to show, and if the message is not deleted.
  /// {@endtemplate}
  bool get shouldShowReactions =>
      widget.showReactions &&
      (widget.message.reactionCounts?.isNotEmpty == true) &&
      !widget.message.isDeleted;

  @override
  bool get wantKeepAlive => widget.message.attachments.isNotEmpty;

  late StreamChatThemeData _streamChatTheme;
  late StreamChatState _streamChat;

  @override
  void didChangeDependencies() {
    _streamChatTheme = StreamChatTheme.of(context);
    _streamChat = StreamChat.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final avatarWidth =
        widget.messageTheme.avatarTheme?.constraints.maxWidth ?? 40;
    final bottomRowPadding =
        widget.showUserAvatar != DisplayWidget.gone ? avatarWidth + 8.5 : 0.5;

    final showReactions = shouldShowReactions;

    return ContextMenuRegion(
      onItemSelected: (item) => item.onSelected!.call(),
      menuItems: [
        // Ensure menu items don't show if message is deleted.
        if (!widget.message.isDeleted) ...[
          if (widget.onReplyTap != null)
            ReplyContextMenuItem(
              title: context.translations.replyLabel,
              onClick: () {
                widget.onReplyTap!(widget.message);
              },
            ),
          if (widget.onThreadTap != null)
            ThreadReplyMenuItem(
              title: context.translations.threadReplyLabel,
              // NEEDS REVIEW ⚠️
              onClick: () => widget.onThreadTap!(widget.message),
            ),
          PinMessageMenuItem(
            context: context,
            message: widget.message,
            pinned: widget.message.pinned,
            title: context.translations.togglePinUnpinText(
              pinned: widget.message.pinned,
            ),
          ),

          // Ensure "Copy Message" menu doesn't show if:
          // * There is no text to copy (like in the case of a message
          //   containing only an attachment)
          if (widget.message.attachments.isEmpty &&
              widget.message.text!.isNotEmpty)
            CopyMessageMenuItem(
              title: context.translations.copyMessageLabel,
              message: widget.message,
            ),
          // Ensure "Copy Message menu does show if:
          // * There are attachments
          // * There is text to copy
          if (widget.message.attachments.isNotEmpty &&
              widget.message.text!.isNotEmpty)
            CopyMessageMenuItem(
              title: context.translations.copyMessageLabel,
              message: widget.message,
            ),
          EditMessageMenuItem(
            title: context.translations.editMessageLabel,
            onClick: () {
              showModalBottomSheet(
                context: context,
                elevation: 2,
                clipBehavior: Clip.hardEdge,
                isScrollControlled: true,
                backgroundColor:
                    MessageInputTheme.of(context).inputBackgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                builder: (_) => EditMessageSheet(
                  message: widget.message,
                  channel: StreamChannel.of(context).channel,
                ),
              );
            },
          ),
          if (widget.showResendMessage && (isSendFailed || isUpdateFailed))
            ResendMessageMenuItem(
              title: context.translations.toggleResendOrResendEditedMessage(
                isUpdateFailed:
                    widget.message.status == MessageSendingStatus.failed_update,
              ),
              onClick: () {
                final isUpdateFailed =
                    widget.message.status == MessageSendingStatus.failed_update;
                final channel = StreamChannel.of(context).channel;
                if (isUpdateFailed) {
                  channel.updateMessage(widget.message);
                } else {
                  channel.sendMessage(widget.message);
                }
              },
            ),
          DeleteMessageMenuItem(
            title: context.translations.deleteMessageLabel,
            onClick: () async {
              final deleted = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const DeleteMessageDialog(),
              );
              if (deleted) {
                try {
                  await StreamChannel.of(context)
                      .channel
                      .deleteMessage(widget.message);
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (_) => const MessageDialog(),
                  );
                }
              }
            },
          ),
        ],
      ],
      child: Material(
        type: widget.message.pinned && widget.showPinHighlight
            ? MaterialType.card
            : MaterialType.transparency,
        color: widget.message.pinned && widget.showPinHighlight
            ? _streamChatTheme.colorTheme.highlight
            : null,
        child: Portal(
          child: PlatformWidgetBuilder(
            mobile: (context, child) {
              return InkWell(
                onTap: () => widget.onMessageTap!(widget.message),
                onLongPress: widget.message.isDeleted && !isFailedState
                    ? null
                    : () => onLongPress(context),
                child: child,
              );
            },
            desktop: (_, child) => MouseRegion(child: child),
            web: (_, child) => MouseRegion(child: child),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(8),
              child: FractionallySizedBox(
                alignment: widget.reverse
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                widthFactor: 0.78,
                child: MessageWidgetContent(
                  streamChatTheme: _streamChatTheme,
                  showUsername: showUsername,
                  showTimeStamp: showTimeStamp,
                  showThreadReplyIndicator: showThreadReplyIndicator,
                  showSendingIndicator: showSendingIndicator,
                  showInChannel: showInChannel,
                  isGiphy: isGiphy,
                  isOnlyEmoji: isOnlyEmoji,
                  hasUrlAttachments: hasUrlAttachments,
                  messageTheme: widget.messageTheme,
                  reverse: widget.reverse,
                  message: widget.message,
                  hasNonUrlAttachments: hasNonUrlAttachments,
                  shouldShowReactions: shouldShowReactions,
                  hasQuotedMessage: hasQuotedMessage,
                  textPadding: widget.textPadding,
                  attachmentBuilders: widget.attachmentBuilders,
                  attachmentPadding: widget.attachmentPadding,
                  avatarWidth: avatarWidth,
                  bottomRowPadding: bottomRowPadding,
                  isFailedState: isFailedState,
                  isPinned: isPinned,
                  messageWidget: widget,
                  showBottomRow: showBottomRow,
                  showPinHighlight: widget.showPinHighlight,
                  showReactionPickerIndicator:
                      widget.showReactionPickerIndicator,
                  showReactions: showReactions,
                  showUserAvatar: widget.showUserAvatar,
                  streamChat: _streamChat,
                  translateUserAvatar: widget.translateUserAvatar,
                  deletedBottomRowBuilder: widget.deletedBottomRowBuilder,
                  onThreadTap: widget.onThreadTap,
                  shape: widget.shape,
                  borderSide: widget.borderSide,
                  borderRadiusGeometry: widget.borderRadiusGeometry,
                  textBuilder: widget.textBuilder,
                  onLinkTap: widget.onLinkTap,
                  onMentionTap: widget.onMentionTap,
                  onQuotedMessageTap: widget.onQuotedMessageTap,
                  bottomRowBuilder: widget.bottomRowBuilder,
                  onUserAvatarTap: widget.onUserAvatarTap,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onLongPress(BuildContext context) {
    if (widget.message.isEphemeral ||
        widget.message.status == MessageSendingStatus.sending) {
      return;
    }

    if (widget.onMessageActions != null) {
      widget.onMessageActions!(context, widget.message);
    } else {
      _showMessageActionModalBottomSheet(context);
    }
    return;
  }

  void _showMessageActionModalBottomSheet(BuildContext context) {
    final channel = StreamChannel.of(context).channel;

    showDialog(
      useRootNavigator: false,
      context: context,
      barrierColor: _streamChatTheme.colorTheme.overlay,
      builder: (context) => StreamChannel(
        channel: channel,
        child: MessageActionsModal(
          messageWidget: widget.copyWith(
            key: const Key('MessageWidget'),
            message: widget.message.copyWith(
              text: (widget.message.text?.length ?? 0) > 200
                  ? '${widget.message.text!.substring(0, 200)}...'
                  : widget.message.text,
            ),
            showReactions: false,
            showUsername: false,
            showTimestamp: false,
            translateUserAvatar: false,
            showSendingIndicator: false,
            padding: const EdgeInsets.all(0),
            showReactionPickerIndicator: widget.showReactions &&
                (widget.message.status == MessageSendingStatus.sent),
            showPinHighlight: false,
            showUserAvatar:
                widget.message.user!.id == channel.client.state.currentUser!.id
                    ? DisplayWidget.gone
                    : DisplayWidget.show,
          ),
          onCopyTap: (message) =>
              Clipboard.setData(ClipboardData(text: message.text)),
          messageTheme: widget.messageTheme,
          reverse: widget.reverse,
          showDeleteMessage: widget.showDeleteMessage || isDeleteFailed,
          message: widget.message,
          editMessageInputBuilder: widget.editMessageInputBuilder,
          onReplyTap: widget.onReplyTap,
          onThreadReplyTap: widget.onThreadTap,
          showResendMessage:
              widget.showResendMessage && (isSendFailed || isUpdateFailed),
          showCopyMessage: widget.showCopyMessage &&
              !isFailedState &&
              widget.message.text?.trim().isNotEmpty == true,
          showEditMessage: widget.showEditMessage &&
              !isDeleteFailed &&
              !widget.message.attachments
                  .any((element) => element.type == 'giphy'),
          showReactions: widget.showReactions,
          showReplyMessage: widget.showReplyMessage &&
              !isFailedState &&
              widget.onReplyTap != null,
          showThreadReplyMessage: widget.showThreadReplyMessage &&
              !isFailedState &&
              widget.onThreadTap != null,
          showFlagButton: widget.showFlagButton,
          showPinButton: widget.showPinButton,
          customActions: widget.customActions,
        ),
      ),
    );
  }

  void retryMessage(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    if (widget.message.status == MessageSendingStatus.failed) {
      channel.sendMessage(widget.message);
      return;
    }
    if (widget.message.status == MessageSendingStatus.failed_update) {
      channel.updateMessage(widget.message);
      return;
    }

    if (widget.message.status == MessageSendingStatus.failed_delete) {
      channel.deleteMessage(widget.message);
      return;
    }
  }
}
