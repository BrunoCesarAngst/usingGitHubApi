class Url {
  final String gitHub = "https://api.github.com/users";
  final String username;

  Url({this.username});

  String getUserGitHub() {
    return gitHub + username;
  }

  String getUserGists() {
    return getUserGitHub() + "/gists";
  }

  String getUserStarred() {
    return getUserGitHub() + "/starred";
  }

  String getUserFollowers() {
    return getUserGitHub() + "/followers";
  }

  String getUserFollowings() {
    return getUserGitHub() + "/following";
  }
}
