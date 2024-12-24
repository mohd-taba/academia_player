import 'dart:async';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:y_player/src/types/y_player_modern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:y_player/y_player.dart';

/// A customizable YouTube video player widget.
///
/// This widget provides a flexible way to embed and control YouTube videos
/// in a Flutter application, with options for customization and event handling.
class YPlayer extends StatefulWidget {
  /// The URL of the YouTube video to play.
  final String youtubeUrl;

  /// The aspect ratio of the video player. If null, defaults to 16:9.
  final double? aspectRatio;

  /// Whether the video should start playing automatically when loaded.
  final bool autoPlay;

  /// The primary color for the player's UI elements.
  final Color? color;

  /// A widget to display while the video is not yet loaded.
  final Widget? placeholder;

  /// A widget to display while the video is loading.
  final Widget? loadingWidget;

  /// A widget to display if there's an error loading the video.
  final Widget? errorWidget;

  /// A callback that is triggered when the player's state changes.
  final YPlayerStateCallback? onStateChanged;

  /// A callback that is triggered when the video's playback progress changes.
  final YPlayerProgressCallback? onProgressChanged;

  /// A callback that is triggered when the player controller is ready.
  final Function(YPlayerController controller)? onControllerReady;

  /// A callback that is triggered when the player enters full screen mode.
  final Function()? onEnterFullScreen;

  /// A callback that is triggered when the player exits full screen mode.
  final Function()? onExitFullScreen;

  /// The margin around the seek bar.
  final EdgeInsets? seekBarMargin;

  /// The margin around the seek bar in fullscreen mode.
  final EdgeInsets? fullscreenSeekBarMargin;

  /// The margin around the bottom button bar.
  final EdgeInsets? bottomButtonBarMargin;

  /// The margin around the bottom button bar in fullscreen mode.
  final EdgeInsets? fullscreenBottomButtonBarMargin;

  ///Video Playlist
  final List<ModernPlayerVideoData>? videoList;

  /// Video data to be viewed, eg. comments etc...
  VideoData videoData = VideoData();

  /// Constructs a YPlayer widget.
  ///
  /// The [youtubeUrl] parameter is required and should be a valid YouTube video URL.
  YPlayer({
    Key? key,
    required this.youtubeUrl,
    required this.videoData,
    this.aspectRatio,
    this.autoPlay = true,
    this.placeholder,
    this.loadingWidget,
    this.errorWidget,
    this.onStateChanged,
    this.onProgressChanged,
    this.onControllerReady,
    this.color,
    this.onEnterFullScreen,
    this.onExitFullScreen,
    this.seekBarMargin,
    this.fullscreenSeekBarMargin,
    this.bottomButtonBarMargin,
    this.fullscreenBottomButtonBarMargin, this.videoList,
  }) : super(key: key);

  @override
  YPlayerState createState() => YPlayerState();
}

/// The state for the YPlayer widget.
///
/// This class manages the lifecycle of the video player and handles
/// initialization, playback control, and UI updates.
class YPlayerState extends State<YPlayer> with SingleTickerProviderStateMixin {
  /// The controller for managing the YouTube player.
  late YPlayerController _controller;

  /// The controller for the video display.
  late VideoController _videoController;

  /// Flag to indicate whether the controller is fully initialized and ready.
  bool _isControllerReady = false;
  late ValueChanged<double> onSpeedChanged;
  double currentSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    // Initialize the YPlayerController with callbacks
    _controller = YPlayerController(
      onStateChanged: widget.onStateChanged,
      onProgressChanged: widget.onProgressChanged,
    );
    // Create a VideoController from the player in YPlayerController
    _videoController = VideoController(_controller.player);
    // Start the player initialization process
    _initializePlayer();
  }

  /// Initializes the video player with the provided YouTube URL and settings.
  void _initializePlayer() async {
    try {
      // Attempt to initialize the player with the given YouTube URL and settings
      await _controller.initialize(
        widget.youtubeUrl,
        autoPlay: widget.autoPlay,
        aspectRatio: widget.aspectRatio,
      );
      if (mounted) {
        // If the widget is still in the tree, update the state
        setState(() {
          _isControllerReady = true;
        });
        // Notify that the controller is ready, if a callback was provided
        if (widget.onControllerReady != null) {
          widget.onControllerReady!(_controller);
        }
      }
    } catch (e) {
      // Log any errors that occur during initialization
      debugPrint('YPlayer: Error initializing player: $e');
      if (mounted) {
        // If there's an error, set the controller as not ready
        setState(() {
          _isControllerReady = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Ensure the controller is properly disposed when the widget is removed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [LayoutBuilder(
        builder: (context, constraints) {
          // Calculate the player dimensions based on the available width and aspect ratio
          final aspectRatio = widget.aspectRatio ?? 16 / 9;
          final playerWidth = constraints.maxWidth;
          final playerHeight = playerWidth / aspectRatio;

          return Container(
            width: playerWidth,
            height: playerHeight,
            color: Colors.transparent,
            child: _buildPlayerContent(playerWidth, playerHeight),
          );
        },
      ), widget.videoList != null ? Playlist(currentlyPlaying: widget.youtubeUrl, videos: widget.videoList!, controller: _controller) : const SizedBox()]
    );
  }

  Widget buildSpeedOption() {
    return PopupMenuButton<double>(
      icon: const Icon(Icons.speed, color: Colors.white),
      initialValue: currentSpeed,
      onSelected: (value) {
        setState(() {
          currentSpeed = value;
          _controller.speed(currentSpeed);
          print("Change speed $currentSpeed");
        });

        // Notify parent widget of the new speed
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 0.5,
          child: Text("0.5x"),
        ),
        const PopupMenuItem(
          value: 1.0,
          child: Text("1.0x (Normal)"),
        ),
        const PopupMenuItem(
          value: 1.5,
          child: Text("1.5x"),
        ),
        const PopupMenuItem(
          value: 2.0,
          child: Text("2.0x"),
        ),
      ],
    );
  }

  /// Builds the main content of the player based on its current state.
  Widget _buildPlayerContent(double width, double height) {
    if (_isControllerReady && _controller.isInitialized) {
      _controller.speed(currentSpeed);
      // If the controller is ready and initialized, show the video player
      return MaterialVideoControlsTheme(
        normal: MaterialVideoControlsThemeData(
          seekBarBufferColor: Colors.grey,
          seekOnDoubleTap: true,
          seekBarPositionColor: widget.color ?? const Color(0xFFFF0000),
          seekBarThumbColor: widget.color ?? const Color(0xFFFF0000),
          seekBarMargin: widget.seekBarMargin ?? EdgeInsets.zero,
          bottomButtonBarMargin: widget.bottomButtonBarMargin ??
              const EdgeInsets.only(left: 16, right: 8),
          brightnessGesture: true,
          volumeGesture: true,
          bottomButtonBar: [
            const MaterialPositionIndicator(),
            const Spacer(),
            buildSpeedOption(),
            SettingsButton(controller: _controller,),
            const MaterialFullscreenButton()
          ],
        ),
        fullscreen: MaterialVideoControlsThemeData(
          volumeGesture: true,
          brightnessGesture: true,
          seekOnDoubleTap: true,
          seekBarMargin: widget.fullscreenSeekBarMargin ?? EdgeInsets.zero,
          bottomButtonBarMargin: widget.fullscreenBottomButtonBarMargin ??
              const EdgeInsets.only(left: 16, right: 8),
          seekBarBufferColor: Colors.grey,
          seekBarPositionColor: widget.color ?? const Color(0xFFFF0000),
          seekBarThumbColor: widget.color ?? const Color(0xFFFF0000),
          bottomButtonBar: [
            const MaterialPositionIndicator(),
            const Spacer(),
            buildSpeedOption(),
            SettingsButton(controller: _controller,),
            const MaterialFullscreenButton()
          ],
        ),
        child: Video(
          controller: _videoController,
          controls: MaterialVideoControls,
          width: width,
          height: height,
          onEnterFullscreen: () async {
            if (widget.onEnterFullScreen != null) {
              return widget.onEnterFullScreen!();
            } else {
              return yPlayerDefaultEnterFullscreen();
            }
          },
          onExitFullscreen: () async {
            if (widget.onExitFullScreen != null) {
              return widget.onExitFullScreen!();
            } else {
              return yPlayerDefaultExitFullscreen();
            }
          },
        ),
      );
    } else if (_controller.status == YPlayerStatus.loading) {
      // If the video is still loading, show a loading indicator
      return Center(
        child:
            widget.loadingWidget ?? const CircularProgressIndicator.adaptive(),
      );
    } else if (_controller.status == YPlayerStatus.error) {
      // If there was an error, show the error widget
      return Center(
        child: widget.errorWidget ?? const Text('Error loading video'),
      );
    } else {
      // For any other state, show the placeholder or an empty container
      return widget.placeholder ?? Container();
    }
  }
  
  
  
}

/// stolen from podplayer
ListTile _bottomSheetTiles({
  required String title,
  required IconData icon,
  String? subText,
  void Function()? onTap,
}) {
  return ListTile(
    leading: Icon(icon),
    onTap: onTap,
    title: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(
            title,
          ),
          if (subText != null) const SizedBox(width: 6),
          if (subText != null)
            const SizedBox(
              height: 4,
              width: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          if (subText != null) const SizedBox(width: 6),
          if (subText != null)
            Text(
              subText,
              style: const TextStyle(color: Colors.grey),
            ),
        ],
      ),
    ),
  );
}

MaterialVideoControlsThemeData _theme(BuildContext context) =>
    FullscreenInheritedWidget.maybeOf(context) == null
        ? MaterialVideoControlsTheme.maybeOf(context)?.normal ??
        kDefaultMaterialVideoControlsThemeData
        : MaterialVideoControlsTheme.maybeOf(context)?.fullscreen ??
        kDefaultMaterialVideoControlsThemeDataFullscreen;

class SettingsButton extends StatelessWidget {
  final Color? iconColor;
  final YPlayerController controller;
  const SettingsButton({super.key, required this.controller, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: iconColor ?? _theme(context).buttonBarButtonColor,
        onPressed: () {
          showModalBottomSheet<void>(
              context: context,
              builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        _bottomSheetTiles(
                          title: "Quality",
                          icon: Icons.video_settings_rounded,

                          //subText: '${podCtr.vimeoPlayingVideoQuality}p',
                          onTap: () {
                            Navigator.of(context).pop();
                            Timer(const Duration(milliseconds: 100), () {
                              showModalBottomSheet<void>(
                                context: context,
                                builder: (context) => SafeArea(
                                  child: _VideoQualitySelectorMob(
                                    onTap: null,
                                    controller: controller,
                                  ),
                                ),
                              );
                            });
                            // await Future.delayed(
                            //   const Duration(milliseconds: 100),
                            // );
                          },
                        ),
                    ],
                  ),
              ));
        },
        icon: Icon(Icons.settings));

  }
}

class _VideoQualitySelectorMob extends StatelessWidget {
  final YPlayerController controller;
  final void Function()? onTap;

  const _VideoQualitySelectorMob({
    required this.onTap, required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: controller.videosData
            .map(
              (e) => ListTile(
            title: Text('${e.label}'),
            onTap: () {
              onTap != null ? onTap!() : Navigator.of(context).pop();
              controller.changeQuality(e);
            },
          ),
        )
            .toList(),
      ),
    );
  }
}

class Playlist extends StatefulWidget {
  final YPlayerController controller;
  String currentlyPlaying;
  List<ModernPlayerVideoData> videos = [];
  VideoData videoData = VideoData();

  Playlist(
      {super.key, required this.currentlyPlaying, required this.videos, required this.controller});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(5.0),

      decoration: BoxDecoration(
          border: Border.all(color: Colors.pinkAccent, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: widget.videos
              .map(
                (e) {
                  var videoId = _youtubeParser(e.source);
                  String thumbnailUrl = (videoId == null) ? "" : "https://img.youtube.com/vi/${videoId}/default.jpg";
                  return Container(
                    decoration: BoxDecoration(
                        border: Border.all(),
                        color: e.source != widget.currentlyPlaying
                            ? Theme.of(context).colorScheme.surface
                            : Colors.pink[50],
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    margin: EdgeInsets.all(5.0),
                    child: ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(color: Colors.black),
                                right: BorderSide(color: Colors.black))),
                        child: CachedNetworkImage(
                          imageUrl: thumbnailUrl,
                          placeholder: (context, url) => SizedBox(
                            child: Center(child: CircularProgressIndicator()),
                            width: 120.0,
                          ),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                      title: Text(e.label),
                      trailing: e.source != widget.currentlyPlaying
                          ? Icon(Icons.play_arrow)
                          : Text("Now playing"),
                      onTap: () {
                        setState(() {
                          widget.controller.changeVideo(e);

                          widget.currentlyPlaying = e.source;
                        });
                        },
                    ),
                  );
                }).toList(),
        ),
    );
  }
}

String? _youtubeParser(String url) {
  final regExp = RegExp(
      r'^.*((youtu.be/)|(v/)|(\/u/\w/)|(embed/)|(watch\?))\??v?=?([^#&?]*).*');
  final match = regExp.firstMatch(url);
  return (match != null && match.group(7)!.length == 11)
      ? match.group(7)
      : null;
}