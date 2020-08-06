import 'dart:async';
import 'dart:io';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notification/pages/groupProfile1.dart';
import 'package:notification/screens/editGroup.dart';
import 'package:notification/util/data.dart';
import 'package:notification/util/screen_size.dart';
import 'package:notification/util/state.dart';
import 'package:notification/util/state_widget.dart';
import 'package:notification/widgets/linearPercentIndicator.dart';
import 'package:notification/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bid365_app_theme.dart';


class JoinPremiumGroup extends StatefulWidget {
    JoinPremiumGroup({Key key, 
    this.chatId,this.groupOwnerName,
    this.userId,
    this.categories,
    this.followers,
    this.accessingBy,
    this.lock, this.title, 
    this.feeArray, this.paymentScreenshotNo, 
    this.seasonRating,this.thisWeekRating, this.lastWeekRating,
    this.avatarUrl}) : super(key: key);
   final String chatId, userId,title,  
                paymentScreenshotNo, avatarUrl,
                accessingBy,
                groupOwnerName, seasonRating,thisWeekRating, lastWeekRating;
   final feeArray;
   final List categories, followers;


   bool lock;
  @override
  _JoinPremiumGroupState createState() =>
      _JoinPremiumGroupState();
}

class _JoinPremiumGroupState extends State<JoinPremiumGroup> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isProsses = false;
  bool isFirstTime = true;
  bool approved = false;
  bool uploadedLock = false;
  String pancard_approve_status, payment_approve_status;
  StateModel appState;
  File _image;
  bool kycData = false;
  String panCardImageUrl,panHolderName, panNo;
   bool lockModify;
  List followCountModify =[] ;
  

  var date = DateTime.now();
  bool _loadingVisible = false;


  var panNameController = new TextEditingController();
  var panNoController = new TextEditingController();

  @override
  void initState() {
    // getPancardData();
    super.initState();
       lockModify = widget.followers.contains(widget.userId);
    followCountModify = widget.followers;
  }

  // void getPancardData() async {
  //   setState(() {
  //     isProsses = true;
  //     panNoController.text = '';
  //     panNameController.text = '';
  //     date = DateFormat('dd/MM/yyyy').parse('30/05/1990');
  //     approved = true;
  //   });

  //   setState(() {
  //     isFirstTime = false;
  //     isProsses = false;
  //   });
  // }
  List<Widget> _buildSelectedOptions(dynamic values) {
    print('values of categories ${values}');
          List<Widget> selectedOptions = [];

          if (values != null) {
            values.forEach((item) {
              selectedOptions.add(
                Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12,),
                                      child: Center(
                                        child: Text(
                                          "${item['categoryName'] ?? ''}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700
                                          ),
                                        ),
                                      ),
                                    ),
              );
            });
          }

          return selectedOptions;
        }
  List<Widget> _buildStatsView(dynamic values, _media) {
          List<Widget> selectedOptions = [];

          if (values != null) {
            values.forEach((item) {
              selectedOptions.add(
                winStats(context, _media, item['categoryName'] ?? '', item['rating'] ?? 0)

             
              );
            });
          }

          return selectedOptions;
        }
  
  Widget winStats(context, _media, gameName, rating){
  return         Row(
                  children: <Widget>[
                    Container(
                      width: 70,
                      child:
                    Text('${gameName}', style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: "Varela",
                  ),
                  overflow: TextOverflow.ellipsis,),
                    ),
                  SizedBox(
                    width: 6
                  ),
                    LinearPercentIndicator(
                      width: screenAwareSize(
                          _media.width - (_media.longestSide <= 775 ? 140 : 200),
                          context),
                      lineHeight: 20.0,
                      percent: rating/ 100,
                      backgroundColor: Colors.grey.shade300,
                      progressColor: Color(0xFF1b52ff),
                      animation: true,
                      animateFromLastPercent: true,
                      alignment: MainAxisAlignment.spaceEvenly,
                      animationDuration: 1000,
                      linearStrokeCap: LinearStrokeCap.roundAll,
                      center: Text(
                        "${rating} %",
                        style: 
                        rating > 45?
                        TextStyle(color: Colors.white): TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                );
}
Widget editGroupButton(context){
 return FlatButton(
                      child: Text(
                        "Edit",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      color: Colors.redAccent,
                      onPressed: ()async{
                        //  this is for token 
    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditGroupProfile(primaryButtonRoute: "/home",
                          groupName: widget.title,groupCategory:  widget.categories,fee: widget.feeArray, expiryDays:widget.feeArray,phNumber:widget.paymentScreenshotNo,
                          ),
                        ),
                      );
                      return;
                      },
                    );
                    }
Widget followUnfollowButtons(context){
return lockModify ? FlatButton(
                      child: Text(
                        "Unfollow",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      color: Colors.grey,
                      onPressed: ()async{
                        //  this is for token 
     SharedPreferences prefs = await SharedPreferences.getInstance();
      String userToken = prefs.get('FCMToken');
                        Firestore.instance.collection('groups').document(widget.chatId).updateData({ 'followers' : FieldValue.arrayRemove([widget.userId]),'AlldeviceTokens': FieldValue.arrayRemove([userToken])});
                        Firestore.instance.collection('IAM').document(widget.userId).updateData({ 'followingGroups0' : FieldValue.arrayRemove([widget.chatId])});
                        Firestore.instance.collection('IAM').document(widget.userId).updateData({ 'followingGroups1' : FieldValue.arrayRemove([widget.chatId])});
                        Firestore.instance.collection('IAM').document(widget.userId).updateData({ 'followingGroups2' : FieldValue.arrayRemove([widget.chatId])});
                        Firestore.instance.collection('IAM').document(widget.userId).updateData({ 'followingGroups3' : FieldValue.arrayRemove([widget.chatId])});
                      
                      setState(() {
                        lockModify = !lockModify;
                        followCountModify.remove(widget.userId);
                      
                      });
                      return;
                      },
                    ):
                                 FlatButton(
                      child: Text(
                        "Follow",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      color: Theme.of(context).accentColor,
                      onPressed: ()async{
                        print("check for doc id of group ${widget.chatId}  id is ${widget.userId}");
                        // make an entry in db as joinedGroups
                       try {
                           setState(() {
                        lockModify = !lockModify;
                        followCountModify.add(widget.userId);
                      });
                         //  this is for token 
     SharedPreferences prefs = await SharedPreferences.getInstance();
      String userToken = prefs.get('FCMToken');
                        Firestore.instance.collection('groups').document(widget.chatId).updateData({ 'followers' : FieldValue.arrayUnion([widget.userId]), 'AlldeviceTokens': FieldValue.arrayUnion([userToken]) });
  
   var q1 = await Firestore.instance.collection('IAM').document(widget.userId).get();

   var followingGroups0 = q1.data['followingGroups0'] ?? [];
   var followingGroups1 = q1.data['followingGroups1'] ?? [];
   var followingGroups2 = q1.data['followingGroups2'] ?? [];
   var followingGroup3 = q1.data['followingGroups3'] ?? [];




 
  if(followingGroups0.length <9){
    print('i was at following groups 0 ${widget.chatId}');
      Firestore.instance.collection('IAM').document(widget.userId).updateData({ 'followingGroups0' : FieldValue.arrayUnion([widget.chatId])});
      return;
  }else if (followingGroups1.length <9){
      Firestore.instance.collection('IAM').document(widget.userId).updateData({ 'followingGroups1' : FieldValue.arrayUnion([widget.chatId]) });
      return;
  }else if (followingGroups2.length <9){
      Firestore.instance.collection('IAM').document(widget.userId).updateData({ 'followingGroups2' : FieldValue.arrayUnion([widget.chatId]) });
      return;
  }else if(followingGroup3.length <9){
      Firestore.instance.collection('IAM').document(widget.userId).updateData({ 'followingGroups3' : FieldValue.arrayUnion([widget.chatId])});
  // ds.documentID


  
      return;
  }
                       } catch (e) {
                         print('error at joining a group ${e}');
                       }
          
 
                      },
                    );
}

 Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }
  Widget _buildCategory(String title,value){
    // return Column(
    //   children: <Widget>[
    //     Text(
    //       "${value}",
    //       style: TextStyle(
    //         fontWeight: FontWeight.bold,
    //         fontSize: 22,
    //       ),
    //     ),
    //     SizedBox(height: 4),
    //     Text(
    //       title,
    //       style: TextStyle(
    //       ),
    //     ),
    //   ],
    // );
    return Container(
                              width: 110,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
 Text(
                                    value, 
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                   SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    title, 
                                    style: TextStyle(
                                      // color: Colors.grey,
                                      // fontSize: 12,
                                    ),
                                  ),
                                  
                                 

                                 
                                ],
                              ),
                            );
  }
  @override
  Widget build(BuildContext context) {

       appState = StateWidget.of(context).state;
    final userId = appState?.firebaseUserAuth?.uid ?? '';
    final email = appState?.firebaseUserAuth?.email ?? '';
var followersA = widget.followers ?? [];
    Size size = MediaQuery.of(context).size;
    final _media = MediaQuery.of(context).size;
  
        // var kycLock = kycData??['pancardLock'] ?? false;
    //  getKycDetails(userId);
     return Scaffold(
       appBar:  AppBar(
        elevation: 3,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_backspace,
          ),
          onPressed: ()=>Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text("Summary"),
       ),
       body: LoadingScreen(
            inAsyncCall: _loadingVisible,
            child: 
                ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 20,
        ),
        children: <Widget>[
                           SizedBox(height: 20),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Profile",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: "Varela",
                  ),
                ),
              ],
            ),
          ),
                //            Profile3(
                //              title: widget.title,
                // avatarUrl: widget.avatarUrl,
                // categories: widget.categories,
                // following: followersA.contains(widget.userId),
                // chatId: widget.chatId,
                // userId: userId,
                // followers: widget.followers,
                // groupOwnerName : widget.groupOwnerName,
                // feeDetails: widget.feeArray,
                // seasonRating: widget.seasonRating,
                // thisWeekRating: widget.thisWeekRating,
                // lastWeekRating: widget.lastWeekRating),

                Align(
              alignment: Alignment.topCenter,
              child: 

              Container(
                  height: size.height * 0.45,
                 
                  margin: EdgeInsets.only(
              top: 15,
              right: 20,
            ),
            padding: EdgeInsets.all(10),
                   // height: screenAwareSize(145, context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 6,
                  spreadRadius: 10,
                )
              ],
            ),
                  child: Column(
                    children: <Widget>[

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16,),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[

                                CircleAvatar(
                                  radius: 36,
                                  backgroundImage: NetworkImage("${widget.avatarUrl}"),
                                ),

                                Row(
                                  children: <Widget>[
                                    Visibility(
                                      visible: widget.accessingBy == 'owner',
                                      child:editGroupButton(context),),
                                 

                                    SizedBox(
                                      width: 8,
                                    ),

                             followUnfollowButtons(context),

                                  ],
                                ),

                              ],
                            ),

                            SizedBox(
                              height: 8,
                            ),

                            Text(
                              "${widget.title.toUpperCase()}",
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(
                              height: 8,
                            ),

                            Text(
                              "@ ${widget.groupOwnerName}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),

                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),

                            SizedBox(
                              height: 8,
                            ),

                            Text(
                              "NA",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Category",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                             Row(
                                         children: <Widget>[
                                           Wrap(
                    spacing: 4.0, // gap between adjacent chips
                    runSpacing: 1.0, // gap between lines
                    children:
                    _buildSelectedOptions(widget.categories),
                  ),
                                         ],
                                       ),

                          ],
                        ),
                      ),

                      Expanded(
                        child: Container(),
                      ),

                      Divider(
                        color: Colors.grey[400],
                      ),
                      Container(
                        height: 64,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                    _buildCategory("30-DAYS FEE", "Rs ${widget.feeArray[0]['fee']}"),
                    _buildCategory("Followers", "${followCountModify.length}"),
                    _buildCategory("Rating", "${widget.seasonRating ?? 'NA'}"),
                          ],
                        ),
                      ),
                    
                    ],
                  ),
                ),
              
            ),
          


            SizedBox(
            height: 30,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Payment Screenshot",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: "Varela",
                  ),
                ),
                 WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.only(left:8.0),
          child: Icon(
                            FontAwesomeIcons.phoneAlt,
                            color: Colors.green,
                            size: 20,
                          ),
        ),
      ),       
                TextSpan(
                  text: " ${widget.paymentScreenshotNo}",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: "Varela",
                  ),
                ),
              ],
            ),
          ),
         Container(
            margin: EdgeInsets.only(
              top: 15,
              right: 20,
            ),
            padding: EdgeInsets.all(10),
            // height: screenAwareSize(145, context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 6,
                  spreadRadius: 10,
                )
              ],
            ),
            child:             StreamBuilder(
          stream: Firestore.instance.collection('KYC').where("chatId", isEqualTo: widget.chatId).where("uid", isEqualTo: widget.userId).where("approve_status", isEqualTo: 'Review_Waiting').snapshots(),
          builder: (context,snapshot){
                    if(snapshot.hasError) {
                                  return Center(child: Text('Error: '));
                    }
                                else if(snapshot.hasData && snapshot.data.documents.length > 0){
                                  print('yo yo ${snapshot.data.documents.length}');
                                return   ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (_, int index) {
                              DocumentSnapshot doc = snapshot.data.documents[index];
                              print(' data is ${doc.data}');
                                          DocumentSnapshot kycDetailsSnap = snapshot.data.documents[index];
                    panCardImageUrl = kycDetailsSnap.data['pancardDocUrl'] ?? "http://www.pngall.com/wp-content/uploads/2/Upload-PNG.png";
                    payment_approve_status = kycDetailsSnap.data['payment_approve_status'] ?? "NA";
        
        if(payment_approve_status == "Rejected" || payment_approve_status == "Review_Waiting"){
          print('iwas inside clearr');
          widget.lock = true;     
        }else{
          widget.lock = false;
          
        }
      //  return uploadDocContent(context,payment_approve_status,userId, panCardImageUrl,widget.lock,_image );
                              return new Container(
                                  child: Column(
                                    children: <Widget>[
                                      Text('Your Documents is ${doc.data["payment_approve_status"] ?? "NULL"}'),
                                      SizedBox(height: 10,),
                                                 Container(
      height: 220.0,
      width: 220.0,
       decoration: BoxDecoration(
         color: Colors.red,
                    image: DecorationImage(
                      image: NetworkImage(panCardImageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  )
    )
                                    ],
                                  ));
                          },
                        );

        
        }
        // return Container(child: Text('check'));
        return uploadDocContent(context,"payment_approve_status",userId, "http://www.pngall.com/wp-content/uploads/2/Upload-PNG.png", widget.lock ,_image);
          }
        ),
            // child: uploadDocContent(context,"payment_approve_status",userId, "http://www.pngall.com/wp-content/uploads/2/Upload-PNG.png", widget.lock ,_image)
            
            // Column(
            //   children: <Widget>[
            //     expandData(context, widget.lock , _image, panCardImageUrl),
            //          Wrap(
            //         spacing: 0.0, // gap between adjacent chips
            //         runSpacing: 1.0, // gap between lines
            //         children:
                    
            //         _buildStatsView(widget.categories, _media),
            //       )

            //   ],
            // ),
            
          ),


            SizedBox(
            height: 30,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Win Stastics",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Varela",
                  ),
                ),
                TextSpan(
                  text: "    This Week",
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: "Varela",
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 15,
              right: 20,
            ),
            padding: EdgeInsets.all(10),
            // height: screenAwareSize(145, context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 6,
                  spreadRadius: 10,
                )
              ],
            ),
            child: 
            
            Column(
              children: <Widget>[
                     Wrap(
                    spacing: 0.0, // gap between adjacent chips
                    runSpacing: 1.0, // gap between lines
                    children:
                    
                    _buildStatsView(widget.categories, _media),
                  )

              ],
            ),
          ),


                    // Container(
                    //   child: Padding(
                    //           padding: const EdgeInsets.all(8),
                    //           child: Row(
                    //             children: <Widget>[
                    //               priceDispUI('1000', '30 days'),
                    //               priceDispUI('1500', '45 days'),
                    //               priceDispUI('100', '10 days'),
                    //             ],
                    //           ),
                    //         ),
                    // ),
                    // uploadDocContent(context,"payment_approve_status",userId, "http://www.pngall.com/wp-content/uploads/2/Upload-PNG.png", widget.lock ,_image),
                  ],
                ),
              
            
        ),
     );
     
  }
Widget uploadDocContent(context, payment_approve_status,userId,panCardImageUrl, lock, _image ){
                      return Container(
        decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
          ),
        ),
        child:Stack(
          
                                  alignment: AlignmentDirectional.bottomCenter,
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        
                                           Container(
                                            child: expandData(context, lock, _image, panCardImageUrl),
                                          ),
                                        
                                      ],
                                    ),
                                      (widget.lock)
                                        ? Positioned(
                                            bottom: 32,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  top: 8, left: 32, right: 32),
                                              child: Text(
                                                "Your Join Request is ${payment_approve_status} ${userId}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Colors.green),
                                              ),
                                            )
                                            )
                                          
                                        : SizedBox(
                                          child: Column(
                                            children: <Widget>[
                                              SizedBox(height:10),
                                              FlatButton(
    onPressed: () async {
        if(widget.lock){
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text("Doc already uploaded"),));
                          }else if (_image == null){
                             Scaffold.of(context).showSnackBar(SnackBar(content: Text("Wanted Payment screenshot for Owner"),));
                          }
                          else{
                           
           await _changeLoadingVisible();
        // uplaod the detail of this in user details table
        // with details of uid, emailid, pandcard no, pancard holder name,approve status 
        // 
        // upload to approve
        DateTime now = new DateTime.now();
          var datestamp = new DateFormat("yyyyMMdd'T'HHmmss");
          String currentdate = datestamp.format(now);
        
    final StorageReference firebaseStorageRef = await FirebaseStorage.instance.ref().child('myimage1.jpg');
    final StorageUploadTask uploadTask = await firebaseStorageRef.putFile(_image);
       var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = dowurl.toString();
    print('uploaded url is $url ${panNoController.text}');

    // return url; 

    // StorageTaskSnapshot taskSnapshot =  uploadTask.onComplete;

    

        var body ={
          "uid": userId,
          "chatId": widget.chatId,
          "pancardDocUrl": url,
          "uploadedTime": currentdate,
          "payment_approve_status": "Review_Waiting",
          "approve_status": "Review_Waiting",
        };

        print("submitted details are ${body} ");
        final collRef = await Firestore.instance.collection('KYC');
                                                       DocumentReference docReferance = collRef.document();
                                                       docReferance.setData(body); 
        final userTable = await Firestore.instance.collection('IAM');
                                                       DocumentReference userTableDocRef = userTable.document(userId);
                                                       userTableDocRef.updateData({ 'WaitingGroups' : FieldValue.arrayUnion([widget.chatId]),  'WaitingGroupsJson' : FieldValue.arrayUnion([body])}); 
        // 
        await _changeLoadingVisible();
        setState(() {
        widget.lock = true;
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Doc Uploaded Successfully"),));
    });
}

    },
    color: Theme.of(context).accentColor,
    child: Text("Submit For Verification",style: TextStyle(
                          color: Colors.white,
                        ),),
  ),
                                            ],
                                          ),
                                        ),
                                  ],
                                ),
                     
        );
}
  Widget expandData(context, lock, _image,panCardImageUrl) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[


          Container(
            padding: EdgeInsets.only(top: 38, left: 16, right: 16, bottom: 8),
       
        child: 
            
            
            Container(
              height: 48,
              decoration: new BoxDecoration(
                color: Colors.redAccent,
                borderRadius: const BorderRadius.all(
                                          Radius.circular(2.0),
                                        ),
                //  boxShadow: <BoxShadow>[
                //                           BoxShadow(
                //                               color: Bid365AppTheme
                //                                   .nearlyBlue
                //                                   .withOpacity(0.5),
                //                               offset: const Offset(1.1, 1.1),
                //                               blurRadius: 10.0),
                //                         ],
              ),
              child: InkWell(
                onTap: () {
                if(lock){
                  // showInSnackBar('Doc already uploaded');
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Doc already uploaded"),));
                }else{
                  getImage();
                }

                },
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.attach_file,
                      color: Colors.white,
                    ),
                    Text(
                      'Upload Payment Screenshot',
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
                        ),
          



          SizedBox(
            height: 20,
          ),
    //       Visibility(
    //         visible: _image == null ,
    //         child: 
    //       Container(
    //   height: 220.0,
    //   width: 220.0,
    //    decoration: BoxDecoration(
    //      color: Colors.red,
    //                 image: DecorationImage(
    //                   image: NetworkImage(panCardImageUrl),
    //                   fit: BoxFit.cover,
    //                 ),
    //                 borderRadius: BorderRadius.circular(20.0),
    //               )
    // )
    //       ),
           Container(
                  //           height: screenHeight * 0.6,
                  // width: screenWidth,
                            child: _image == null ? Text('No payment deatail upload') : 
                              Container(
      height: 220.0,
      width: 220.0,
      decoration: BoxDecoration(
                  
                    borderRadius: BorderRadius.circular(20.0),
                  ),


                  
  child: Image.file(_image, height:250, width: 250),
    )
                            
                            
                          ),
                           SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Future getImage() async {
   print("launching image picker");
var image = await ImagePicker.pickImage(source: ImageSource.gallery);
  print('ending image picker');

      setState(() {
          _image = image;
        });
    // if (image != null) {
    //   File cropimage = await cropImage(image);
    //   if (cropimage != null) {
    //     if (!mounted) return;
    //     setState(() {
    //       _image = cropimage;
    //     });
    //   }
    // }
  }

  Future<File> cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      maxWidth: 512,
      maxHeight: 512,
    );
    return croppedFile;
  }

  void showInSnackBar(String value, {bool isGreen = false}) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          value,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
        ),
        backgroundColor: isGreen ? Colors.green : Colors.red,
      ),
    );
  }
    Widget priceDispUI(String text1, String txt2) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Bid365AppTheme.nearlyWhite,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Bid365AppTheme.grey.withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 8.0),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 18.0, right: 18.0, top: 12.0, bottom: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                text1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: Bid365AppTheme.nearlyBlue,
                ),
              ),
              Text(
                txt2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w200,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: Bid365AppTheme.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}