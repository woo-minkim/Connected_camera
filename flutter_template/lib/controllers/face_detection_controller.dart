import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:fluttertemplate/services/camera_service.dart';
import 'package:fluttertemplate/services/display_service.dart';
import 'package:fluttertemplate/webos_service_helper/utils.dart';

enum ViewingMode { idle, solo, group }

enum DistanceLevel { near, mid, far }

enum AutoPauseState { inactive, countdown, paused }

class FaceInfo {
  const FaceInfo({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
  });

  factory FaceInfo.fromMap(Map<String, dynamic> map) {
    final double x = _findValue(map, _xKeys);
    final double y = _findValue(map, _yKeys);
    final double w = _findValue(map, _wKeys);
    final double h = _findValue(map, _hKeys);
    final double conf = _findValue(map, _confidenceKeys);
    return FaceInfo(
      x: x,
      y: y,
      width: w,
      height: h,
      confidence: conf == 0 ? 1 : conf,
    );
  }

  factory FaceInfo.mock({
    double x = 0.45,
    double y = 0.4,
    double width = 320,
    double height = 320,
    double confidence = 0.95,
  }) {
    return FaceInfo(
      x: x,
      y: y,
      width: width,
      height: height,
      confidence: confidence,
    );
  }

  final double x;
  final double y;
  final double width;
  final double height;
  final double confidence;

  static const Set<String> _xKeys = {
    'x',
    'posx',
    'positionx',
    'centerx',
    'cx',
    'left'
  };
  static const Set<String> _yKeys = {
    'y',
    'posy',
    'positiony',
    'centery',
    'cy',
    'top'
  };
  static const Set<String> _wKeys = {
    'w',
    'width',
    'sizew',
    'sizex',
    'rectwidth',
    'bboxwidth'
  };
  static const Set<String> _hKeys = {
    'h',
    'height',
    'sizeh',
    'sizey',
    'rectheight',
    'bboxheight'
  };
  static const Set<String> _confidenceKeys = {
    'confidence',
    'score',
    'prob',
    'probability'
  };

  static double _findValue(
    Map<String, dynamic> map,
    Set<String> keySet, [
    double defaultValue = 0,
  ]) {
    final queue = <dynamic>[map];
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (current is Map) {
        final typedMap = current is Map<String, dynamic>
            ? current
            : Map<String, dynamic>.from(current);
        for (final entry in typedMap.entries) {
          final key = entry.key.toString().toLowerCase();
          final value = entry.value;
          if (keySet.contains(key)) {
            if (value is Map || value is List) {
              queue.add(value);
              continue;
            }
            return _asDouble(value);
          }
          if (value is Map || value is List) {
            queue.add(value);
          }
        }
      } else if (current is List) {
        queue.addAll(current);
      }
    }
    return defaultValue;
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  double get normalizedWidth {
    if (width <= 1) return width;
    return (width / 1280).clamp(0, 1);
  }

  double get normalizedHeight {
    if (height <= 1) return height;
    return (height / 720).clamp(0, 1);
  }

  double get normalizedArea => normalizedWidth * normalizedHeight;

  double get avgNormalizedSize => (normalizedWidth + normalizedHeight) / 2.0;
}

class FaceEvent {
  FaceEvent({required this.faceCount, required this.faces});

  factory FaceEvent.fromCameraPayload(Map<String, dynamic> payload) {
    final parser = _FacePayloadParser()..parse(payload);
    final faces = parser.faceMaps
        .map((face) => FaceInfo.fromMap(face))
        .toList(growable: false);
    final count = parser.faceCount ?? faces.length;
    return FaceEvent(faceCount: count, faces: faces);
  }

  final int faceCount;
  final List<FaceInfo> faces;
}

class _FacePayloadParser {
  int? faceCount;
  final List<Map<String, dynamic>> faceMaps = [];
  final Set<int> _processedFaceNodes = <int>{};

  static final Set<String> _countKeys = {
    'facecount',
    'count',
    'numfaces',
    'peoplecount',
    'personcount'
  };

  void parse(dynamic node) {
    if (node is Map) {
      final map =
          node is Map<String, dynamic> ? node : Map<String, dynamic>.from(node);
      map.forEach((rawKey, value) {
        final key = rawKey.toString().toLowerCase();
        if (_countKeys.contains(key)) {
          final parsed = _tryParseInt(value);
          if (parsed != null) {
            faceCount = parsed;
          }
        }
        if (key.contains('face') && key != 'facecount') {
          _ingestFaces(value);
        }
        parse(value);
      });
    } else if (node is List) {
      for (final item in node) {
        parse(item);
      }
    }
  }

  void _ingestFaces(dynamic value) {
    if (value is! Map && value is! List) return;
    final nodeId = identityHashCode(value);
    if (!_processedFaceNodes.add(nodeId)) return;
    if (value is List) {
      for (final entry in value) {
        _ingestFaces(entry);
      }
    } else if (value is Map<String, dynamic>) {
      if (_looksLikeSingleFace(value)) {
        faceMaps.add(value);
      } else {
        for (final child in value.values) {
          _ingestFaces(child);
        }
      }
    } else if (value is Map) {
      final typed = Map<String, dynamic>.from(value);
      _ingestFaces(typed);
    }
  }

  bool _looksLikeSingleFace(Map<String, dynamic> map) {
    final lowerKeys =
        map.keys.map((key) => key.toString().toLowerCase()).toSet();
    final hasCoord = lowerKeys.any(
          (key) =>
              FaceInfo._xKeys.contains(key) || FaceInfo._yKeys.contains(key),
        ) ||
        map.entries.any((entry) =>
            entry.value is Map &&
            (entry.key.toString().toLowerCase().contains('bbox') ||
                entry.key.toString().toLowerCase().contains('rect') ||
                entry.key.toString().toLowerCase().contains('roi')));
    final hasSize = lowerKeys.any(
      (key) => FaceInfo._wKeys.contains(key) || FaceInfo._hKeys.contains(key),
    );
    return hasCoord && hasSize;
  }

  int? _tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class FaceDetectionController extends ChangeNotifier {
  FaceDetectionController({
    Duration autoPauseDelay = const Duration(seconds: 10),
    bool mockMode = false,
  })  : _autoPauseDelay = autoPauseDelay,
        _mockRequested = mockMode;

  final Duration _autoPauseDelay;
  final DisplayService _displayService = DisplayService();

  bool _mockRequested;
  bool _initialized = false;
  bool _initializing = false;
  bool _playbackActive = false;
  String? _lastError;
  int? _cameraSubscription;
  Timer? _noViewerTimer;
  Timer? _mockTimer;
  DateTime? _autoPauseDeadline;

  int _faceCount = 0;
  List<FaceInfo> _faces = const [];
  ViewingMode _viewingMode = ViewingMode.idle;
  DistanceLevel _distanceLevel = DistanceLevel.mid;
  AutoPauseState _autoPauseState = AutoPauseState.inactive;
  int? _brightnessLevel;
  Map<String, dynamic>? _lastRawEvent;

  int get faceCount => _faceCount;
  List<FaceInfo> get faces => List.unmodifiable(_faces);
  ViewingMode get viewingMode => _viewingMode;
  DistanceLevel get distanceLevel => _distanceLevel;
  AutoPauseState get autoPauseState => _autoPauseState;
  bool get initialized => _initialized;
  bool get initializing => _initializing;
  bool get playbackActive => _playbackActive;
  bool get mockModeEnabled => _mockRequested;
  String? get lastError => _lastError;
  Map<String, dynamic>? get lastRawEvent => _lastRawEvent;

  double get textScaleFactor {
    switch (_distanceLevel) {
      case DistanceLevel.near:
        return 0.95;
      case DistanceLevel.mid:
        return 1.0;
      case DistanceLevel.far:
        return 1.12;
    }
  }

  int get suggestedBrightness {
    switch (_distanceLevel) {
      case DistanceLevel.near:
        return 40;
      case DistanceLevel.mid:
        return 60;
      case DistanceLevel.far:
        return 85;
    }
  }

  int get autoPauseRemainingSeconds {
    if (_autoPauseState != AutoPauseState.countdown ||
        _autoPauseDeadline == null) {
      return 0;
    }
    final diff = _autoPauseDeadline!.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return diff.inSeconds;
  }

  Future<void> initialize() async {
    if (_initialized || _initializing) return;
    _initializing = true;
    _lastError = null;
    notifyListeners();
    try {
      if (_mockRequested) {
        _startMockStream();
      } else {
        await _setupCameraPipeline();
      }
      _initialized = true;
    } catch (error, stackTrace) {
      debugPrint('FaceDetection initialization failed: $error');
      debugPrint(stackTrace.toString());
      _lastError = error.toString();
      _startMockStream();
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  Future<void> _setupCameraPipeline() async {
    await CameraService.intallModel();
    final cameraList = await CameraService.getCameraList();
    final String? cameraId = _extractCameraId(cameraList);
    if (cameraId == null) {
      throw StateError('No camera device found.');
    }
    await CameraService.setPermission();
    final openResult = await CameraService.openCamera(cameraId);
    final int handle = _extractHandle(openResult);
    await CameraService.setFormat(handle);
    await CameraService.startPreview(handle);
    await CameraService.setSolutions(cameraId);
    _cameraSubscription =
        CameraService.getEventNotification(cameraId, _handleCameraEvent);
  }

  Future<void> disposeController() async {
    _mockTimer?.cancel();
    _mockTimer = null;
    _cancelNoViewerTimer();
    if (_cameraSubscription != null) {
      cancel(_cameraSubscription!);
      _cameraSubscription = null;
    }
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  void _handleCameraEvent(dynamic data) {
    Map<String, dynamic>? payload;
    if (data is Map<String, dynamic>) {
      payload = data;
    } else if (data is Map) {
      payload = Map<String, dynamic>.from(data);
    } else {
      return;
    }
    try {
      _lastRawEvent = payload;
      final event = FaceEvent.fromCameraPayload(payload);
      _handleFaceEvent(event);
    } catch (error) {
      debugPrint('Failed to parse face event: $error');
    }
  }

  void _handleFaceEvent(FaceEvent event) {
    _faceCount = event.faceCount;
    _faces = event.faces;
    _updateViewingMode();
    _updateDistanceLevel();
    _evaluateAutoPauseState();
    notifyListeners();
  }

  void _updateViewingMode() {
    if (_faceCount == 0) {
      _viewingMode = ViewingMode.idle;
    } else if (_faceCount == 1) {
      _viewingMode = ViewingMode.solo;
    } else {
      _viewingMode = ViewingMode.group;
    }
  }

  void _updateDistanceLevel() {
    if (_faces.isEmpty) {
      _distanceLevel = DistanceLevel.mid;
      return;
    }
    final FaceInfo primary = _faces.first;
    final double metric = primary.avgNormalizedSize;
    DistanceLevel nextLevel;
    if (metric >= 0.35) {
      nextLevel = DistanceLevel.near;
    } else if (metric <= 0.18) {
      nextLevel = DistanceLevel.far;
    } else {
      nextLevel = DistanceLevel.mid;
    }
    if (nextLevel != _distanceLevel) {
      _distanceLevel = nextLevel;
      _applyDisplayPolicy();
    }
  }

  void pushBrightnessUpdate() {
    _applyDisplayPolicy(force: true);
  }

  Future<void> setManualBrightness(int level) async {
    final safeValue = level.clamp(10, 100);
    _brightnessLevel = safeValue;
    await _displayService.setBrightnessLevel(safeValue);
  }

  void _applyDisplayPolicy({bool force = false}) {
    final int targetBrightness = suggestedBrightness;
    if (!force && _brightnessLevel == targetBrightness) return;
    _brightnessLevel = targetBrightness;
    _displayService.setBrightnessLevel(targetBrightness);
  }

  void _evaluateAutoPauseState() {
    if (!_playbackActive) {
      _cancelNoViewerTimer();
      if (_autoPauseState != AutoPauseState.paused) {
        _autoPauseState = AutoPauseState.inactive;
      }
      return;
    }
    if (_faceCount == 0) {
      if (_autoPauseState == AutoPauseState.inactive) {
        _autoPauseState = AutoPauseState.countdown;
        notifyListeners();
      }
      _startNoViewerCountdown();
    } else {
      final bool changed = _autoPauseState != AutoPauseState.inactive;
      _autoPauseState = AutoPauseState.inactive;
      _cancelNoViewerTimer();
      if (changed) {
        notifyListeners();
      }
    }
  }

  void _startNoViewerCountdown() {
    if (_noViewerTimer != null) return;
    _autoPauseDeadline = DateTime.now().add(_autoPauseDelay);
    _noViewerTimer = Timer(_autoPauseDelay, () {
      _autoPauseDeadline = null;
      _autoPauseState = AutoPauseState.paused;
      _playbackActive = false;
      notifyListeners();
    });
  }

  void _cancelNoViewerTimer() {
    _noViewerTimer?.cancel();
    _noViewerTimer = null;
    _autoPauseDeadline = null;
  }

  void setPlaybackActive(bool active) {
    if (_playbackActive == active) return;
    _playbackActive = active;
    if (!active) {
      _cancelNoViewerTimer();
    }
    _evaluateAutoPauseState();
    notifyListeners();
  }

  void acknowledgeResume() {
    if (_autoPauseState != AutoPauseState.paused) return;
    _autoPauseState = AutoPauseState.inactive;
    notifyListeners();
  }

  static String? _extractCameraId(Map<String, dynamic>? payload) {
    final list = payload?['deviceList'];
    if (list is List && list.isNotEmpty) {
      final device = list.firstWhere(
        (element) => element is Map<String, dynamic>,
        orElse: () => null,
      );
      if (device is Map<String, dynamic>) {
        return device['id'] as String?;
      }
    }
    return null;
  }

  static int _extractHandle(Map<String, dynamic>? payload) {
    final handle = payload?['handle'];
    if (handle is int) return handle;
    if (handle is num) return handle.round();
    throw StateError('Camera handle not found.');
  }

  void _startMockStream() {
    _mockRequested = true;
    _mockTimer?.cancel();
    final sequence = <FaceEvent>[
      FaceEvent(faceCount: 0, faces: []),
      FaceEvent(faceCount: 1, faces: [
        FaceInfo.mock(width: 420, height: 420),
      ]),
      FaceEvent(faceCount: 3, faces: [
        FaceInfo.mock(width: 280, height: 280, x: 0.3),
        FaceInfo.mock(width: 260, height: 260, x: 0.6),
      ]),
      FaceEvent(faceCount: 0, faces: []),
    ];
    int index = 0;
    _mockTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      _handleFaceEvent(sequence[index]);
      index = (index + 1) % sequence.length;
    });
  }
}

class FaceDetectionScope extends InheritedNotifier<FaceDetectionController> {
  const FaceDetectionScope({
    super.key,
    required FaceDetectionController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static FaceDetectionController of(
    BuildContext context, {
    bool listen = true,
  }) {
    FaceDetectionScope? scope;
    if (listen) {
      scope = context.dependOnInheritedWidgetOfExactType<FaceDetectionScope>();
    } else {
      final element =
          context.getElementForInheritedWidgetOfExactType<FaceDetectionScope>();
      scope = element?.widget as FaceDetectionScope?;
    }
    assert(scope != null, 'FaceDetectionScope is not available in context.');
    return scope!.notifier!;
  }
}
