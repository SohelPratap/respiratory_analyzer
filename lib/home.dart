import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  bool isRecording = false;
  String? resultText;
  String? audioPath;

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  Future<void> initRecorder() async {
    await Permission.microphone.request();
    await recorder.openRecorder();
  }

  Future<void> startRecording() async {
    final dir = await getTemporaryDirectory();
    audioPath = '${dir.path}/temp_record.wav';
    await recorder.startRecorder(
      toFile: audioPath,
      codec: Codec.pcm16WAV,
    );

    setState(() => isRecording = true);

    // Stop after 10 seconds
    Future.delayed(Duration(seconds: 10), () async {
      if (isRecording) await stopRecording();
    });
  }

  Future<void> stopRecording() async {
    await recorder.stopRecorder();
    setState(() => isRecording = false);
    if (audioPath != null) {
      await uploadAudio(File(audioPath!));
      File(audioPath!).delete(); // Auto delete
    }
  }

  Future<void> pickFileAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      await uploadAudio(file);
    }
  }

  Future<void> uploadAudio(File file) async {
    final uri = Uri.parse('http://your-backend-url.com/predict');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final json = jsonDecode(respStr);
      setState(() {
        resultText = '${json['prediction']} (confidence: ${json['probability'].toStringAsFixed(2)})';
      });
    } else {
      setState(() {
        resultText = '❌ Error uploading audio';
      });
    }
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Respiratory Analyzer')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: isRecording ? null : startRecording,
              icon: Icon(Icons.mic),
              label: Text(isRecording ? 'Recording...' : 'Record 10 sec'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickFileAndUpload,
              icon: Icon(Icons.upload_file),
              label: Text('Choose audio file'),
            ),
            SizedBox(height: 40),
            if (resultText != null)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🧠 Prediction:\n$resultText',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}