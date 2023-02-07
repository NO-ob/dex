/// Gets the id from an api url
class StringUtils {
  static int getIdFromUrl(String url) {
    List<String> splitURL = url.split("/");
    int? id = int.tryParse(splitURL[splitURL.length - 2]);

    if (id == null) {
      throw Exception("No id in url $url");
    }
    return id;
  }
}
