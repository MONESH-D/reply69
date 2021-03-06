import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notification/controllers/firebaseController.dart';


class ChatMenuIcon extends StatefulWidget {

  final String dp;
  final String groupName;
  final String time;
  final String msg;
  final bool isOnline;
  final counter;
  final fullUserJson;
  final chatId;
  final bool ownerOrPrime;

  ChatMenuIcon({
    Key key,
    @required this.dp,
    @required this.groupName,
    @required this.time,
    @required this.msg,
    @required this.isOnline,
    @required this.counter,
    this.ownerOrPrime,
    this.chatId,
    this.fullUserJson,
  }) : super(key: key);

  @override
  _ChatMenuIconState createState() => _ChatMenuIconState();
}

class _ChatMenuIconState extends State<ChatMenuIcon> {
  @override
  Widget build(BuildContext context) {
    return Container(
        
            decoration: widget.ownerOrPrime ? new BoxDecoration (
                 gradient: new LinearGradient(
                colors: [
                  const Color(0xFF3366FF),
                  const Color(0xFF00CCFF),
                ],
                 )
            ) :
             new BoxDecoration (
              
                 
            )
            ,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: Stack(
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(
                  "${widget.dp}",
                ),
                radius: 25,
              ),

              Positioned(
                bottom: 0.0,
                left: 6.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  height: 11,
                  width: 11,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.isOnline
                            ?Colors.greenAccent
                            :Colors.grey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      height: 7,
                      width: 7,
                    ),
                  ),
                ),
              ),

            ],
          ),

          title: Text(
            "${widget.groupName[0].toUpperCase() + widget.groupName.substring(1)}",
            maxLines: 1,
            style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: widget.ownerOrPrime ?  Colors.white :Color(0xff3A4276),
                      fontWeight: FontWeight.w800,
                    ),
          ),
          subtitle: Text(
            "${widget.msg}",
            style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: widget.ownerOrPrime ?  Colors.white :Color(0xff3A4276),
                    fontWeight: FontWeight.w400,
                  ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(height: 10),
              Text(
                "${widget.time}",
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 11,
                ),
              ),

              SizedBox(height: 5),
              widget.counter == "0"
                  ?SizedBox()
                  :InkWell(
                    onTap: (){
                      print('remove was clicked');
                      var userId = widget.fullUserJson['userId'];
                      var modifiedDate = widget.fullUserJson['expiresOn'];
                      var kycDocId = widget.fullUserJson['kycDocId'];
                      var period = widget.fullUserJson['membershipDuration'];
                      var joinedTime = widget.fullUserJson['joinedId'];
                      var expiredTime = widget.fullUserJson['expiresOn'];
                    FirebaseController.instanace.removeMemberOnExpiry(userId, joinedTime, expiredTime, kycDocId, period, widget.chatId, widget.fullUserJson);
                    },
                    child:Container(
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 11,
                  minHeight: 11,
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 2, left: 5, right: 5, bottom: 2),
                  child:Text(
                    "${widget.counter}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
