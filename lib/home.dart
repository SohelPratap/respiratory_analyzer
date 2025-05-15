  import 'dart:io';
  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:flutter_sound/flutter_sound.dart';
  import 'package:permission_handler/permission_handler.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:path_provider/path_provider.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';
  import 'package:device_info_plus/device_info_plus.dart';

  class HomePage extends StatefulWidget {
    const HomePage({super.key});
    @override
    State<HomePage> createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {
    final FlutterSoundRecorder recorder = FlutterSoundRecorder();
    final FlutterSoundPlayer player = FlutterSoundPlayer();
    bool isRecording = false;
    bool isPlaying = false;
    String? resultText;
    String? audioPath;
    bool isFileReady = false;
    double recordingProgress = 0.0;
    Timer? recordingTimer;
    bool isLoading = false;

    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initApp();
      });
    }

    Future<void> _initApp() async {
      await _requestPermissions();
      await initRecorder();
      await player.openPlayer();
    }

    Future<void> _requestPermissions() async {
      await Permission.microphone.request();

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        if (androidInfo.version.sdkInt >= 33) {
          // Android 13+ and 14
          await Permission.audio.request();
        } else {
          await Permission.storage.request();
        }
      } else if (Platform.isIOS) {
        await Permission.photos.request();
      }
    }

    void showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Future<void> initRecorder() async {
      try {
        await recorder.openRecorder();
      } catch (e) {
        showSnackBar('Failed to initialize recorder: ${e.toString()}');
        rethrow;
      }
    }

    Future<void> startRecording() async {
      if (!(await Permission.microphone.isGranted)) {
        showSnackBar('Microphone permission not granted');
        return;
      }

      try {
        final dir = await getTemporaryDirectory();
        audioPath = '${dir.path}/temp_record_${DateTime.now().millisecondsSinceEpoch}.wav';

        await recorder.startRecorder(
          toFile: audioPath,
          codec: Codec.pcm16WAV,
        );

        setState(() {
          isRecording = true;
          recordingProgress = 0.0;
          resultText = null;
        });

        recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          setState(() {
            recordingProgress += 0.01;
            if (recordingProgress >= 1.0) {
              timer.cancel();
              stopRecording();
            }
          });
        });
      } catch (e) {
        showSnackBar('Recording failed: ${e.toString()}');
        setState(() => isRecording = false);
      }
    }

    Future<void> stopRecording() async {
      try {
        recordingTimer?.cancel();
        await recorder.stopRecorder();
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          isRecording = false;
          isFileReady = true;
        });
      } catch (e) {
        showSnackBar('Failed to stop recording: ${e.toString()}');
        setState(() => isRecording = false);
      }
    }

    Future<void> pickFileAndUpload() async {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          if (!(await Permission.audio.isGranted)) {
            showSnackBar('Audio permission required');
            return;
          }
        } else {
          if (!(await Permission.storage.isGranted)) {
            showSnackBar('Storage permission required');
            return;
          }
        }
      } else if (Platform.isIOS && !(await Permission.photos.isGranted)) {
        showSnackBar('Photos permission required');
        return;
      }

      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['wav'],
          withData: true,
        );

        if (result != null && result.files.single.path != null) {
          setState(() {
            audioPath = result.files.single.path!;
            isFileReady = true;
            resultText = null;
          });
        }
      } catch (e) {
        showSnackBar('File selection failed: ${e.toString()}');
      }
    }

    Future<void> uploadAudio() async {
      if (audioPath == null || !isFileReady) return;

      setState(() {
        isLoading = true;
        resultText = null;
      });

      try {
        final file = File(audioPath!);
        if (!await file.exists()) {
          showSnackBar('Audio file not found');
          return;
        }

        final uri = Uri.parse('http://192.168.0.106:5001/predict');
        final request = http.MultipartRequest('POST', uri)
          ..files.add(await http.MultipartFile.fromPath('file', file.path));

        final response = await request.send();
        final respStr = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final json = jsonDecode(respStr) as Map<String, dynamic>;
          setState(() {
            resultText = '${json['prediction']} (confidence: ${json['probability'].toStringAsFixed(2)})';
          });
        } else {
          throw Exception('Server error: ${response.statusCode}');
        }
      } catch (e) {
        showSnackBar('Analysis failed: ${e.toString()}');
      } finally {
        setState(() {
          isLoading = false;
          isFileReady = false;
        });
      }
    }

    @override
    void dispose() {
      recordingTimer?.cancel();
      recorder.closeRecorder();
      player.closePlayer();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Respiratory Analyzer'),
          centerTitle: true,
          elevation: 4,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Recording Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        IconButton(
                          iconSize: 64,
                          icon: Icon(
                            isRecording ? Icons.stop : Icons.mic,
                            color: isRecording ? Colors.red : Colors.blue,
                          ),
                          onPressed: isRecording ? stopRecording : startRecording,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isRecording ? 'Recording...' : 'Record Audio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isRecording ? Colors.red : Colors.blue,
                          ),
                        ),
                        if (isRecording) ...[
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: recordingProgress,
                            backgroundColor: Colors.grey[200],
                            color: Colors.redAccent,
                            minHeight: 8,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(recordingProgress * 10).toStringAsFixed(1)}s / 10s',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),

                const SizedBox(height: 24),

                // File Picker Button
                OutlinedButton.icon(
                  icon: const Icon(Icons.upload_rounded),
                  label: const Text('Upload WAV File'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    side: BorderSide(color: Colors.blue.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: pickFileAndUpload,
                ),

                const SizedBox(height: 24),

                // Play Audio Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(isPlaying ? 'STOP AUDIO' : 'PLAY AUDIO'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    onPressed: (audioPath != null && isFileReady && !isLoading)
                        ? () async {
                            final file = File(audioPath!);
                            if (!await file.exists() || await file.length() == 0) {
                              showSnackBar('Audio file not ready yet, try again.');
                              return;
                            }

                            if (isPlaying) {
                              await player.stopPlayer();
                            } else {
                              await player.startPlayer(
                                fromURI: audioPath!,
                                codec: Codec.pcm16WAV,
                                whenFinished: () {
                                  setState(() {
                                    isPlaying = false;
                                  });
                                },
                              );
                            }
                            setState(() {
                              isPlaying = !isPlaying;
                            });
                          }
                        : null,
                  ),
                ),

                const SizedBox(height: 16),

                // Analyze Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFileReady ? Colors.green.shade600 : Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    onPressed: isFileReady && !isLoading ? uploadAudio : null,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'ANALYZE AUDIO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Results Section
                if (resultText != null)
                  AnimatedOpacity(
                    opacity: resultText != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.analytics,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ANALYSIS RESULT',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            resultText!,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }