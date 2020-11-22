import 'package:flutter/material.dart';
import 'package:usingGithubApi/templates/User.dart';
import 'package:usingGithubApi/templates/Starred.dart';
import 'package:usingGithubApi/templates/Repo.dart';
import 'package:usingGithubApi/templates/Gist.dart';
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
  bool starLoading = true, repoLoading = true, gistLoading = true,followersLoading = true, followingLoading = true;
  bool starData = false, repoData = false, gistData = false, followersData = false, followingData = false;

  String username, user;
  ProfileState({this.username, this.user}) {
    this.username = username;
  }

  String baseUrl = "https://api.github.com/users";
  String getUrl() {
    return baseUrl + user + "/";
  }

  var resBody;

  List<Repo> _repo = [];
  List<Gist> _gist = [];
  List<Starred> _starred = [];
  List<User> _followers = [];
  List<User> _following = [];

  getStarred() async {
    var res = await http
        .get(getUrl() + "starred", headers: {'Accept': 'application/json'});
    resBody = json.decode(res.body);

    setState(() {
      for (var data in resBody) {
        _starred.add(
          new Starred(
            data['name'],
            data['stargazersCount'],
            data['forksCount'],
            data['language']
          )
        );
        starData = true;
      }
      starLoading = false;
    });
  }

  getRepo() async {
    var res = await http
      .get(getUrl() + "repos", headers: {"Accept": "application/json"});      
    resBody = json.decode(res.body);

    setState(() {
      for(var data in resBody){
        _repo.add(
            new Repo(
                data['name'],
                data['description'],
                data['stargazersCount'],
                data['forksCount'],
                data['language']
            ));
        repoData = true;
      }
    });
    repoLoading = false;
  }

  getGist() async{
    var res = await http.get(
      getUrl() + "gists", headers: {"Accept": "application/json"}
    );
    resBody = json.decode(res.body);

    setState(() {
      for(var data in resBody){
        _gist.add(
            new Gist(
                description : data['files'].keys.first,
                createdAt : data['createdAt']
            ));
        gistData = true;
      }

      gistLoading = false;
    });
  }

  getFollowers() async{
    var res = await http.get(
      getUrl()+"followers", headers: {"Accept": "application/json"}
    );
    resBody = json.decode(res.body);

    setState(() {
      for(var data in resBody){
        _followers.add(
            new User(
              text: data['login'],
              image: data['avatarUrl'],
            ));
        followersData =  true;
      }
      followersLoading = false;
    });
  }

  getFollowing() async{
    var res = await http.get(
      getUrl()+"following", headers: {"Accept": "application/json"}
    );
    resBody = json.decode(res.body);

    setState(() {
      for(var data in resBody){
        _following.add(
            new User(
              text: data['login'],
              image: data['avatarUrl'],
            ));

        followingData = true;
      }
    });
    followingLoading = false;
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
                    new Tab(child: new Text("Overview")),
                    new Tab(child: new Text("Repository")),
                    new Tab(child: new Text("Gists")),
                    new Tab(child: new Text("Starred")),
                    new Tab(child: new Text("Follower")),
                    new Tab(child: new Text("Following")),
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
                )
              ),
              new Container(child: _repoData()),
              new Container(child: _gistData()),
              new Container(child: _starredData()),
              new Container(child: _followersData()),
              new Container(child: _followingData()),
            ]),
          )),
    );
  }

  @override
  void initState() {
  // ignore: todo
  //  TODO: implementar initState
    super.initState();

    getStarred();
    getRepo();
  }

  Widget _repoData() {
      if(repoLoading){
        return new Center(
          child: new CircularProgressIndicator(),
        );
      }else if(!repoData){
        return new Center(
          child:new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  "$user have No Repo",
                  style: Theme.of(context).textTheme.display1
                )
              ]
          ),
        );
      }else{
        return new Column(
          children: <Widget>[
            new Flexible(
                child: new ListView.builder(
                  padding: new EdgeInsets.all(8.0),
                  itemBuilder: (_, int index) => _repo[index],
                  itemCount: _repo.length,
                )
            )
          ],
        );
      }
    }

  Widget _gistData() {
    if(gistLoading){
      return new Center(
        child: new CircularProgressIndicator(),
      );
    }else if(!gistData){
      return new Center(
        child:new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                "$user have No Gists",
                style: Theme.of(context).textTheme.display1
              )
            ]
        ),
      );
    }else{
      return new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
                padding: new EdgeInsets.all(8.0),
                itemBuilder: (_, int index) => _gist[index],
                itemCount: _gist.length,
              )
          )
        ],
      );
    }
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

  Widget _followingData() {
    if(followingLoading){
      return new Center(
        child: new CircularProgressIndicator(),
      );
    }else if(!followingData){
      return new Center(
        child:new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                "$user is not following to anyone",
                style: Theme.of(context).textTheme.display1
              )
            ]
        ),
      );
    }else{
      return new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
                padding: new EdgeInsets.all(8.0),
                itemBuilder: (_, int index) => _following[index],
                itemCount: _following.length,
              )
          )
        ],
      );
    }
  }

  Widget _followersData() {
    if(followersLoading){
      return new Center(
        child: new CircularProgressIndicator(),
      );
    }else if(!followersData){
      return new Center(
        child:new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              "$user have no Follower",
              style: Theme.of(context).textTheme.display1
            )
          ]
        ),
      );
    }else{
      return new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
                padding: new EdgeInsets.all(8.0),
                itemBuilder: (_, int index) => _followers[index],
                itemCount: _followers.length,
              )
          )
        ],
      );
    }
  }
}