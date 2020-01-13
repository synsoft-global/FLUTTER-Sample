import 'dart:async';
import 'dart:io';

import 'package:blog_app/utils/app_utils.dart';
import 'package:blog_app/utils/const.dart';
import 'package:blog_app/utils/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:uuid/uuid.dart';

/// build chat screen
/// @author : surendra
/// @creationDate :13-Dec-2019
class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String name;

  ChatScreen({
    Key key,
    @required this.peerId,
    @required this.peerAvatar,
    this.name,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

// class for create ChatScreenState
class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();
  Firestore _database = Firestore.instance;
  ChatUser user;
  ChatUser otherUser;
  String loginUserId;
  List<ChatMessage> messages = List<ChatMessage>();
  String groupChatId = '';

  var i = 0;

  readLocal() async {
    if (loginUserId.hashCode <= widget.peerId.hashCode) {
      groupChatId = '$loginUserId-${widget.peerId}';
    } else {
      groupChatId = '${widget.peerId}-$loginUserId';
    }
  }

  @override
  void initState() {
    getUser().then((userData) {
      setState(() {
        loginUserId = userData.id;
        readLocal();
        user = ChatUser(
          name: userData.name,
          uid: userData.id,
          avatar: userData.image,
        );
        otherUser = ChatUser(
          name: widget.name,
          uid: widget.peerId,
          avatar: widget.peerAvatar,
        );

        _database
            .collection(TABLE_MESSAGE)
            .where('groupChatId', isEqualTo: groupChatId)
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((data) {
          messages.clear();
          data.documents.forEach((doc) {
            setState(() {
              ChatMessage chatMessage;
              doc['type'] == 0
                  ? chatMessage = ChatMessage(
                      text: doc['type'] == 0 ? doc['content'] : '',
                      user: doc['idFrom'] == loginUserId ? user : otherUser,
                      createdAt: DateTime.fromMillisecondsSinceEpoch(
                        int.parse(doc['timestamp']),
                      ),
                    )
                  : chatMessage = ChatMessage(
                      text: '',
                      image: doc['type'] == 1 ? doc['content'] : '',
                      user: doc['idFrom'] == loginUserId ? user : otherUser,
                      createdAt: DateTime.fromMillisecondsSinceEpoch(
                        int.parse(doc['timestamp']),
                      ),
                    );
              messages.add(chatMessage);
            });
          });
//          systemMessage();
        });
      });
    });

    super.initState();
  }

  void systemMessage() {
    Timer(Duration(milliseconds: 300), () {
      _chatViewKey.currentState.scrollController
        ..animateTo(
          _chatViewKey.currentState.scrollController.position.minScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
    });
  }

  /// type: 0 = text, 1 = image, 2 = sticker
  void onSend(String content, int type) {
    var documentReference =
        Firestore.instance.collection(TABLE_MESSAGE).document();
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(documentReference, {
        'idFrom': loginUserId,
        'idTo': widget.peerId,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'id': documentReference.documentID,
        'groupChatId': groupChatId,
        'type': type
      });
    });
  }

  double avatarImageSize = 32;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        title: Text(
          (widget.name.isEmpty || widget.name == null)
              ? TITLE_CHAT
              : widget.name,
          style: Theme.of(context).textTheme.headline,
        ),
      ),
      body: DashChat(
        key: _chatViewKey,
        inverted: true,
        onSend: (ChatMessage message) {
          onSend(message.text, 0);
        },
        user: user,
        dateFormat: DateFormat('yyyy-MMM-dd'),
        timeFormat: DateFormat('hh:mm a'),
        messages: messages,
        scrollToBottom: false,
        showUserAvatar: false,
        showAvatarForEveryMessage: true,
        messageContainerPadding:
            const EdgeInsets.only(top: 10.0, left: 1.0, right: 1.0),
        onPressAvatar: (ChatUser user) {
          print("OnPressAvatar: ${user.name}");
        },
        onLongPressAvatar: (ChatUser user) {
          print("OnLongPressAvatar: ${user.name}");
        },
        inputMaxLines: 5,
        alwaysShowSend: true,
        inputTextStyle: Theme.of(context).textTheme.subtitle,
        inputDecoration: InputDecoration.collapsed(
          hintText: "Type a message",
        ),
        inputContainerStyle: BoxDecoration(
          border: Border.all(width: 0.0),
          color: Colors.white,
        ),
        onLoadEarlier: () {
          print("laoding...");
        },
        shouldShowLoadEarlier: false,
        showTraillingBeforeSend: true,
        inputCursorColor: themeColor,
        scrollToBottomWidget: () {
          return Container();
        },
        avatarBuilder: avatarBuilder,
        leading: <Widget>[
          IconButton(
            icon: Icon(Icons.photo),
            color: themeColor,
            onPressed: getImage,
          ),
        ],
        sendButtonBuilder: (onSendClick) {
          return IconButton(
            icon: Icon(Icons.send),
            color: themeColor,
            onPressed: onSendClick,
          );
        },
        messageImageBuilder: messageImageBuilder,
      ),
    );
  }

  /// avatar image builder
  /// @author : surendra
  /// @creationDate :13-Dec-2019
  Widget avatarBuilder(ChatUser chatUser) {
    return ((chatUser.avatar == null || chatUser.avatar.isEmpty)
        ? Container(
            child: Icon(
              Icons.account_circle,
              size: avatarImageSize,
              color: Colors.grey,
            ),
          )
        : Container(
            padding: const EdgeInsets.all(1.0),
            decoration: new BoxDecoration(
              color: themeColor, // border color
              shape: BoxShape.circle,
            ),
            child: Material(
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(
                  child: SizedBox(
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 1.0,
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    ),
                    height: 5,
                    width: 5,
                  ),
                  width: avatarImageSize,
                  height: avatarImageSize,
                  padding: EdgeInsets.all(15.0),
                ),
                imageUrl: chatUser.avatar,
                width: avatarImageSize,
                height: avatarImageSize,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              clipBehavior: Clip.hardEdge,
            ),
          ));
  }


  /// image message builder
  /// @author : surendra
  /// @creationDate :13-Dec-2019
  Widget messageImageBuilder(String imagePath) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(

          ),
        );
      },
      child: Material(
        child: CachedNetworkImage(
          placeholder: (context, url) => Container(
            width: 120.0,
            height: 160.0,
            padding: EdgeInsets.all(20.0),
            child: SizedBox(
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1.0,
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                ),
              ),
              height: 10,
              width: 10,
            ),
          ),
          errorWidget: (context, url, error) => Material(
            child: Image.asset(
              'assets/img_not_available.jpeg',
              width: 120.0,
              height: 160.0,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
            clipBehavior: Clip.hardEdge,
          ),
          imageUrl: imagePath,
          width: 120.0,
          height: 160.0,
          fit: BoxFit.cover,
        ),
        clipBehavior: Clip.hardEdge,
      ),
    );
  }

  /// get image
  /// @author : surendra
  /// @creationDate :13-Dec-2019
  Future getImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    var dir = await path_provider.getTemporaryDirectory();
    if (imageFile != null) {
      showProgress(context);
      final String uuid = Uuid().v1();
      var targetPath = dir.absolute.path + "/$uuid.jpeg";
      File imgFile = await testCompressAndGetFile(imageFile, targetPath);
      print("File Path : " + imgFile.path);
      uploadFile(imgFile);
    }
  }

  /// compress image and get path
  /// @author : surendra
  /// @creationDate :13-Dec-2019
  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    print("testCompressAndGetFile");
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
    );

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  /// upload image
  /// @author : surendra
  /// @creationDate :13-Dec-2019
  Future uploadFile(File imgFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference =
        FirebaseStorage.instance.ref().child(TABLE_CHAT_IMAGE).child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imgFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      hideProgress(context);
      onSend(downloadUrl, 1);
    }, onError: (err) {
      hideProgress(context);
    });
  }
}
