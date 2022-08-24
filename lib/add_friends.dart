import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tunestreak/user_provider.dart';
import 'user_profile.dart';
import 'friend_card.dart';
import 'constants.dart';
import 'utilities.dart';

// Used in ListView - stores TsUser information and whether or not we've sent a friend request
class TsUserToFriend {
  final TsUser user;
  final bool requested;
  const TsUserToFriend(this.user, this.requested);
}

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({Key? key}) : super(key: key);

  @override
  State<AddFriendsPage> createState() => AddFriendsPageState();
}

class AddFriendsPageState extends State<AddFriendsPage> {
  final _focusNode = FocusNode();
  final firestore = FirebaseFirestore.instance;

  final _friendSearchController = TextEditingController();
  var findFriendsList = List<TsUserToFriend>.empty();
  var friendRequestList = List<TsUser>.empty();

  void loadFriendRequests() async {
    UserProvider up = Provider.of<UserProvider>(context, listen: false);
    // Set sentFriendRequests and receivedFriendRequests in Provider
    // This reads every time the page is open, which seems a bit wasteful
    await firestore.collection("users").doc(up.fbDocId).get().then((doc) async {
      List<String> sfr = List.from(doc.get("sentFriendRequests"));
      List<String> rfr = List.from(doc.get("receivedFriendRequests"));
      up.setReceivedFriendRequests(rfr);
      up.setSentFriendRequests(sfr);
      // Load the TsUsers associated with each receivedFriendRequest one by one
      for (String fbDocId in rfr) {
        await firestore.collection("users").doc(fbDocId).get().then((doc) {
          if (!mounted) return;
          setState(() {
            friendRequestList = [
              ...friendRequestList,
              TsUser(
                  doc.get("name"), doc.get("username"), doc.id, doc.get("id"))
            ];
          });
        });
      }
    });
  }

  void _friendSearchControllerListener() async {
    var newFriendsList = List<TsUserToFriend>.empty(growable: true);
    final up = Provider.of<UserProvider>(context, listen: false);
    await firestore
        .collection("users")
        .where("username", isEqualTo: _friendSearchController.text)
        .get()
        .then((QuerySnapshot res) async {
      for (QueryDocumentSnapshot<Object?> doc in res.docs) {
        // Check that the returned user isn't already a friend
        bool isFriend = false;
        for (TsUser friend in up.friendsList) {
          if (friend.fbDocId == doc.id) {
            isFriend = true;
            break;
          }
        }
        if (isFriend) continue;
        // Check if we've already requested to add this friend
        List<String>? sfr = up.sentFriendRequests;
        if (sfr != null) {
          bool requestAlreadySent = false;
          for (String requestedFriendDocId in sfr) {
            if (requestedFriendDocId == doc.id) {
              requestAlreadySent = true;
              break;
            }
          }
          TsUser friend = TsUser(
              doc.get('name'), doc.get('username'), doc.id, doc.get('id'));
          if (requestAlreadySent) {
            newFriendsList.add(TsUserToFriend(friend, true));
          } else {
            newFriendsList.add(TsUserToFriend(friend, false));
          }
        }
      }
      setState(() => findFriendsList = newFriendsList);
    });
  }

  Widget _buildFriendRequestsList(context) {
    if (friendRequestList.isEmpty) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Text("All clear.", style: TextStyle(fontSize: 16))));
    }
    return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 150),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: friendRequestList.length,
            itemBuilder: (context, index) {
              return AddFriendCard(
                  friendRequestList[index], firestore, "Accept");
            }));
  }

  @override
  void initState() {
    super.initState();
    loadFriendRequests();
    _friendSearchController.addListener(_friendSearchControllerListener);
  }

  @override
  void dispose() {
    _friendSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      // Friend requests
      Container(
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: circleColor,
          width: 1,
        ))),
        child: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: 60.0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Text("Friend requests", style: header1),
          elevation: 0,
        ),
      ),
      _buildFriendRequestsList(context),
      // Find friends
      AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 60.0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text("Find friends", style: header1),
        elevation: 0,
      ),
      AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 60.0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: TextField(
                controller: _friendSearchController,
                focusNode: _focusNode,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: "Search by username",
                  hintStyle: const TextStyle(fontSize: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(0),
                  fillColor: circleColor,
                  filled: true,
                  prefixIcon: InkWell(
                    onTap: () => {_focusNode.requestFocus()},
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      decoration: circleInkwellBoxDecoration,
                      child: const Icon(
                        Icons.search,
                        color: darkGray,
                      ),
                    ),
                  ),
                )),
          )),
      Expanded(
          child: ListView.builder(
              itemCount: findFriendsList.length,
              itemBuilder: (BuildContext context, int index) {
                return AddFriendCard(
                    TsUser(
                      findFriendsList[index].user.name,
                      findFriendsList[index].user.username,
                      findFriendsList[index].user.fbDocId,
                      findFriendsList[index].user.id,
                    ),
                    firestore,
                    findFriendsList[index].requested
                        ? "Requested"
                        : "Add Friend");
              }))
    ]));
  }
}
