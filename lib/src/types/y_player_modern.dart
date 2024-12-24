class ModernPlayerVideoData {
  /// Name of quality, This will be displayed in video player quality selector menu.
  String label = "";

  /// Url or path of the video.
  String source = "";

  String? backendId;



  /// This can define type of data source of Modern Player.
  ModernPlayerSourceType sourceType = ModernPlayerSourceType.asset;

  ///Constructs a [ModernPlayerVideoData] playing a video from obtained from the network.
  ///
  ///The URL for the video is given by the [url] argument and must not be null
  ///and the [label] is displayed on quality selection on menu.
  ModernPlayerVideoData.network({required this.label, required String url}) {
    source = url;
    sourceType = ModernPlayerSourceType.network;
  }

  ///Constructs a [ModernPlayerVideoData] playing a video from obtained from the local file.
  ///
  ///The Path for the video is given by the [path] argument and must not be null.
  ///And the [label] is displayed on quality selection on menu.
  ModernPlayerVideoData.file({required this.label, required String path}) {
    source = path;
    sourceType = ModernPlayerSourceType.file;
  }

  ///Constructs a [ModernPlayerVideoData] playing a video from obtained from the youtube.
  ///
  ///The url of the youtube video is given by the [url] argument and must not be null.
  ///And the [label] is displayed on quality selection on menu.
  ModernPlayerVideoData.youtubeWithUrl(
      {required this.label, required String url}) {
    String? videoId = _youtubeParser(url);

    if (videoId == null) {
      throw Exception("Cannot get video from url. Please try with ID");
    }

    source = videoId;
    sourceType = ModernPlayerSourceType.youtube;
  }

  ///Constructs a [ModernPlayerVideoData] playing a video from obtained from the youtube.
  ///
  ///The Id of the youtube video is given by the [id] argument and must not be null.
  ///And the [label] is displayed on quality selection on menu.
  ModernPlayerVideoData.youtubeWithId(
      {required this.label, required String id}) {
    source = id;
    sourceType = ModernPlayerSourceType.youtube;
  }

  ///Constructs a [ModernPlayerVideoData] playing a video from obtained from the assets.
  ///
  ///The Path for the video is given by the [path] argument and must not be null.
  ///And the [label] is displayed on quality selection on menu.
  ModernPlayerVideoData.asset({required this.label, required String path}) {
    source = path;
    sourceType = ModernPlayerSourceType.asset;
  }

  // Get youtube video id from url
  String? _youtubeParser(String url) {
    final regExp = RegExp(
        r'^.*((youtu.be/)|(v/)|(\/u/\w/)|(embed/)|(watch\?))\??v?=?([^#&?]*).*');
    final match = regExp.firstMatch(url);
    return (match != null && match.group(7)!.length == 11)
        ? match.group(7)
        : null;
  }
}

/// ModernPlayerVideoDataYoutube is an internal class which used for accessing all qualities of video from youtube and merging an audio
class ModernPlayerVideoDataYoutube extends ModernPlayerVideoData {
  /// Url of audio for override [For youtube only]
  String audioOverride;

  ModernPlayerVideoDataYoutube.network(
      {required super.label, required super.url, required this.audioOverride})
      : super.network();
}

enum ModernPlayerSourceType {
  /// The video is downloaded from the internet.
  network,

  /// The video is load from the local filesystem.
  file,

  /// The video is load from the youtube.
  youtube,

  /// The video is load from asset
  asset
}

class VideoData {
  String? youtubeId;
  int backendId = 0;
  String channelUrl = "";
  List<dynamic> comments = [];
  String description = "";
  String name = "";
}