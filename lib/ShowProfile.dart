import 'package:flutter/material.dart';
import 'package:usingGithubApi/templates/Starred.dart';
import 'package:usingGithubApi/templates/User.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowProfile extends StatefulWidget {
  final String username, user;
  ShowProfile({this.username, this.user});

  @override
  State<StatefulWidget> createState() {
    return new ProfileState(username: username, user: user);
  }
}

class ProfileState extends State<ShowProfile> {
  bool starLoading = true;
  bool starData = false;

  String username, user;
  ProfileState({this.username, this.user}) {
    this.username = username;
  }

  String baseUrl = "https://api.github.com/users";
  String getUrl() {
    return baseUrl + user + "/";
  }

  var resBody;

  List<Starred> _starred = [];

  getStarred() async {
    var res = await http
        .get(getUrl() + "starred", headers: {'Accept': 'application/json'});
    resBody = json.decode(res.body);

    setState(() {
      for (var data in resBody) {
        _starred.add(new Starred(data['name'], data['stargazersCount'],
            data['forksCount'], data['language']));
        starData = true;
      }
      starLoading = false;
    });
  }
}

@override
Widget build(BuildContext context) {
  return new MaterialApp(
    title: "Profile",
    home: new DefaultTabController(
        length: 6,
        child: new Scaffold(
          appBar: new AppBar(
              title: new Text(username),
              bottom: new TabBar(
                isScrollable: true,
                tabs: [
                  new Tab(
                    child: new Text("Starred"),
                  )
                ],
              )),
          body: new TabBarView(children: [
            new Center(
                child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Icon(Icons.code, size: 100.0),
                new Text("Overview",
                    style: Theme.of(context).textTheme.display2),
              ],
            )),
            new Container(child: _starredData())
          ]),
        )),
  );
}

@override
void initState() {
  super.initState();

  getStarred();
}

Widget _starredData() {
  if (starLoading) {
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            "$user haven't starred any repo",
            style: Theme.of(context).textTheme.display1
          )
        ]
      ),
    );
  } else {
    return new Column(
      children: <Widget>[
        new Flexible(
          child: new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            itemBuilder: (_, int index) => _starred[index],
            itemCount: _starred.length,
          )
        )
      ]
    );
  }
}
