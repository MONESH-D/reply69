import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:notification/ImageEditorPack/image_editorHome.dart';
import 'package:notification/bid365_app_theme.dart';
import 'package:notification/controllers/firebaseController.dart';
import 'package:notification/pages/feedBacker.dart';
import 'package:notification/pages/imageFullView.dart';
import 'package:notification/pages/reports.dart';
import 'package:notification/util/data.dart';
import 'package:notification/widgets/chat_bubble.dart';
import 'package:notification/widgets/post_item.dart';
import 'dart:math';


import 'groupMembersHome.dart';
import 'joinPremium.dart';
import 'joinRequestApproval.dart';

class Conversation extends StatefulWidget {
  Conversation({Key key,this.groupFullDetails,
  this.followingGroupsLocal,this.msgFullCount,
  this.msgReadCount,
  this.chatId,this.groupSportCategory,this.userId,this.groupLogo,this.groupTitle,this.senderMailId, this.chatType, this.waitingGroups, this.approvedGroups,this.followers, this.chatOwnerId, this.approvedGroupsJson, this.AllDeviceTokens, this.FDeviceTokens, this.followersCount});
  var  chatId, userId,chatType, chatOwnerId, senderMailId, groupTitle, groupLogo ;
  List waitingGroups, approvedGroups, AllDeviceTokens,FDeviceTokens, groupSportCategory, followers;
  List followingGroupsLocal;
  List approvedGroupsJson;
  var msgFullCount, msgReadCount;
  var groupFullDetails;
  var followersCount;

  
  


  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
     final TextEditingController _chatMessageText = new TextEditingController();
    ScrollController _scrollController = new ScrollController();

   File _image;
   int selectedRadio;
   String msgDeliveryMode = "All";
   List votingBalletHeapData;
   List groupCategoriesArray = [];
   int selectedRadioTile;
   List feeDetails;




   // Changes the selected value on 'onChanged' click on each radio button
setSelectedRadio(int val) {
  setState(() {
    selectedRadio = val;
    if(val== 2){
      msgDeliveryMode = "Prime";
    }else if(val ==1){
      msgDeliveryMode = "All";
    }
    else if(val ==3){
      msgDeliveryMode = "Non-Prime";
    }
  });
}
setDeliveryModeCheckBox(bool val) {
  setState(() {
    // msgDeliveryMode = val;
    if(val){
      selectedRadio = 2;
    }else if(!val){
      selectedRadio = 1;
    }
  });
}

 
setSelectedRadioTile(int val) {
  setState(() {
    selectedRadioTile = val;
  });
}



scrollToBottomFun(){
  SchedulerBinding.instance.addPostFrameCallback((_) {
  _scrollController.animateTo(
    _scrollController.position.maxScrollExtent,
    duration: const Duration(milliseconds: 10),
    curve: Curves.easeOut,);
  });
}
  static Random random = Random();
  String name = names[random.nextInt(10)];

  Color backgroundColor(){
    if(Theme.of(context).brightness == Brightness.dark){
      return Colors.grey[700];
    }else{
      return Colors.grey[50];
    }
  }

void initState() {
    // TODO: implement initState
    super.initState();
  print('check ${widget.approvedGroups}');
  print('check idd ${widget.userId}');
  if((widget.approvedGroups.contains(widget.userId))) {
    print('@@@@@@@@ iwas at prime group init state2');
    print('@approveGroups ${widget.approvedGroups}');
    print('@usEr Id ${widget.userId}');

    //  prime group
        selectedRadio = 2;
  selectedRadioTile = 2;
  setSelectedRadio(2);
    } else if((widget.chatOwnerId == widget.userId)){
      print(' @@@@@@@@iwas at all group init state');
    print('@achatOwnerId ${widget.chatOwnerId}');
    print('@usEr Id ${widget.userId}');
      selectedRadio = 1;
      selectedRadioTile = 1;
      setSelectedRadio(1);
    }
    else{
        print('@@@@@@@@ iwas at non-prime  group init state');
    print('@achatOwnerId ${widget.chatOwnerId}');
    print('@usEr Id ${widget.userId}');
    print('@chat Id ${widget.chatId}');
     selectedRadio = 3;
      selectedRadioTile = 3;
      setSelectedRadio(3);
    }
    print('what was here ${widget.groupSportCategory}');
    if(widget.groupSportCategory.length != 0){
  widget.groupSportCategory.forEach((data){
    print('values are ${data}');
        groupCategoriesArray.add(data['categoryName']);
    });
    }
  
  }
 
profileRoute(context, origin){
    Navigator.push(
                                  context,
                                                                new  MaterialPageRoute(
                                      builder: (BuildContext context) => JoinPremiumGroup(chatId: widget.chatId,userId: widget.userId,lock: false,
                                      title: widget.groupTitle,feeArray: widget.groupFullDetails['FeeDetails'] ?? [], 
                                      paymentScreenshotNo: widget.groupFullDetails['paymentNo'] ?? "", 
                                      avatarUrl: widget.groupFullDetails['logo']?? "", 
                                      categories:widget.groupFullDetails['category'] ?? [],
                                      followers: widget.groupFullDetails['followers'] ?? [], 
                                      groupOwnerName : widget.groupFullDetails['groupOwnerName']?? '',
                                      seasonRating: widget.groupFullDetails['seasonRating'] ?? 'NA',
                                       thisWeekRating: widget.groupFullDetails['thisWeekRating'] ?? 'NA',
                                      lastWeekRating: widget.groupFullDetails['lastWeekRating'] ?? 'NA',
                                      followingGroupsLocal: widget.followingGroupsLocal,
                                      accessingBy: origin
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPress,
      child: Scaffold(
        backgroundColor: backgroundColor(),
        appBar: AppBar(
          elevation: 3,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_backspace,
            ),
            onPressed: ()=>Navigator.pop(context, 'testing'),
          ),
          titleSpacing: 0,
          title: InkWell(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 0.0, right: 10.0),
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
                      Text(
                        "${widget.groupTitle}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "${widget.followersCount ?? '0'} Followers",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            onTap: (){},
          ),
          actions: <Widget>[
               IconButton(
              icon: Icon(
                Icons.notifications,
              ),
              onPressed: () async{
               var  snapShot = await FirebaseController.instanace.getCurrentVotes(widget.chatId);

// this creates feedback entry for newGroup or a group which does not have entry yet in DB
if (snapShot == null || !snapShot.exists) {

}else{
  votingBalletHeapData = await  snapShot.data['VotingStats'];
  print('full data of heap is ${votingBalletHeapData}');
  // List reqGroupA =  data.where((i) => i["gameId"] == matchId).toList();
  // List homeGroup =  data.where((i) => i["gameId"] != matchId).toList();
}
                // powerPredictor
               await   Navigator.push(
                                    context,
                                   new  MaterialPageRoute(
                                        builder: (BuildContext context) => PowerFeedbacker(
                                        groupCategories: widget.groupSportCategory ,
                                        groupCategoriesArray : groupCategoriesArray,
                                        groupId: widget.chatId,
                                        groupTitle: widget.groupTitle, 
                                        votingBalletHeapData: votingBalletHeapData ?? []),
                                        ),
                                 );
              },
            ),
            // display for group members
            Visibility(
              visible: widget.chatOwnerId != widget.userId,
              child:
            new PopupMenuButton(
              onSelected: (value){
                print('selected value si   $value');
                if(value == "Profile"){
                  profileRoute(context, 'member');
                }else if(value == "Report"){
                    Navigator.push(
                                      context,
                                     new  MaterialPageRoute(
                                          builder: (BuildContext context) => 
                                          ReportScreen(chatId: widget.chatId,uId: widget.userId),
                                          ),
                                   );
                }
              },
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                      const 
                      PopupMenuItem(
                        value: "Profile",
                        child: Text("Profile"),
                      ),
                      PopupMenuItem(
                        value: "Report",
                        child: Text("Report"),
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
              child:
            new PopupMenuButton(
              onSelected: (value){
                print('selected value is ${widget.chatOwnerId}  $value');
                if(value == "Approve Payments"){
                 Navigator.push(
                                      context,
                                     new  MaterialPageRoute(
                                          builder: (BuildContext context) => 
                                          JoinRequestApproval(chatId: widget.chatId,),
                                          ),
                                   );
                } else if (value == "Expired Memberships"){
                   Navigator.push(
                                      context,
                                     new  MaterialPageRoute(
                                          builder: (BuildContext context) => 
                                          GroupMembersHome(groupMembersJson : widget.approvedGroupsJson ?? [], chatId: widget.chatId, ownerMailId: widget.senderMailId),
                                          ),
                                   );
                }else if (value == "Edit Details"){
                     profileRoute(context, 'owner');
                }
              },
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                      const 
                      PopupMenuItem(
                        value: "Approve Payments",
                        child: Text("Approve Payments"),
                      ),
                      PopupMenuItem(
                        value: "Expired Memberships",
                        child: Text("Expired Membersips"),
                      ),
                      PopupMenuItem(
                        value: "Edit Details",
                        child: Text("Edit Profile"),
                      ),
                    ]),
            )
          
          ],
        ),


        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Container(
                height: 10,
              ),

              Flexible(
                child: StreamBuilder(
          stream: FirebaseController.instanace.getChatContent(widget.chatId) ,
          builder: (context,snapshot){
                       if (snapshot.hasError) {
            return Text('Error ${snapshot.error}');
          }
          if(snapshot.hasData ){
             DocumentSnapshot ds = snapshot.data;
                        feeDetails = ds['FeeDetails'];
                        print('fee details ${feeDetails}');


                        widget.groupFullDetails = ds;

            if(snapshot.hasData && snapshot.data['messages'].length > 0){
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: snapshot.data['messages'].length,
                  controller: _scrollController,
                  // reverse: true,
                  itemBuilder: (BuildContext context, int index) {
               //     Map msg = conversation[index];
                        DocumentSnapshot ds = snapshot.data;
                        var indexVal = index;
                        feeDetails = ds['FeeDetails'];
                        print('fee details ${ds}');
                        print('value of messages are ${ds['messages'] ?? "empty"}');
                        scrollToBottomFun();
                          // var datestamp = new DateFormat("dd-MM'T'HH:mm");
                          var datestamp = new DateFormat("HH:mm");
  // return PostItem(
  //           message: snapshot.data['messages'][indexVal]['type'] == "text"
  //                       ?snapshot.data['messages'][indexVal]['messageBody']
  //                       :snapshot.data['messages'][indexVal]['imageUrl'],
  //           premium:  snapshot.data['messages'][indexVal]['premium'] ,          
  //           type : snapshot.data['messages'][indexVal]['type'],
  //           img: snapshot.data['messages'][indexVal]['imageUrl'],
  //           name: snapshot.data['messages'][indexVal]['type'],
  //           dp: snapshot.data['messages'][indexVal]['imageUrl'],
  //           time: datestamp.format(snapshot.data['messages'][indexVal]['date'].toDate()).toString(),
  //         );



  // fresh start check
  widget.groupFullDetails = snapshot.data;

   if(((widget.approvedGroups.contains(widget.userId)) || (widget.chatOwnerId == widget.userId)) && (snapshot.data['messages'][indexVal]['messageMode'] ==  'Prime' || snapshot.data['messages'][indexVal]['messageMode'] ==  'All') && (msgDeliveryMode =="Prime")){
          //  owner display for Prime
             print(' i was at prime');
              return PostItem(
              message: snapshot.data['messages'][indexVal]['type'] == "text"
                          ?snapshot.data['messages'][indexVal]['messageBody']
                          :snapshot.data['messages'][indexVal]['imageUrl'],
              premium:  snapshot.data['messages'][indexVal]['premium'] ,          
              type : snapshot.data['messages'][indexVal]['type'],
              img: snapshot.data['messages'][indexVal]['imageUrl'],
              name: snapshot.data['messages'][indexVal]['type'],
              dp: snapshot.data['messages'][indexVal]['imageUrl'],
              messageMode: snapshot.data['messages'][indexVal]['messageMode'],
              time: datestamp.format(snapshot.data['messages'][indexVal]['date'].toDate()).toString(),
              selMessageMode: msgDeliveryMode
                    );
         }else if(((widget.approvedGroups.contains(widget.userId)) || (widget.chatOwnerId == widget.userId)) && (snapshot.data['messages'][indexVal]['messageMode'] ==  'Non-Prime' || snapshot.data['messages'][indexVal]['messageMode'] ==  'All') && (msgDeliveryMode =="Non-Prime")){
          //  owner display for Prime
             print(' i was at non- prime');
              return PostItem(
              message: snapshot.data['messages'][indexVal]['type'] == "text"
                          ?snapshot.data['messages'][indexVal]['messageBody']
                          :snapshot.data['messages'][indexVal]['imageUrl'],
              premium:  snapshot.data['messages'][indexVal]['premium'] ,          
              type : snapshot.data['messages'][indexVal]['type'],
              img: snapshot.data['messages'][indexVal]['imageUrl'],
              name: snapshot.data['messages'][indexVal]['type'],
              dp: snapshot.data['messages'][indexVal]['imageUrl'],
              messageMode: snapshot.data['messages'][indexVal]['messageMode'],
              time: datestamp.format(snapshot.data['messages'][indexVal]['date'].toDate()).toString(),
              selMessageMode: msgDeliveryMode
                    );
         }
         else if(((widget.approvedGroups.contains(widget.userId)) || (widget.chatOwnerId == widget.userId)) && ( snapshot.data['messages'][indexVal]['messageMode'] ==  'All') && (msgDeliveryMode =="All")){
          //  owner display for All
             print(' i was at All');
              return PostItem(
              message: snapshot.data['messages'][indexVal]['type'] == "text"
                          ?snapshot.data['messages'][indexVal]['messageBody']
                          :snapshot.data['messages'][indexVal]['imageUrl'],
              premium:  snapshot.data['messages'][indexVal]['premium'] ,          
              type : snapshot.data['messages'][indexVal]['type'],
              img: snapshot.data['messages'][indexVal]['imageUrl'],
              name: snapshot.data['messages'][indexVal]['type'],
              dp: snapshot.data['messages'][indexVal]['imageUrl'],
              messageMode: snapshot.data['messages'][indexVal]['messageMode'],
              time: datestamp.format(snapshot.data['messages'][indexVal]['date'].toDate()).toString(),
              selMessageMode: msgDeliveryMode
                    );
         }
         else if((!(widget.approvedGroups.contains(widget.userId)) || !(widget.chatOwnerId == widget.userId)) && (( snapshot.data['messages'][indexVal]['messageMode'] ==  'Non-Prime') || ( snapshot.data['messages'][indexVal]['messageMode'] ==  'All')) && (msgDeliveryMode =="Non-Prime")){
          //  non prime users display
             print(' i was at All');
              return PostItem(
              message: snapshot.data['messages'][indexVal]['type'] == "text"
                          ?snapshot.data['messages'][indexVal]['messageBody']
                          :snapshot.data['messages'][indexVal]['imageUrl'],
              premium:  snapshot.data['messages'][indexVal]['premium'] ,          
              type : snapshot.data['messages'][indexVal]['type'],
              img: snapshot.data['messages'][indexVal]['imageUrl'],
              name: snapshot.data['messages'][indexVal]['type'],
              dp: snapshot.data['messages'][indexVal]['imageUrl'],
              messageMode: snapshot.data['messages'][indexVal]['messageMode'],
              time: datestamp.format(snapshot.data['messages'][indexVal]['date'].toDate()).toString(),
              selMessageMode: msgDeliveryMode
                    );
         }else{
          return Container();
         }


  // fresh end check

         if(((widget.approvedGroups.contains(widget.chatId)) || (widget.chatOwnerId == widget.userId)) && (snapshot.data['messages'][indexVal]['messageMode'] ==  'Prime') && (msgDeliveryMode =="Prime")){
          //  owner display for Prime
             print(' i was at prime');
              return PostItem(
              message: snapshot.data['messages'][indexVal]['type'] == "text"
                          ?snapshot.data['messages'][indexVal]['messageBody']
                          :snapshot.data['messages'][indexVal]['imageUrl'],
              premium:  snapshot.data['messages'][indexVal]['premium'] ,          
              type : snapshot.data['messages'][indexVal]['type'],
              img: snapshot.data['messages'][indexVal]['imageUrl'],
              name: snapshot.data['messages'][indexVal]['type'],
              dp: snapshot.data['messages'][indexVal]['imageUrl'],
              messageMode: snapshot.data['messages'][indexVal]['messageMode'],
              time: datestamp.format(snapshot.data['messages'][indexVal]['date'].toDate()).toString(),
                    );
         }
         else if(((widget.approvedGroups.contains(widget.chatId) && !snapshot.data['messages'][indexVal]['premium'])) && (snapshot.data['messages'][indexVal]['messageMode'] ==  'Non-Prime')){
         print(' i was at non-prime');
          //  owner display for non-prime
              return PostItem(
              message: snapshot.data['messages'][indexVal]['type'] == "text"
                          ?snapshot.data['messages'][indexVal]['messageBody']
                          :snapshot.data['messages'][indexVal]['imageUrl'],
              premium:  snapshot.data['messages'][indexVal]['premium'] ,          
              type : snapshot.data['messages'][indexVal]['type'],
              img: snapshot.data['messages'][indexVal]['imageUrl'],
              name: snapshot.data['messages'][indexVal]['type'],
              dp: snapshot.data['messages'][indexVal]['imageUrl'],
              messageMode: snapshot.data['messages'][indexVal]['messageMode'],
              time: datestamp.format(snapshot.data['messages'][indexVal]['date'].toDate()).toString(),
                    );
         }
         else if   (((widget.approvedGroups.contains(widget.chatId) && snapshot.data['messages'][indexVal]['premium']))){
          print(' i was at one one one');
          //  prime user display for all and 
            return PostItem(
              message: snapshot.data['messages'][indexVal]['type'] == "text"
                          ?snapshot.data['messages'][indexVal]['messageBody']
                          :snapshot.data['messages'][indexVal]['imageUrl'],
              premium:  snapshot.data['messages'][indexVal]['premium'] ,          
              type : snapshot.data['messages'][indexVal]['type'],
              img: snapshot.data['messages'][indexVal]['imageUrl'],
              name: snapshot.data['messages'][indexVal]['type'],
              dp: snapshot.data['messages'][indexVal]['imageUrl'],
              messageMode: snapshot.data['messages'][indexVal]['messageMode'],
              time: datestamp.format(snapshot.data['messages'][indexVal]['date'].toDate()).toString(),
            );
                  } else if(!widget.approvedGroups.contains(widget.chatId) && snapshot.data['messages'][indexVal]['premium']){
                    return Container();
                  }else if(!(msgDeliveryMode == 'Prime')  ||  (snapshot.data['messages'][indexVal]['messageMode'] ==  'All')){
                print(' i was at yo yo yo');
                    return PostItem(
              message: snapshot.data['messages'][indexVal]['type'] == "text"
                          ?snapshot.data['messages'][indexVal]['messageBody']
                          :snapshot.data['messages'][indexVal]['imageUrl'],
              premium:  snapshot.data['messages'][indexVal]['premium'] ,          
              type : snapshot.data['messages'][indexVal]['type'],
              img: snapshot.data['messages'][indexVal]['imageUrl'],
              name: snapshot.data['messages'][indexVal]['type'],
              dp: snapshot.data['messages'][indexVal]['imageUrl'],
              messageMode: snapshot.data['messages'][indexVal]['messageMode'],
              time: datestamp.format(snapshot.data['messages'][indexVal]['date'].toDate()).toString(),
                    );
                  }
                  else{
                    return Container();
                  }

                       return  ChatBubble(
                      message: snapshot.data['messages'][indexVal]['type'] == "text"
                          ?snapshot.data['messages'][indexVal]['messageBody']
                          :snapshot.data['messages'][indexVal]['imageUrl'],
                      username: widget.userId,
                      time: datestamp.format(snapshot.data['messages'][indexVal]['date'].toDate()).toString(),
                      //time: Jiffy(snapshot.data['messages'][indexVal]['date'].toDate()).fromNow().toString(),
                      type: snapshot.data['messages'][indexVal]['type'],
                      replyText:"",
                      isMe: true,
                      isGroup: true,
                      isReply: false,
                      replyName: widget.userId,
                    );
                       

                  },
                );
            }
          }
              return 
                       Align(
                         alignment: Alignment.center,
                       child: Column(
                         children: <Widget>[
                           SizedBox(height: MediaQuery.of(context).size.height/4.5),
                           
                           new Container(
                height: MediaQuery.of(context).size.height / 3,
                child: SvgPicture.asset('assets/emptyBox.svg'),
              
              ),

              new Text('Empty Chat', style: TextStyle(color: Colors.black, fontSize: 20),),
                           
                         ],
                       )
                       );
            }
                )
              ),

   

          Visibility(
           visible: (widget.chatOwnerId == widget.userId),
            child:
            Padding(
              padding: const EdgeInsets.only(left:8.0, right: 8.0),
              child: ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Send To"),
                  Row(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Radio(
                            value: 1,
                            groupValue: selectedRadio,
                            activeColor: Colors.green,
                            onChanged: (val) {
                              print("Radio $val");
                              setSelectedRadio(val);
                            },
                          ),
                          Text("Common")
                        ],
                      ),
                    
                  Row(
                    children: <Widget>[
                      Radio(
                        value: 2,
                        groupValue: selectedRadio,
                        activeColor: Colors.blue,
                        onChanged: (val) {
                          print("Radio $val");
                          setSelectedRadio(val);
                        },
                      ),
                      Text("Prime")
                    ],
                  ),
                  Row(
                        children: <Widget>[
                          Radio(
                            value: 3,
                            groupValue: selectedRadio,
                            activeColor: Colors.green,
                            onChanged: (val) {
                              print("Radio $val");
                              setSelectedRadio(val);
                            },
                          ),
                          Text("Non-Prime")
                        ],
                      ),
                  ],
                  ),
                ],
              ),
            )     ,
          ),
              Visibility(
                visible: (widget.chatOwnerId != widget.userId),
                child: Visibility(
                  visible:((!widget.approvedGroups.contains(widget.userId)) || !(widget.chatOwnerId == widget.userId)),
                  child:
 Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                padding: EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 8),
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
                            child:Icon(
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
                        child:
                        Column(
                          children: <Widget>[
                            SizedBox(height: 13),
                            Text(
                              (!widget.waitingGroups.contains(widget.chatId)) 
                                
                               ? "Join Premium Rs ${feeDetails}/-" : "Under Review",
                              style: TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w400
                              ),
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
      //                      Checkbox(
      //   value: msgDeliveryMode =="Prime",
      //   onChanged: setDeliveryModeCheckBox
      // ),
                          IconButton(
                            icon: Icon(
                              Icons.image,
                              color: Color(0xff3E8Df3),
                            ),
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MyImageEditorPro(
          appBarColor: Colors.blue,
          bottomBarColor: Colors.blue,
          groupLogo: widget.groupLogo,
          chatId: widget.chatId,
          userId: widget.userId,
          premiumMode: msgDeliveryMode == 'Prime',
          deliveryMode: msgDeliveryMode,
          msgFullCount: widget.msgFullCount,
        );
      })).then((geteditimage) {
        if (geteditimage != null) {
          setState(() {
            _image = geteditimage;
          });
        }
      }).catchError((er) {
        print(er);
      });
                                  //  Navigator.push(
                                  //     context,
                                  //    new  MaterialPageRoute(
                                  //         builder: (BuildContext context) => ImageEditorPage(chatId: widget.chatId,userId: widget.userId,chatType: "Image", groupLogo: widget.groupLogo),
                                  //         ),
                                  //  );
                            },
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
                                hintText: "Write your message...",
                                hintStyle: TextStyle(
                                  fontSize: 15.0,
                                  color: Theme.of(context).textTheme.title.color,
                                ),
                              ),
                              controller: _chatMessageText,
                              maxLines: null,
                            ),
                          ),
//                         Visibility(
//                           visible: msgDeliveryMode == "Prime",
//                           child:
//  IconButton(
//                           icon: Icon(
//                             FontAwesomeIcons.crown,
//                             color: Theme.of(context).accentColor,
//                           ),
//  ),
//                         ),
//                          Visibility(
//                           visible: !(msgDeliveryMode =="Prime"),
//                           child:
//   IconButton(
//                           icon: Icon(
//                             FontAwesomeIcons.users,
//                             color: Theme.of(context).accentColor,
//                           ),
//  ),
//                          ),
                          IconButton(
                            icon: Icon(
                              Icons.send,
                              color: Theme.of(context).accentColor,
                            ),
                                onPressed: () {
                          print('user send tis message ${_chatMessageText.text}');
                          var now = new DateTime.now();
                          var alt =  now.add(Duration(days: 1));
                          print('time was ${alt}');
                          try {
                            widget.msgFullCount = widget.msgFullCount + 1;
                            var now = new DateTime.now();
                            var body ={ "messageBody":_chatMessageText.text, "date": now,"author": widget.userId, "type": "text" , "premium": (msgDeliveryMode  == "Prime"), "messageMode": msgDeliveryMode };
                            // var lastMessageBody ={"lastMsg":_chatMessageText.text, "lastMsgTime": now};
                            var lastMessageBody ={"lastMsg":_chatMessageText.text, "lastMsgTime": now.toString(), "title": widget.groupTitle, "msgFullCount" : widget.msgFullCount};
                           
                           FirebaseController.instanace.sendChatMessage(widget.chatId, body, lastMessageBody);
                            _chatMessageText.text ="";
  
                              Timer(Duration(milliseconds: 500),
              () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
                          } catch (e) {
                          }
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
        

       floatingActionButton: 
         

   
       Visibility(
        visible: widget.approvedGroups.contains(widget.chatId), 
        child:
        Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
          child: FloatingActionButton.extended(
  onPressed: () async {
               var  snapShot = await FirebaseController.instanace.getCurrentVotes(widget.chatId);

// this creates feedback entry for newGroup or a group which does not have entry yet in DB
if (snapShot == null || !snapShot.exists) {

}else{
  votingBalletHeapData = await  snapShot.data['VotingStats'];
  print('full data of heap is ${votingBalletHeapData}');
  // List reqGroupA =  data.where((i) => i["gameId"] == matchId).toList();
  // List homeGroup =  data.where((i) => i["gameId"] != matchId).toList();
}


                  // powerPredictor
                 await   Navigator.push(
                                      context,
                                     new  MaterialPageRoute(
                                          builder: (BuildContext context) => PowerFeedbacker(
                                          groupCategories: widget.groupSportCategory ,groupCategoriesArray : groupCategoriesArray,
                                          groupId: widget.chatId,groupTitle: widget.groupTitle, 
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
}
