import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notification/controllers/firebaseController.dart';
import 'package:notification/screens/main_screen.dart';
import 'package:notification/util/screen_size.dart';
import 'package:notification/util/state_widget.dart';
import 'package:notification/widgets/linearPercentIndicator.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Profile3 extends StatefulWidget {
   Profile3({
    Key key,
    this.title,
    this.chatId,
    this.feeArray,
    this.avatarUrl,
    this.categories,
    this.paymentScreenshotNo,
    this.rating,
    this.followers,
    this.following,
    this.userId,
    this.groupOwnerName,
    this.feeDetails,
    this.seasonRating,
    this.lastWeekRating,
    this.thisWeekRating,
    this.followingGroupsLocal,
  }) : super(key: key);
   final String chatId,title,avatarUrl, paymentScreenshotNo, rating, seasonRating, lastWeekRating, thisWeekRating;
   final feeArray, categories, followers, userId, feeDetails, groupOwnerName;
   final bool following;
   List followingGroupsLocal;
  @override
  _Profile3State createState() => _Profile3State();
}

class _Profile3State extends State<Profile3> {
  bool lockModify;
  List followCountModify =[] ;
   @override
  void initState() {
    super.initState();

    lockModify = widget.following;
    followCountModify = widget.followers;
  }

 void _showBasicsFlash({
    Duration duration,
    flashStyle = FlashStyle.floating,BuildContext context, String messageText,
  }) {
    showFlash(
      context: context,
      duration: duration,
      builder: (context, controller) {
        return Flash(
          controller: controller,
          style: flashStyle,
          boxShadows: kElevationToShadow[4],
          horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            message: Text('$messageText'),
          ),
        );
    },
    );
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

  List<Widget> _buildSelectedOptions(dynamic values) {
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
Widget followUnfollowButtons(context){
return widget.followingGroupsLocal.contains(widget.chatId) ? FlatButton(
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

                      FirebaseController.instanace.unfollowGroup(widget.chatId, widget.userId, userToken);
                      
                      setState(() {
                        lockModify = !lockModify;
                        followCountModify.remove(widget.userId);
                        widget.followingGroupsLocal.remove(widget.chatId);
                        StateWidget.of(context).setFollowingGroupState(widget.followingGroupsLocal,widget.chatId, 'remove' );
                      });
                      await Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(
        builder: (BuildContext context)
        => MainScreen(userId: widget.userId,followingGroupsLocal: widget.followingGroupsLocal),
        ),(Route<dynamic> route) => false);
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
              
                         //  this is for token 
     SharedPreferences prefs = await SharedPreferences.getInstance();
      String userToken = prefs.get('FCMToken');
  

  //  var followingGroups1 = q1.data['followingGroups1'] ?? [];
  //  var followingGroups2 = q1.data['followingGroups2'] ?? [];
  //  var followingGroup3 = q1.data['followingGroups3'] ?? [];


       

 
  if(widget.followingGroupsLocal.length <9){
    print('i was at following groups 0 ${widget.chatId}');
     FirebaseController.instanace.followGroup(widget.chatId, widget.userId, userToken);

     var notifySnap =FirebaseController.instanace.getMessagesCount(widget.chatId);

           setState(() {
                        lockModify = !lockModify;
                        followCountModify.add(widget.userId);
                       widget.followingGroupsLocal.add(widget.chatId);
                      //  make a call and get read count 

                      //  widget.followingGruppsReadCount.add(notifySnap);
                        StateWidget.of(context).setFollowingGroupState(widget.followingGroupsLocal,widget.chatId, 'add' );
                      });
                      await Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(
        builder: (BuildContext context)
        => MainScreen(userId: widget.userId,followingGroupsLocal: widget.followingGroupsLocal),
        ),(Route<dynamic> route) => false);
     
     
      return;
  }else{
   
 _showBasicsFlash(context:  context, duration: Duration(seconds: 4), messageText : 'Overall max 9 group can be followed...!');
  }
                       } catch (e) {
                         _showBasicsFlash(context:  context, duration: Duration(seconds: 4), messageText : 'errow at following a group ${e}');
                         print('error at joining a group ${e}');
                       }
          
 
                      },
                    );
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

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    final _media = MediaQuery.of(context).size;

    return Scaffold(
           backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.4,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          'Summary',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black,),
        ),
      ),
      body: ListView(
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
                                  followUnfollowButtons(context),
                                 

                                    SizedBox(
                                      width: 8,
                                    ),

                            

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
                                fontSize: 32,
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

                            Container(
                              width: 110,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[

                                  Text(
                                    "30-DAYS FEE", 
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  
                                  SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    "${widget.feeDetails[0]['fee']}", 
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              width: 110,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[

                                  Text(
                                    "FOLLOWERS", 
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  
                                  SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    "${followCountModify.length}", 
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                ],
                              ),
                            ),

                            Container(
                              width: 110,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[

                                  Text(
                                    "RATING", 
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  
                                  SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    "${widget.seasonRating ?? 'NA'}", 
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                ],
                              ),
                            ),

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
                  text: "Win Statistics",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
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
          )

        ],
        
        
      ),
    
    );
  }
}