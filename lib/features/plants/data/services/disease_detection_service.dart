import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';
import '../../domain/models/disease_detection.dart';

class DiseaseDetectionService {
  static DiseaseDetectionService? _instance;
  static DiseaseDetectionService get instance => _instance ??= DiseaseDetectionService._();
  
  DiseaseDetectionService._();

  OrtSession? _session;
  List<String>? _labels;
  bool _isInitialized = false;

  // Model configuration
  static const String modelPath = 'assets/models/plant_disease_model.onnx';
  static const String labelsPath = 'assets/models/labels.txt';
  static const int inputSize = 640; // YOLOv8 default input size
  static const int numClasses = 29; // Number of plant disease classes
  static const double confidenceThreshold = 0.25;
  static const double nmsThreshold = 0.45;

  /// Initialize the ONNX model
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Load the model
      await _loadModel();
      
      // Load the labels
      await _loadLabels();
      
      _isInitialized = true;
      print('✅ Disease Detection Service initialized successfully');
      return true;
    } catch (e) {
      print('❌ Error initializing Disease Detection Service: $e');
      return false;
    }
  }

  /// Load the ONNX model
  Future<void> _loadModel() async {
    try {
      // Initialize ONNX Runtime
      OrtEnv.instance.init();
      
      // Load model from assets
      final modelBytes = await rootBundle.load(modelPath);
      final sessionOptions = OrtSessionOptions();
      
      // Create ONNX Runtime session
      _session = OrtSession.fromBuffer(modelBytes.buffer.asUint8List(), sessionOptions);
      print('📱 Real ONNX model loaded successfully!');
      print('🔧 Model inputs: ${_session!.inputNames}');
      print('🔧 Model outputs: ${_session!.outputNames}');
    } catch (e) {
      // Throw error instead of falling back to simulation since user has the model
      print('❌ Failed to load ONNX model: $e');
      print('🔍 Model path: $modelPath');
      throw Exception('Could not load ONNX model from assets: $e. Make sure the model file exists at $modelPath');
    }
  }

  /// Load the class labels
  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString(labelsPath);
      _labels = labelsData.split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && !line.startsWith('#'))
          .toList();
      
      print('🏷️ Loaded ${_labels!.length} disease classes');
      
      // Print first few labels for debugging
      if (_labels!.isNotEmpty) {
        print('📝 Sample labels: ${_labels!.take(3).join(', ')}...');
      }
    } catch (e) {
      print('❌ Error loading labels: $e');
      // Provide fallback labels for demo purposes
      _labels = [
        'Apple Scab Leaf',
        'Tomato Early blight leaf', 
        'Potato leaf early blight',
        'Corn leaf blight',
        'grape leaf black rot'
      ];
      print('🔄 Using fallback labels (${_labels!.length} classes)');
    }
  }

  /// Detect diseases in an image
  Future<DiseaseDetectionResult> detectDiseases(File imageFile) async {
    if (!_isInitialized) {
      throw Exception('Service not initialized. Call initialize() first.');
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Load and preprocess the image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image to model input size
      final resizedImage = img.copyResize(
        image,
        width: inputSize,
        height: inputSize,
        interpolation: img.Interpolation.linear,
      );

      // Prepare input tensor
      final input = _imageToInputTensor(resizedImage);

      // Use real inference if model is loaded, otherwise simulate
      final detections = _session != null 
          ? await _runInference(input, image.width, image.height)
          : await _simulateInference(image.width, image.height);

      stopwatch.stop();

      final modelVersion = _session != null ? '1.0.0-yolov8-onnx' : '1.0.0-simulated';
      
      return DiseaseDetectionResult(
        detections: detections,
        processingTimeMs: stopwatch.elapsedMilliseconds.toDouble(),
        imageWidth: image.width,
        imageHeight: image.height,
        modelVersion: modelVersion,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      stopwatch.stop();
      throw Exception('Disease detection failed: $e');
    }
  }

  /// Convert image to input tensor format
  Float32List _imageToInputTensor(img.Image image) {
    final inputTensor = Float32List(1 * inputSize * inputSize * 3);
    int index = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        
        // Normalize pixel values to [0, 1] and arrange in RGB order
        inputTensor[index++] = pixel.r / 255.0;
        inputTensor[index++] = pixel.g / 255.0;
        inputTensor[index++] = pixel.b / 255.0;
      }
    }

    return inputTensor;
  }

  /// Simulate model inference (replace with actual inference in production)
  Future<List<DetectedDisease>> _simulateInference(int imageWidth, int imageHeight) async {
    // Simulate processing time
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate detecting 1-3 diseases with random confidence scores
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    final numDetections = (random % 3) + 1;
    final detections = <DetectedDisease>[];

    for (int i = 0; i < numDetections; i++) {
      final labelIndex = (random + i * 7) % _labels!.length;
      final confidence = 0.3 + (random % 600) / 1000.0; // Random confidence between 0.3-0.9
      
      final diseaseClass = _labels![labelIndex];
      final detectedDisease = DetectedDisease(
        diseaseClass: diseaseClass,
        diseaseName: _formatDiseaseName(diseaseClass),
        confidence: confidence,
        boundingBox: BoundingBox(
          x: (random % 200).toDouble(),
          y: (random % 200).toDouble(),
          width: (200 + random % 200).toDouble(),
          height: (200 + random % 200).toDouble(),
        ),
        description: DiseaseInfo.getDescription(diseaseClass),
        severity: DiseaseInfo.getSeverity(diseaseClass),
        treatmentSuggestions: DiseaseInfo.getTreatmentSuggestions(diseaseClass),
        preventionTips: DiseaseInfo.getPreventionTips(diseaseClass),
      );

      detections.add(detectedDisease);
    }

    // Sort by confidence (highest first)
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    return detections;
  }

  /// Format disease class name for display
  String _formatDiseaseName(String diseaseClass) {
    return diseaseClass
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word)
        .join(' ');
  }

  /// Run actual inference (for when you have the real model)
  Future<List<DetectedDisease>> _runInference(Float32List input, int imageWidth, int imageHeight) async {
    if (_session == null) {
      throw Exception('Model not loaded');
    }

    try {
      print('🔄 Starting ONNX inference...');
      
      // Convert input for ONNX - YOLOv8 expects [batch, channels, height, width] format
      final inputData = Float32List(1 * 3 * inputSize * inputSize);
      int outputIndex = 0;
      
      // Rearrange from HWC to CHW format
      for (int c = 0; c < 3; c++) {
        for (int y = 0; y < inputSize; y++) {
          for (int x = 0; x < inputSize; x++) {
            final pixelIndex = (y * inputSize + x) * 3 + c;
            inputData[outputIndex++] = input[pixelIndex];
          }
        }
      }
      
      // Create ONNX input tensor with proper data type conversion
      final inputTensor = OrtValueTensor.createTensorWithDataList(
        inputData,  // Keep as Float32List, don't convert to double
        [1, 3, inputSize, inputSize],
      );
      
      print('📊 Input tensor created with shape: [1, 3, $inputSize, $inputSize]');
      print('🔗 Running inference on input: ${_session!.inputNames.first}');
      
      // Run inference
      final runOptions = OrtRunOptions();
      final outputs = _session!.run(
        runOptions,
        {_session!.inputNames.first: inputTensor},
      );
      
      // Get output tensor - handle the List<OrtValue?> return type
      if (outputs == null || outputs.isEmpty) {
        throw Exception('No output from model');
      }
      
      final outputTensor = outputs.first as OrtValueTensor?;
      if (outputTensor == null) {
        throw Exception('Invalid output tensor');
      }
      
      // Get tensor data and handle proper type conversion
      final outputData = outputTensor.value;
      print('🔍 ONNX output data type: ${outputData.runtimeType}');
      print('🔍 ONNX output data length: ${outputData is List ? outputData.length : 'N/A'}');
      
      // For ONNX runtime, we need to infer shape from model or use known shape
      // YOLOv8 typically outputs shape [1, 33, 8400]
      final outputShape = [1, 33, 8400];
      
      // Convert output data to List<double> with comprehensive type handling
      final outputList = <double>[];
      
      try {
        if (outputData is List<double>) {
          print('✅ Output is List<double>');
          outputList.addAll(outputData);
        } else if (outputData is Float32List) {
          print('✅ Output is Float32List');
          outputList.addAll(outputData.toList());
        } else if (outputData is List<List<double>>) {
          print('✅ Output is List<List<double>> - flattening...');
          // Handle nested list structure - flatten it
          for (final sublist in outputData) {
            outputList.addAll(sublist);
          }
        } else if (outputData is List<List<num>>) {
          print('✅ Output is List<List<num>> - converting and flattening...');
          // Handle nested list structure with num types
          for (final sublist in outputData) {
            for (final item in sublist) {
              outputList.add(item.toDouble());
            }
          }
        } else if (outputData is List) {
          print('✅ Output is generic List - processing items...');
          // Convert other numeric types with safer casting
          for (int i = 0; i < outputData.length; i++) {
            final item = outputData[i];
            print('🔍 Item $i type: ${item.runtimeType}');
            
            if (item is double) {
              outputList.add(item);
            } else if (item is int) {
              outputList.add(item.toDouble());
            } else if (item is num) {
              outputList.add(item.toDouble());
            } else if (item is List) {
              print('🔍 Processing nested list of length: ${item.length}');
              // Handle nested structure
              for (int j = 0; j < item.length; j++) {
                final subItem = item[j];
                if (subItem is double) {
                  outputList.add(subItem);
                } else if (subItem is int) {
                  outputList.add(subItem.toDouble());
                } else if (subItem is num) {
                  outputList.add(subItem.toDouble());
                } else {
                  print('⚠️ Unknown subitem type: ${subItem.runtimeType}');
                  // Try dynamic conversion as last resort
                  try {
                    final doubleVal = double.parse(subItem.toString());
                    outputList.add(doubleVal);
                  } catch (e) {
                    print('❌ Failed to convert subitem to double: $e');
                  }
                }
              }
            } else {
              print('⚠️ Unknown item type: ${item.runtimeType}');
              // Try dynamic conversion as last resort
              try {
                final doubleVal = double.parse(item.toString());
                outputList.add(doubleVal);
              } catch (e) {
                print('❌ Failed to convert item to double: $e');
              }
            }
          }
        } else {
          throw Exception('Unsupported output data type: ${outputData.runtimeType}');
        }
        
        print('✅ Successfully converted ${outputList.length} values to List<double>');
        
      } catch (e) {
        throw Exception('Error converting ONNX output data: $e');
      }
      
      // Reshape output to [anchors, classes + 4]
      // YOLOv8 output shape: [1, 33, 8400] -> [8400, 33]
      final numAnchors = outputShape.length > 2 ? outputShape[2] : 8400;
      final numFeatures = outputShape.length > 1 ? outputShape[1] : 33;
      final output = <List<double>>[];
      
      for (int i = 0; i < numAnchors; i++) {
        final detection = <double>[];
        for (int j = 0; j < numFeatures; j++) {
          final index = j * numAnchors + i;
          if (index < outputList.length) {
            detection.add(outputList[index]);
          }
        }
        if (detection.length == numFeatures) {
          output.add(detection);
        }
      }

      // Post-process results
      return _postProcessResults(output, imageWidth, imageHeight);
    } catch (e) {
      throw Exception('Inference failed: $e');
    }
  }

  /// Post-process YOLOv8 results
  List<DetectedDisease> _postProcessResults(List<List<double>> output, int imageWidth, int imageHeight) {
    final detections = <DetectedDisease>[];
    
    for (int i = 0; i < output.length; i++) {
      final detection = output[i];
      
      // Extract bbox coordinates and confidence
      final centerX = detection[0];
      final centerY = detection[1];
      final width = detection[2];
      final height = detection[3];
      
      // Get class scores (starting from index 4)
      final scores = detection.sublist(4);
      final maxScoreIndex = scores.indexOf(scores.reduce((a, b) => a > b ? a : b));
      final confidence = scores[maxScoreIndex];
      
      // Filter by confidence threshold
      if (confidence < confidenceThreshold) continue;
      
      // Convert normalized coordinates to image coordinates
      final x = (centerX - width / 2) * imageWidth;
      final y = (centerY - height / 2) * imageHeight;
      final w = width * imageWidth;
      final h = height * imageHeight;
      
      final diseaseClass = _labels![maxScoreIndex];
      final detectedDisease = DetectedDisease(
        diseaseClass: diseaseClass,
        diseaseName: _formatDiseaseName(diseaseClass),
        confidence: confidence,
        boundingBox: BoundingBox(x: x, y: y, width: w, height: h),
        description: DiseaseInfo.getDescription(diseaseClass),
        severity: DiseaseInfo.getSeverity(diseaseClass),
        treatmentSuggestions: DiseaseInfo.getTreatmentSuggestions(diseaseClass),
        preventionTips: DiseaseInfo.getPreventionTips(diseaseClass),
      );
      
      detections.add(detectedDisease);
    }
    
    // Apply Non-Maximum Suppression
    return _applyNMS(detections);
  }

  /// Apply Non-Maximum Suppression to remove overlapping detections
  List<DetectedDisease> _applyNMS(List<DetectedDisease> detections) {
    if (detections.isEmpty) return detections;
    
    // Sort by confidence (highest first)
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    final selected = <DetectedDisease>[];
    final suppressed = <bool>[for (int i = 0; i < detections.length; i++) false];
    
    for (int i = 0; i < detections.length; i++) {
      if (suppressed[i]) continue;
      
      selected.add(detections[i]);
      
      for (int j = i + 1; j < detections.length; j++) {
        if (suppressed[j]) continue;
        
        final iou = _calculateIoU(detections[i].boundingBox, detections[j].boundingBox);
        if (iou > nmsThreshold) {
          suppressed[j] = true;
        }
      }
    }
    
    return selected;
  }

  /// Calculate Intersection over Union (IoU) for two bounding boxes
  double _calculateIoU(BoundingBox box1, BoundingBox box2) {
    final x1 = box1.x.clamp(0, double.infinity);
    final y1 = box1.y.clamp(0, double.infinity);
    final x2 = (box1.x + box1.width).clamp(0, double.infinity);
    final y2 = (box1.y + box1.height).clamp(0, double.infinity);
    
    final x3 = box2.x.clamp(0, double.infinity);
    final y3 = box2.y.clamp(0, double.infinity);
    final x4 = (box2.x + box2.width).clamp(0, double.infinity);
    final y4 = (box2.y + box2.height).clamp(0, double.infinity);
    
    final intersectionX1 = x1 > x3 ? x1 : x3;
    final intersectionY1 = y1 > y3 ? y1 : y3;
    final intersectionX2 = x2 < x4 ? x2 : x4;
    final intersectionY2 = y2 < y4 ? y2 : y4;
    
    if (intersectionX1 >= intersectionX2 || intersectionY1 >= intersectionY2) {
      return 0.0;
    }
    
    final intersectionArea = (intersectionX2 - intersectionX1) * (intersectionY2 - intersectionY1);
    final box1Area = box1.width * box1.height;
    final box2Area = box2.width * box2.height;
    final unionArea = box1Area + box2Area - intersectionArea;
    
    return intersectionArea / unionArea;
  }

  /// Dispose of resources
  void dispose() {
    _session?.release();
    _session = null;
    _labels = null;
    _isInitialized = false;
    _instance = null;
  }
}

// Extension to add reshape functionality to List
extension ListReshape<T> on List<T> {
  List<List<T>> reshape(List<int> shape) {
    if (shape.length != 2) {
      throw ArgumentError('Only 2D reshape is supported');
    }
    
    final rows = shape[0];
    final cols = shape[1];
    
    if (length != rows * cols) {
      throw ArgumentError('Cannot reshape list of length $length to shape $shape');
    }
    
    final result = <List<T>>[];
    for (int i = 0; i < rows; i++) {
      final row = sublist(i * cols, (i + 1) * cols);
      result.add(row);
    }
    
    return result;
  }
}
