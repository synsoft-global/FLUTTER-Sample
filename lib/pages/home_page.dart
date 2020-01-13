import 'package:blog_app/models/blogs.dart';
import 'package:blog_app/models/user_model.dart';
import 'package:blog_app/services/authentication.dart';
import 'package:blog_app/utils/app_utils.dart';
import 'package:blog_app/utils/const.dart';
import 'package:blog_app/utils/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Home screen class
class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    this.auth,
    this.userId,
    this.onProfileClick,
  }) : super(key: key);

  final BaseAuth auth;
  final VoidCallback onProfileClick;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Blogs> _blogList = new List();
  bool _isLoading;
  Firestore _database = Firestore.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  UserModel loginUser;
  ScrollController _hideButtonController;
  bool _isVisible;

  @override
  void initState() {
    super.initState();
    getBlogsData();
    getUser().then(
      (userData) {
        loginUser = userData;
        _database
            .collection(TABLE_MESSAGE)
            .where('idFrom', isEqualTo: loginUser.id)
            .where('idTo', isEqualTo: loginUser.id)
            .snapshots()
            .listen(
          (data) {
            print('message ${data.documents.length}');
          },
        );
      },
    );
    setScrollListener();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _openProfile() {

    widget.onProfileClick();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text(
          TITLE_HOME,
          style: Theme.of(context).textTheme.headline,
        ),
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: _openProfile,
            iconSize: 26,
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          _buildListRow(),
          getCircularProgress(_isLoading),
        ],
      ),
      floatingActionButton: new Visibility(
        visible: _isVisible,
        child: FloatingActionButton(
          backgroundColor: themeColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(

              ),
            );
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  static String isNullOrEmptyText(String value) {
    if (value == null || value.length == 0)
      return '';
    else
      return value;
  }

  /// build row for list
  /// @author : Kailash
  /// @creationDate :13-Feb-2019
  Widget _buildListRow() {
    if (_blogList != null && _blogList.length > 0) {
      return new ListView.builder(
        controller: _hideButtonController,
        shrinkWrap: true,
        padding: EdgeInsets.all(8.0),
        itemCount: _blogList.length,
        itemBuilder: (BuildContext context, int index) {
          Blogs blog = _blogList[index];
          bool isLike = false;
          for (var userId in blog.likes) {
            if (userId == loginUser.id) {
              isLike = true;
              break;
            }
          }
          return GestureDetector(
            child: SizedBox(
              width: screenWidth(context),
              child: new Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 2.0,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildImageContainer(blog.image),
                    new Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(
                              text: blog.title,
                              style: Theme.of(context).textTheme.title,
                            ),
                          ],
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(
                              text: blog.description,
                              style: Theme.of(context).textTheme.subtitle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 6.0),
                      child: Text(
                        getFormattedDateTime(blog.createdAt),
                        style: Theme.of(context)
                            .textTheme
                            .overline
                            .apply(letterSpacingFactor: 0.0),
                      ),
                    ),
                    Divider(),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            IconButton(
                              icon: isLike
                                  ? Icon(Icons.favorite)
                                  : Icon(Icons.favorite_border),
                              color: themeColor,
                            ),
                            GestureDetector(
                              child: Container(
                                height: 20.0,
                                child: Text(
                                  '${blog.likes.length} Likes',
                                ),
                              ),

                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.comment),
                              color: themeColor,

                            ),
                            new GestureDetector(
                              child: Container(
                                height: 20.0,
                                child: Text(
                                  '${blog.comments.length} Comments',
                                ),
                              ),

                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.share),
                          color: themeColor,

                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          );
        },
      );
    } else {
      return Center(
        child: Text(
          "Welcome. Your list is empty",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.title,
        ),
      );
    }
  }




  updateBlog(Blogs note) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx
          .get(Firestore.instance.collection(TABLE_BLOG).document(note.id));

      await tx.update(ds.reference, blogsToMap(note));
      return {'updated': true};
    };

    return Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => setState(() {
              _isLoading = false;
            }))
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  _deleteLike(Blogs blogs) {
    _database
        .collection(TABLE_LIKE)
        .where("userId", isEqualTo: loginUser.id)
        .where("blogId", isEqualTo: blogs.id)
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
      List<String> list = new List();
      list.addAll(blogs.likes);
      // remove like object to list
      list.remove(loginUser.id);
      // set like object to blogs
      blogs.likes = list;
      updateBlog(blogs);
    }).catchError((e) {
      print(e);
    });
  }

  /// build image widget if image is available
  /// @imagePath : server imagePath
  /// @author : surendra
  /// @creationDate :13-Feb-2019
  Widget _buildImageContainer(String imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return new Container();
    } else {
      return Container(
        child: Material(
          child: CachedNetworkImage(
            placeholder: (context, url) => Container(
              width: screenWidth(context),
              height: 150.0,
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
                width: screenWidth(context),
                height: 150.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
            ),
            imageUrl: imagePath,
            width: screenWidth(context),
            height: 150.0,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
          clipBehavior: Clip.hardEdge,
          elevation: 1.0,
        ),
      );
    }
  }

  void setScrollListener() {
    _isVisible = true;
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _isVisible = false;
          print("**** $_isVisible up");
        });
      }
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _isVisible = true;
          print("**** $_isVisible down");
        });
      }
    });
  }

  void getBlogsData() {
    _isLoading = true;
    _database
        .collection(TABLE_BLOG)
        .where('completed', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((data) {
      setState(() {
        _isLoading = false;
      });
      _blogList.clear();
      data.documents.forEach((doc) {
        Blogs blogs = fromJson(doc.data);
        setState(() {
          _blogList.add(blogs);
        });
      });
    });
  }
}
