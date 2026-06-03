import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../l10n/app_localizations.dart';
import '../../models/detection/landmark_food_model.dart';
import '../../services/detection/detection_config.dart';
import '../../services/detection/landmark_food_service.dart';
import '../../widgets/detection/detection_result_card.dart';

List<CameraDescription> cameras = [];

class TravelAiScannerScreen extends StatefulWidget {
  const TravelAiScannerScreen({super.key});

  @override
  State<TravelAiScannerScreen> createState() => _TravelAiScannerScreenState();
}

class _TravelAiScannerScreenState extends State<TravelAiScannerScreen>
    with SingleTickerProviderStateMixin {
  CameraController? controller;
  late FlutterVision vision;
  late FlutterTts tts;

  bool isLoaded = false;
  bool isRealtime = false;
  bool isDetecting = false;
  bool voiceEnabled = true;
  bool isClosing = false;
  bool isSimulationMode = false;

  List<Map<String, dynamic>> yoloResults = [];

  String lastSpoken = "";
  int lastTime = 0;

  double speechRate = 0.45;
  double speakCooldown = 3000;
  double confThreshold = 0.50; // default sensitivity

  late AnimationController pulseController;
  Timer? simulationTimer;
  int simulationIndex = 0;
  String? modelLoadError;

  // List of mock labels to cycle through in Simulation Mode
  final List<String> simulationLabels = [
    'monas',
    'borobudur',
    'rendang',
    'gudeg',
    'prambanan',
    'sate'
  ];

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    initScanner();
  }

  Future<void> initScanner() async {
    vision = FlutterVision();
    tts = FlutterTts();

    // Check camera list availability. If empty, try to initialize it.
    if (cameras.isEmpty) {
      try {
        cameras = await availableCameras();
      } catch (e) {
        debugPrint("Error fetching cameras: $e");
      }
    }

    // Try initializing camera if available
    if (cameras.isNotEmpty) {
      controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      try {
        await controller!.initialize();
      } catch (e) {
        debugPrint("Camera initialization failed: $e");
        controller = null;
      }
    }

    // Try loading primary YOLO model, fallback if it fails
    try {
      await vision.loadYoloModel(
        modelPath: DetectionConfig.primaryModelPath,
        labels: DetectionConfig.primaryLabelsPath,
        modelVersion: "yolov8",
        numThreads: 2,
        useGpu: false,
      );
      debugPrint("Primary YOLO model loaded successfully.");
    } catch (e) {
      debugPrint("Primary model failed: $e. Trying fallback demo model...");
      try {
        await vision.loadYoloModel(
          modelPath: DetectionConfig.fallbackModelPath,
          labels: DetectionConfig.fallbackLabelsPath,
          modelVersion: "yolov8",
          numThreads: 2,
          useGpu: false,
        );
        debugPrint("Fallback demo YOLO model loaded successfully.");
      } catch (err) {
        debugPrint("Fallback model failed: $err. Enabling simulation fallback.");
        setState(() {
          modelLoadError = err.toString();
          isSimulationMode = true;
        });
      }
    }

    if (!mounted) return;

    setState(() {
      isLoaded = true;
    });

    if (isSimulationMode) {
      startSimulation();
    } else {
      startRealtime();
    }
  }

  void startRealtime() {
    if (isSimulationMode || isRealtime || controller == null) return;

    setState(() {
      isRealtime = true;
      yoloResults = [];
    });

    controller!.startImageStream((image) async {
      if (!mounted || isClosing || !isRealtime || isDetecting) return;

      isDetecting = true;

      try {
        final result = await vision.yoloOnFrame(
          bytesList: image.planes.map((e) => e.bytes).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          iouThreshold: 0.3,
          confThreshold: confThreshold,
          classThreshold: confThreshold,
        );

        if (!mounted || isClosing || !isRealtime) {
          isDetecting = false;
          return;
        }

        setState(() {
          yoloResults = result;
        });

        if (result.isNotEmpty && voiceEnabled) {
          await speakResult(result.first['tag']);
        }
      } catch (e) {
        debugPrint("YOLO Realtime Inference Error: $e");
      }

      isDetecting = false;
    });
  }

  Future<void> stopRealtime() async {
    if (!isRealtime) return;
    setState(() {
      isRealtime = false;
    });
    if (controller != null && controller!.value.isStreamingImages) {
      await controller!.stopImageStream();
    }
  }

  // Simulation Mode Functions
  void startSimulation() {
    simulationTimer?.cancel();
    setState(() {
      isSimulationMode = true;
      isRealtime = false;
      yoloResults = [];
    });

    // Run simulation timer to trigger mock detections
    simulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (!mounted || isClosing || !isSimulationMode) {
        timer.cancel();
        return;
      }

      final label = simulationLabels[simulationIndex % simulationLabels.length];
      simulationIndex++;

      setState(() {
        yoloResults = [
          {
            'box': [100.0, 180.0, 320.0, 420.0, 0.89], // Mock bounding box coordinates
            'tag': label,
          }
        ];
      });

      if (voiceEnabled) {
        await speakResult(label);
      }
    });
  }

  void stopSimulation() {
    simulationTimer?.cancel();
    setState(() {
      isSimulationMode = false;
      yoloResults = [];
    });
  }

  Future<void> speakResult(String text) async {
    if (!voiceEnabled || isClosing) return;

    final locale = Localizations.localeOf(context).languageCode;
    final info = LandmarkFoodService.getInfo(text, locale);
    final speakText = info.name;

    final now = DateTime.now().millisecondsSinceEpoch;

    if (speakText != lastSpoken || now - lastTime > speakCooldown.toInt()) {
      try {
        await tts.stop();
        await tts.setLanguage(locale == 'id' ? 'id-ID' : 'en-US');
        await tts.setSpeechRate(speechRate);
        await tts.speak(speakText);

        lastSpoken = speakText;
        lastTime = now;
      } catch (e) {
        debugPrint("TTS Error: $e");
      }
    }
  }

  List<Widget> displayBoxes() {
    if (yoloResults.isEmpty) return [];

    final screen = MediaQuery.of(context).size;
    double scaleX = 1.0;
    double scaleY = 1.0;

    if (controller != null && controller!.value.isInitialized) {
      final previewSize = controller!.value.previewSize!;
      // In portrait mode, camera width maps to screen height, height maps to screen width
      scaleX = screen.width / previewSize.height;
      scaleY = screen.height / previewSize.width;
    } else {
      // Default fallback dimensions if camera is null
      scaleX = screen.width / 480.0;
      scaleY = screen.height / 640.0;
    }

    return yoloResults.map((r) {
      final box = r["box"];

      double x = box[0] * scaleX;
      double y = box[1] * scaleY;
      double w = (box[2] > box[0]) ? (box[2] - box[0]) * scaleX : box[2] * scaleX;
      double h = (box[3] > box[1]) ? (box[3] - box[1]) * scaleY : box[3] * scaleY;

      if (w < 0) w = 0;
      if (h < 0) h = 0;

      final tag = r["tag"] as String;
      final info = LandmarkFoodService.getInfo(tag, 'en');
      final isFood = info.category == 'food';

      return Positioned(
        left: x,
        top: y,
        width: w,
        height: h,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isFood ? Colors.orangeAccent : Colors.tealAccent,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isFood ? Colors.orangeAccent : Colors.tealAccent,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Text(
                tag.toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget buildViewfinder() {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white12, width: 1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Viewfinder Corners
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.tealAccent, width: 4),
                    left: BorderSide(color: Colors.tealAccent, width: 4),
                  ),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8)),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.tealAccent, width: 4),
                    right: BorderSide(color: Colors.tealAccent, width: 4),
                  ),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(8)),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.tealAccent, width: 4),
                    left: BorderSide(color: Colors.tealAccent, width: 4),
                  ),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.tealAccent, width: 4),
                    right: BorderSide(color: Colors.tealAccent, width: 4),
                  ),
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
                ),
              ),
            ),
            // Pulsing Scanning Line
            if (isRealtime || isSimulationMode)
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, child) {
                  return Positioned(
                    top: pulseController.value * 250,
                    left: 6,
                    right: 6,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withValues(alpha: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.tealAccent.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTopBar() {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => handleClose(),
                ),
              ),
            ),
          ),
          // Screen Title HUD
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: (isRealtime || isSimulationMode)
                                ? Colors.tealAccent
                                : Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (isRealtime || isSimulationMode)
                                ? l10n.scannerTitleActive
                                : l10n.scannerTitlePaused,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Simulation/Realtime Toggle Mode
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: TextButton.icon(
                  onPressed: () {
                    if (isSimulationMode) {
                      stopSimulation();
                      startRealtime();
                    } else {
                      stopRealtime();
                      startSimulation();
                    }
                  },
                  icon: Icon(
                    isSimulationMode ? Icons.videocam_rounded : Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    isSimulationMode ? "Live" : "Demo",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handleClose() async {
    if (isClosing) return;
    await safeCloseCamera();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> safeCloseCamera() async {
    if (isClosing) return;
    isClosing = true;

    try {
      stopSimulation();
      isRealtime = false;

      // Wait for any active inference to complete
      int waitMs = 0;
      while (isDetecting && waitMs < 2000) {
        await Future.delayed(const Duration(milliseconds: 50));
        waitMs += 50;
      }

      if (controller != null) {
        if (controller!.value.isStreamingImages) {
          await controller!.stopImageStream();
        }
        await Future.delayed(const Duration(milliseconds: 200));
        await controller!.dispose();
      }

      await vision.closeYoloModel();
      await tts.stop();
    } catch (e) {
      debugPrint("Safe Close Error: $e");
    }
  }

  @override
  void dispose() {
    simulationTimer?.cancel();
    pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    if (!isLoaded) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.tealAccent),
              SizedBox(height: 16),
              Text(
                "Loading Travel AI Module...",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Resolve details for currently detected item
    Map<String, dynamic>? detectedItem = yoloResults.isNotEmpty ? yoloResults.first : null;
    LandmarkFoodInfo? foodInfo;
    double confidence = 0.0;

    if (detectedItem != null) {
      final tag = detectedItem['tag'] as String;
      foodInfo = LandmarkFoodService.getInfo(tag, locale);
      confidence = (detectedItem['box'] as List<dynamic>)[4] as double? ?? 0.85;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await handleClose();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Camera feed or Simulation placeholder
            Positioned.fill(
              child: (controller != null && controller!.value.isInitialized)
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: 1 / controller!.value.aspectRatio,
                        child: CameraPreview(controller!),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.grey[900]!, Colors.black],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white24,
                          size: 64,
                        ),
                      ),
                    ),
            ),

            // Scanning UI viewfinder
            buildViewfinder(),

            // Drawn Bounding Boxes
            ...displayBoxes(),

            // Top HUD Navigation
            buildTopBar(),

            // Informational indicator for Demo/Simulation Mode
            if (isSimulationMode)
              Positioned(
                top: 110,
                left: 16,
                right: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber, width: 0.5),
                    ),
                    child: Text(
                      modelLoadError != null
                          ? "Model assets missing. Running in Simulation Mode."
                          : "Demo Mode active. Cycling mock landmarks/foods.",
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

            // Detection Result Overlay Card
            if (foodInfo != null)
              Positioned(
                bottom: 40,
                left: 16,
                right: 16,
                child: DetectionResultCard(
                  info: foodInfo,
                  confidence: confidence,
                  voiceEnabled: voiceEnabled,
                  onVoiceToggle: () {
                    setState(() {
                      voiceEnabled = !voiceEnabled;
                    });
                  },
                  sensitivity: confThreshold,
                  onSensitivityChanged: (v) {
                    setState(() {
                      confThreshold = v;
                    });
                    // If realtime is running, restart the stream to apply sensitivity threshold
                    if (isRealtime) {
                      stopRealtime().then((_) => startRealtime());
                    }
                  },
                ),
              )
            else
              Positioned(
                bottom: 60,
                left: 16,
                right: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        border: Border.all(color: Colors.white12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isSimulationMode
                            ? "Simulating scan... waiting for objects"
                            : "Point camera at landmark/food to scan",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
