import 'dart:async';
import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notification/ImageEditorPack/image_editorHome.dart';
import 'package:notification/controllers/firebaseController.dart';
import 'package:notification/controllers/gradeMaker.dart';
import 'package:notification/pages/feedBacker.dart';
import 'package:notification/pages/reports.dart';
import 'package:notification/screens/groupEarnings.dart';
import 'package:notification/util/admob_service.dart';
import 'package:notification/util/data.dart';
import 'package:notification/widgets/chat_bubble.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'groupMembersHome.dart';
import 'joinPremium.dart';
import 'joinRequestApproval.dart';

class Conversation extends StatefulWidget {
  Conversation(
      {Key key,
      this.groupFullDetails,
      this.followingGroupsLocal,
      this.msgFullCount,
      this.msgReadCount,
      this.msgFullPmCount,
      this.chatId,
      this.groupSportCategory,
      this.userId,
      this.groupLogo,
      this.groupTitle,
      this.senderMailId,
      this.chatType,
      this.waitingGroups,
      this.approvedGroups,
      this.followers,
      this.chatOwnerId,
      this.approvedGroupsJson,
      this.AllDeviceTokens,
      this.FDeviceTokens,
      this.followersCount});
  var chatId,
      userId,
      chatType,
      chatOwnerId,
      senderMailId,
      groupTitle,
      groupLogo;
  List waitingGroups,
      approvedGroups,
      AllDeviceTokens,
      FDeviceTokens,
      groupSportCategory,
      followers;
  List followingGroupsLocal;
  List approvedGroupsJson;
  var msgFullCount, msgReadCount, msgFullPmCount;
  var groupFullDetails;
  var followersCount;

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final ams = AdMobService();
  final TextEditingController _chatMessageText = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  File _image;
  int selectedRadio = 2;
  String msgDeliveryMode = "All";
  List votingBalletHeapData;
  List groupCategoriesArray = [];
  int selectedRadioTile;
  List feeDetails;
  int messageCount, nonPrimeMsgCount = 0;
  List nonPrimeMessageContent;
  var groupGrade;

  // Changes the selected value on 'onChanged' click on each radio button
  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
      if (val == 2) {
        scrollToBottomFun();
        msgDeliveryMode = "Prime";
      } else if (val == 1) {
        msgDeliveryMode = "All";
        scrollToBottomFun();
      } else if (val == 3) {
        msgDeliveryMode = "Non-Prime";
      }
    });
  }

  scrollToBottomFun() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    });
  }

  static Random random = Random();
  String name = names[random.nextInt(10)];

  Color backgroundColor() {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Colors.grey[700];
    } else {
      return Colors.black;
    }
  }

  upadateFeeDetails(feeDetailsv) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('thisFee', feeDetailsv[0]['fee'].toString());
    prefs.setString('thisFeeDays', feeDetailsv[0]['days'].toString());
    feeDetails = feeDetailsv;
  }

  getFeeDeatils() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var fee = prefs.getString('thisFee');
    var details = prefs.getString('thisFeeDays');

    feeDetails = [
      {'fee': fee}
    ];
  }

  fetIt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var fee = prefs.getString('thisFee');
    return fee;
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    Admob.initialize(ams.getAdMobAppId());

    loadGrade();

    upadateFeeDetails([
      {'fee': 0, 'days': 0}
    ]);

    if ((widget.approvedGroups.contains(widget.userId))) {
      //  prime group
      selectedRadio = 2;
      selectedRadioTile = 2;
      setSelectedRadio(2);
    } else if ((widget.chatOwnerId == widget.userId)) {
      selectedRadio = 3;
      selectedRadioTile = 3;
      setSelectedRadio(3);
    } else {
      selectedRadio = 3;
      selectedRadioTile = 3;
      setSelectedRadio(3);
    }

    if (widget.groupSportCategory.length != 0) {
      widget.groupSportCategory.forEach((data) {
        groupCategoriesArray.add(data['categoryName']);
      });
    }
    setReadCountToClear();
  }

  @override
  void dispose() {
    super.dispose();
  }

  setReadCountToClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("${widget.chatId}", widget.msgFullCount);
  }

  loadGrade() async {
    var grade = await followerGrades(widget.followersCount);

    setState(() {
      groupGrade = grade;
    });
  }

  profileRoute(context, origin) {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (BuildContext context) => JoinPremiumGroup(
          chatId: widget.chatId,
          userId: widget.userId,
          lock: false,
          title: widget.groupTitle,
          feeArray: widget.groupFullDetails['FeeDetails'] ?? [],
          paymentScreenshotNo: widget.groupFullDetails['paymentNo'] ?? "",
          avatarUrl: widget.groupFullDetails['logo'] ?? "",
          categories: widget.groupFullDetails['category'] ?? [],
          followers: widget.groupFullDetails['followers'] ?? [],
          groupOwnerName: widget.groupFullDetails['ownerName'] ?? '',
          seasonRating: widget.groupFullDetails['seasonRating'] ?? 'NA',
          thisWeekRating: widget.groupFullDetails['thisWeekRating'] ?? 'NA',
          lastWeekRating: widget.groupFullDetails['lastWeekRating'] ?? 'NA',
          followingGroupsLocal: widget.followingGroupsLocal,
          accessingBy: origin,
          followersCount: NumberFormat.compact().format(widget.followersCount),
        ),
      ),
      //  new  MaterialPageRoute(
      //       builder: (BuildContext context) => JoinPremiumGroup(chatId: widget.chatId,userId: widget.userId,lock: false,title: widget.groupTitle,feeArray: widget.groupFullDetails['FeeDetails'] ?? [], paymentScreenshotNo: widget.groupFullDetails['paymentNo'] ?? "", avatarUrl: widget.groupFullDetails['logo']?? "" ),
      //       ),
    );
  }

  Future<bool> _onBackPress() async {
    // await showDialog or Show add banners or whatever
    // then
    Navigator.pop(context, 'testing');
    return false; // return true if the route to be popped
  }

  Future<void> _shareImages(textData, appLink) async {
    FlutterShare.share(
        title: 'Check out',
        text: 'textData',
        linkUrl: 'https://flutter.dev/',
        chooserTitle: 'Example Chooser Title');

    return;
    try {
      final ByteData bytes1 = await rootBundle.load('assets/like.png');

      await Share.files(
          'esys images',
          {
            'esys.png': bytes1.buffer.asUint8List(),
          },
          '*/*',
          text: textData);
    } catch (e) {}
    return;
    try {
      Share.text('my text title',
          'This is my text to share with other applications.', 'text/plain');
    } catch (e) {}
    return;
    try {
      final ByteData bytes1 = await rootBundle.load('assets/like.png');
      final ByteData bytes2 = await rootBundle.load('assets/like.png');

      await Share.files(
          'esys images',
          {
            'esys.png': bytes1.buffer.asUint8List(),
            'bluedan.png': bytes2.buffer.asUint8List(),
          },
          'image/png');
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    double dw = MediaQuery.of(context).size.width;
    // getFeeDeatils();
    int setScrollDelay = widget.chatId.contains('PGrp') ? 1 : 0;
    Timer(
        Duration(seconds: setScrollDelay),
        () => {
              if (_scrollController.hasClients)
                {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(seconds: 1),
                    curve: Curves.fastOutSlowIn,
                  ),
                }
            });
    return WillPopScope(
      onWillPop: _onBackPress,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBarWid(),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: <Widget>[
              Container(
                height: 10,
              ),
// Ad here
              // AdmobBanner(adUnitId: ams.getBannerAdId(), adSize: AdmobBannerSize.FULL_BANNER),
              Expanded(
                  child: StreamBuilder(
                      stream: FirebaseController.instanace
                          .getChatContent(widget.chatId, msgDeliveryMode),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error ${snapshot.error}');
                        }
                        if (snapshot.hasData) {
                          DocumentSnapshot ds = snapshot.data;
                          // upadateFeeDetails(ds['FeeDetails']);
                          widget.groupFullDetails = ds;
                          if (snapshot.hasData &&
                              snapshot.data['messages'].length > 0) {
                            messageCount = snapshot.data['messages'].length;
                            nonPrimeMessageContent = snapshot.data['messages'];
                            return ListView.builder(
                              padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                              itemCount: snapshot.data['messages'].length,
                              controller: _scrollController,
                              // shrinkWrap: true,
                              //reverse: true,
                              itemBuilder: (BuildContext context, int index) {
                                DocumentSnapshot ds = snapshot.data;
                                var indexVal = index;
                                //  scrollToBottomFun();
                                // var datestamp = new DateFormat("dd-MM'T'HH:mm");
                                var datestamp = new DateFormat("HH:mm");
                                return ChatBubble(
                                    message: snapshot.data['messages'][indexVal]
                                                ['type'] ==
                                            "text"
                                        ? snapshot.data['messages'][indexVal]
                                            ['messageBody']
                                        : snapshot.data['messages'][indexVal]
                                            ['imageUrl'],
                                    premium: snapshot.data['messages'][indexVal]
                                        ['premium'],
                                    type: snapshot.data['messages'][indexVal]
                                        ['type'],
                                    img: snapshot.data['messages'][indexVal]
                                        ['imageUrl'],
                                    name: snapshot.data['messages'][indexVal]
                                        ['type'],
                                    dp: snapshot.data['messages'][indexVal]
                                        ['imageUrl'],
                                    messageMode: snapshot.data['messages']
                                        [indexVal]['messageMode'],
                                    time: datestamp
                                        .format(snapshot.data['messages'][indexVal]['date'].toDate())
                                        .toString(),
                                    // date: datestamp.format(snapshot.data['messages'][indexVal]['truedate'].toDate()).toString(),
                                    selMessageMode: msgDeliveryMode);

                                // fresh start check
                              },
                            );
                          }
                        }
                        return Align(
                            alignment: Alignment.center,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        4.5),
                                new Container(
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  child:
                                      SvgPicture.asset('assets/emptyBox.svg'),
                                ),
                                new Text(
                                  'Empty Chat',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
                              ],
                            ));
                      })),

              Visibility(
                visible: (widget.chatOwnerId == widget.userId),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      width: dw * 1,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text("Send To",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Color(0xff3A4276),
                                      fontWeight: FontWeight.w800,
                                    )),
                              ),
                              Theme(
                                data: Theme.of(context).copyWith(
                                    unselectedWidgetColor: Colors.black),
                                child: Row(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          value: 1,
                                          groupValue: selectedRadio,
                                          activeColor: Colors.pink[400],
                                          onChanged: (val) {
                                            setSelectedRadio(val);
                                          },
                                        ),
                                        Text("Common",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Color(0xff3A4276),
                                              fontWeight: FontWeight.w500,
                                            )),
                                        Row(
                                          children: <Widget>[
                                            Radio(
                                              value: 2,
                                              groupValue: selectedRadio,
                                              activeColor: Colors.greenAccent,
                                              onChanged: (val) {
                                                setSelectedRadio(val);
                                              },
                                            ),
                                            Text("Prime",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Color(0xff3A4276),
                                                  fontWeight: FontWeight.w500,
                                                ))
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Radio(
                                              value: 3,
                                              groupValue: selectedRadio,
                                              activeColor:
                                                  Colors.lightBlueAccent,
                                              onChanged: (val) {
                                                setSelectedRadio(val);
                                              },
                                            ),
                                            Text("Non-Prime",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Color(0xff3A4276),
                                                  fontWeight: FontWeight.w500,
                                                ))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: (widget.chatOwnerId != widget.userId),
                child: Visibility(
                  visible: !widget.chatId.contains('PGrp'),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      padding: EdgeInsets.only(
                          top: 10, left: 16, right: 16, bottom: 8),
                      child: Container(
                        height: 48,
                        decoration: new BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(2.0),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            profileRoute(context, 'member');

                            // if(lock){
                            //   // showInSnackBar('Doc already uploaded');
                            //     Scaffold.of(context).showSnackBar(SnackBar(content: Text("Doc already uploaded"),));
                            // }else{
                            //   getImage();
                            // }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Icon(
                                      FontAwesomeIcons.crown,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 13),
                              Align(
                                alignment: Alignment.center,
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 13),
                                    Text(
                                      (!widget.waitingGroups
                                              .contains(widget.chatId))
                                          ? "Upgrade To Prime"
                                          : "Under Review",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: widget.chatOwnerId == widget.userId,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomAppBar(
                    elevation: 10,
                    color: Theme.of(context).primaryColor,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: 100,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.image,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return MyImageEditorPro(
                                  appBarColor: Colors.blue,
                                  bottomBarColor: Colors.blue,
                                  groupLogo: widget.groupLogo,
                                  chatId: widget.chatId,
                                  userId: widget.userId,
                                  premiumMode: msgDeliveryMode == 'Prime',
                                  deliveryMode: msgDeliveryMode,
                                  msgFullCount: widget.msgFullCount,
                                  msgFullPmCount: widget.msgFullPmCount,
                                );
                              })).then((geteditimage) {
                                if (geteditimage != null) {
                                  setState(() {
                                    _image = geteditimage;
                                  });
                                }
                              }).catchError((er) {});
                              //  Navigator.push(
                              //     context,
                              //    new  MaterialPageRoute(
                              //         builder: (BuildContext context) => ImageEditorPage(chatId: widget.chatId,userId: widget.userId,chatType: "Image", groupLogo: widget.groupLogo),
                              //         ),
                              //  );
                            },
                          ),
                          SizedBox(
                            height: 45,
                            width: 2,
                            child: Container(
                              color: Colors.black,
                            ),
                          ),
                          Flexible(
                            child: TextField(
//                                                     onTap: () {
// Timer(
// Duration(milliseconds: 300),
// () => _scrollController
//     .jumpTo(_scrollController.position.maxScrollExtent));
// },
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Theme.of(context).textTheme.title.color,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.0),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                hintText: "message count - ${messageCount}",
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              controller: _chatMessageText,
                              maxLines: null,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // TODO: show error to user when message is not delivered
                              sendMessageFun();
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Visibility(
          visible: widget.approvedGroups.contains(widget.chatId),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: FloatingActionButton.extended(
              onPressed: () async {
                var snapShot = await FirebaseController.instanace
                    .getCurrentVotes(widget.chatId);

// this creates feedback entry for newGroup or a group which does not have entry yet in DB
                if (snapShot == null || !snapShot.exists) {
                } else {
                  votingBalletHeapData = await snapShot.data['VotingStats'];

                  // List reqGroupA =  data.where((i) => i["gameId"] == matchId).toList();
                  // List homeGroup =  data.where((i) => i["gameId"] != matchId).toList();
                }

                // powerPredictor
                await Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (BuildContext context) => PowerFeedbacker(
                        groupCategories: widget.groupSportCategory,
                        groupCategoriesArray: groupCategoriesArray,
                        groupId: widget.chatId,
                        groupTitle: widget.groupTitle,
                        votingBalletHeapData: votingBalletHeapData ?? []),
                  ),
                );
              },
              icon: Icon(FontAwesomeIcons.check),
              label: Text("Feedback"),
            ),
          ),
        ),
      ),
    );
  }

  Widget appBarWid() {
    return AppBar(
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(color: Colors.blueAccent, size: 10.0),
      elevation: 3,
      titleSpacing: 0,
      title: InkWell(
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  "${widget.groupLogo}",
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        "${widget.groupTitle.toString().toUpperCase()}",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 1.0),
                        child: Text(
                          "${NumberFormat.compact().format(widget.followersCount) ?? '0'} Followers ",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF2ecc71),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(
                          "👑 ${groupGrade} ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () {},
      ),
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.blueAccent,
            ),
            onPressed: () async {
              FlutterShare.share(
                  title: 'check our my official Group # ${widget.groupTitle} ✌',
                  text:
                      'Check out my official Group ⚡ ${widget.groupTitle} 🔥🎯✌ 👑🎁 👍',
                  linkUrl:
                      "https://play.google.com/store/apps/details?id=com.candc.chatogram",
                  chooserTitle: 'Example Chooser Title');
            }),
// START of feedback button
//                IconButton(
//               icon: Icon(
//                 Icons.notifications,
//               ),
//               onPressed: () async{
//                var  snapShot = await FirebaseController.instanace.getCurrentVotes(widget.chatId);

// // this creates feedback entry for newGroup or a group which does not have entry yet in DB
// if (snapShot == null || !snapShot.exists) {

// }else{
//   votingBalletHeapData = await  snapShot.data['VotingStats'];
//   print('full data of heap is ${votingBalletHeapData}');
//   // List reqGroupA =  data.where((i) => i["gameId"] == matchId).toList();
//   // List homeGroup =  data.where((i) => i["gameId"] != matchId).toList();
// }
//                 // powerPredictor
//                await   Navigator.push(
//                                     context,
//                                    new  MaterialPageRoute(
//                                         builder: (BuildContext context) => PowerFeedbacker(
//                                         groupCategories: widget.groupSportCategory ,
//                                         groupCategoriesArray : groupCategoriesArray,
//                                         groupId: widget.chatId,
//                                         groupTitle: widget.groupTitle,
//                                         votingBalletHeapData: votingBalletHeapData ?? []),
//                                         ),
//                                  );
//               },
//             ),

        // END of feedback button
        // display for group members
        Visibility(
          visible: widget.chatOwnerId != widget.userId,
          child: new PopupMenuButton(
              onSelected: (value) {
                if (value == "Profile") {
                  profileRoute(context, 'member');
                } else if (value == "Report") {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) => ReportScreen(
                          chatId: widget.chatId, uId: widget.userId),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                    PopupMenuItem(
                      value: "Profile",
                      child: Text("Profile",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Color(0xff3A4276),
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                    PopupMenuItem(
                      value: "Report",
                      child: Text("Report",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Color(0xff3A4276),
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                    // PopupMenuItem(
                    //   value: "Exit Group",
                    //   child: Text("Exit Group"),
                    // ),
                  ]),
        ),
        // display for group owners
        Visibility(
          visible: widget.chatOwnerId == widget.userId,
          child: new PopupMenuButton(
              onSelected: (value) {
                if (value == "Approve Payments") {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) => JoinRequestApproval(
                        chatId: widget.chatId,
                        groupName: widget.groupTitle,
                      ),
                    ),
                  );
                } else if (value == "Expired Memberships") {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (BuildContext context) => GroupMembersHome(
                          groupMembersJson: widget.approvedGroupsJson ?? [],
                          chatId: widget.chatId,
                          ownerMailId: widget.senderMailId,
                          groupTitle: widget.groupTitle,
                        ),
                      ));
                } else if (value == "Earnings") {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (BuildContext context) => GroupEarnings(),
                      ));
                } else if (value == "Edit Details") {
                  profileRoute(context, 'owner');
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                    PopupMenuItem(
                      value: "Approve Payments",
                      child: Text("Prime User Payments",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Color(0xff3A4276),
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                    PopupMenuItem(
                      value: "Expired Memberships",
                      child: Text("Prime Members",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Color(0xff3A4276),
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                    PopupMenuItem(
                      value: "Earnings",
                      child: Text("Earnings",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Color(0xff3A4276),
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                    PopupMenuItem(
                      value: "Edit Details",
                      child: Text("Edit Profile",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Color(0xff3A4276),
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ]),
        )
      ],
    );
  }

  // sendMessgeFun
  sendMessageFun() {
    try {
      if (msgDeliveryMode == "Prime") {
        widget.msgFullPmCount = widget.msgFullPmCount + 1;
      } else if (msgDeliveryMode == "Non-Prime") {
        widget.msgFullCount = widget.msgFullCount + 1;
      } else {
        widget.msgFullCount = widget.msgFullCount + 1;
        widget.msgFullPmCount = widget.msgFullPmCount + 1;
      }

      var now = new DateTime.now();
      var body = {
        "messageBody": _chatMessageText.text,
        "date": now,
        "author": widget.userId,
        "type": "text",
        "premium": (msgDeliveryMode == "Prime"),
        "messageMode": msgDeliveryMode
      };
      // var lastMessageBody ={"lastMsg":_chatMessageText.text, "lastMsgTime": now};
      var lastMessageBody = {
        "lastMsg": _chatMessageText.text,
        "lastMsgTime": now.toString(),
        "title": widget.groupTitle,
        "msgFullCount": widget.msgFullCount,
        "msgFullPmCount": widget.msgFullPmCount,
        "lastPmMsg": _chatMessageText.text
      };

      if (messageCount > 120 &&
          (msgDeliveryMode == "Prime" || msgDeliveryMode == "Non-Prime")) {
        nonPrimeMessageContent.removeAt(0);
        nonPrimeMessageContent.add(body);
        FirebaseController.instanace.sendToClear121Message(widget.chatId,
            nonPrimeMessageContent, lastMessageBody, msgDeliveryMode);
      } else {
        FirebaseController.instanace.sendChatMessage(
            widget.chatId, body, lastMessageBody, msgDeliveryMode);
      }

      _chatMessageText.text = "";
      scrollToBottomFun();
      Timer(
          Duration(milliseconds: 500),
          () => _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent));
    } catch (e) {}
  }
}
