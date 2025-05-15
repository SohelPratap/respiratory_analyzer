

```markdown
# 🫁 Respiratory Analyzer

A cross-platform mobile app built using Flutter + Python Flask that detects respiratory diseases by analyzing breathing sounds using Digital Signal Processing (DSP) and Machine Learning.

## 📦 Features
- Record 10 seconds of breathing audio
- Upload existing .wav files
- Backend audio analysis using DSP (MFCC, Chroma, ZCR, etc.)
- Trained Random Forest model (.pkl) returns disease prediction
- Confidence score displayed in the app
- Real-time results

## � Tech Stack

| Component       | Technology            |
|-----------------|-----------------------|
| Frontend        | Flutter               |
| Backend         | Python Flask          |
| ML Model        | Random Forest (joblib)|
| Audio Features  | Librosa               |
| File Upload     | Flutter Sound, File Picker |

## 🗂️ Project Structure

```
respiratory_analyzer/
├── backend/                 # Flask API and ML model
│   ├── app.py               # Main Flask app
│   ├── requirements.txt     # Python dependencies
│   ├── respiratory_classifier.pkl  # Trained model
│   ├── utils.py             # Feature extraction
│   └── venv/                # Python virtual env (optional)
├── lib/                     # Flutter frontend
│   ├── main.dart
│   └── home.dart
├── android/ios/windows/...  # Platform folders
├── pubspec.yaml             # Flutter dependencies
└── README.md                # This file
```

## 🚀 Getting Started

### ✅ Prerequisites
- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Android Studio or VSCode with Flutter plugin
- Python 3.10+ with pip
- Java JDK 17
- Git

### 📥 Step-by-Step Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/yourusername/respiratory_analyzer.git
   cd respiratory_analyzer
   ```

2. **Setup the Python Backend**
   ```bash
   cd backend
   python3 -m venv venv
   source venv/bin/activate  # or venv\Scripts\activate on Windows
   pip install -r requirements.txt
   python app.py
   ```
   ✅ This starts the Flask server at: http://localhost:5000/predict

3. **Update IP in Flutter Code**  
   If running on a physical phone (not emulator), replace `localhost` with your local machine's IP in:
   ```
   📁 lib/home.dart
   final uri = Uri.parse('http://192.168.x.x:5000/predict');
   ```
   🔁 Replace `192.168.x.x` with your actual IP (find it using `ipconfig` on Windows or `ifconfig` on macOS/Linux)

4. **Run the Flutter App**
   ```bash
   flutter pub get
   flutter run
   ```

5. **Build APK (Optional)**
   ```bash
   flutter build apk --release
   ```
   APK output will be at: `build/app/outputs/flutter-apk/app-release.apk`

## 🧪 Model Details
- Dataset: ICBHI 2017 Respiratory Sound Database
- Classes: COPD, URTI, Bronchiectasis, Healthy, Pneumonia, etc.
- 30 DSP features: MFCCs, Chroma, ZCR, Spectral Centroid, etc.
- Optimized with Optuna
- Trained using Scikit-learn's Random Forest

## 📊 How Prediction Works
1. User uploads or records .wav file
2. Backend extracts features using librosa
3. Model predicts respiratory condition
4. App displays prediction with confidence

## 📱 Screenshots (optional)
[Add screenshots of the recording screen, file picker, and result display here]

## 🔮 Future Scope
- Add TensorFlow Lite support for offline prediction
- Improve classification with deep learning
- Add visual lung health graphs
- iOS support

## 🧑‍💻 Contributing
PRs are welcome! If you want to improve frontend UI or extend model support, feel free to fork and contribute.

## 📜 License
MIT License
```

To use this file:
1. Copy the entire content above
2. Create a new file named `README.md` in your project root
3. Paste the content
4. Save the file

Would you like me to:
1. Provide this as a downloadable file?
2. Add any additional sections?
3. Customize any part further for your specific project?
