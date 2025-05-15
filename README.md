
---

# 🫁 Respiratory Analyzer

A cross-platform mobile app built with Flutter and Python Flask to detect respiratory diseases by analyzing breathing sounds using Digital Signal Processing (DSP) and Machine Learning.

---

## 📦 Features

- Record 10-second breathing audio
- Upload existing `.wav` files
- Backend audio analysis using DSP (MFCC, Chroma, ZCR, etc.)
- Trained Random Forest model (`.pkl`) for disease prediction
- Confidence score displayed in the app
- Real-time results

---

## 🧰 Tech Stack

| Component       | Technology            |
|-----------------|-----------------------|
| Frontend        | Flutter               |
| Backend         | Python Flask          |
| ML Model        | Random Forest (joblib)|
| Audio Features  | Librosa               |
| File Upload     | Flutter Sound, File Picker |

---

## 🗂️ Project Structure

```
respiratory_analyzer/
├── backend/                 # Flask API and ML model
│   ├── app.py               # Main Flask app
│   ├── requirements.txt     # Python dependencies
│   ├── respiratory_classifier.pkl  # Trained model
│   ├── utils.py             # Feature extraction
│   ├── scratch.ipynb        # Experimental/Prototyping notebook
│   └── venv/                # Python virtual env (optional)
├── lib/                     # Flutter frontend
│   ├── main.dart
│   └── home.dart
├── android/ios/windows/…    # Platform folders
├── pubspec.yaml             # Flutter dependencies
└── README.md                # This file
```

---

## 🚀 Getting Started

### ✅ Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio or VSCode with Flutter plugin
- Python 3.10+ with pip
- Java JDK 17
- Git

---

### 📥 Step-by-Step Setup

#### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/respiratory_analyzer.git
cd respiratory_analyzer
```

#### 2. Set Up the Python Backend

```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

✅ Flask server starts at: `http://localhost:5000/predict`

#### 3. Update IP in Flutter Code

If using a physical device (not an emulator), replace `localhost` with your machine’s IP in:

```dart
// lib/home.dart
final uri = Uri.parse('http://192.168.x.x:5000/predict');
```

🔁 Replace `192.168.x.x` with your local IP (check with `ipconfig` on Windows or `ifconfig` on macOS/Linux).

#### 4. Run the Flutter App

```bash
flutter pub get
flutter run
```

#### 5. Build APK (Optional)

```bash
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧠 Machine Learning Implementation

### 📊 Dataset
- **Source**: ICBHI 2017 Respiratory Sound Database
- **Size**: 920 audio samples (WAV format)
- **Classes**: COPD (793), Pneumonia (37), Healthy (35), URTI (23), Bronchiectasis (16), Bronchiolitis (13), LRTI (2), Asthma (1)

### 🔍 Feature Engineering Pipeline

**Core DSP Features Extracted**:

```python
fn_list = [
    feature.chroma_stft,       # Chromagram
    feature.mfcc,              # MFCCs
    feature.melspectrogram,    # Mel-spectrogram
    feature.spectral_contrast, # Spectral contrast
    feature.spectral_centroid, # Spectral centroid
    feature.zero_crossing_rate # ZCR
]
```

**Statistical Features**:
`['_mean', '_std', '_max', '_min']`

### ⚙️ Preprocessing Steps
1. **Audio Standardization**:
   - Trimmed to 7.86s
   - Sample rate: 44.1kHz
2. **Feature Selection**:
   - Removed low-importance features (e.g., `mel_spectrogram_min`, `chroma_stft_max`)
   - Final features: 30 statistical values

### 🤖 Model Development

**Optimized Random Forest Classifier**:

```python
best_params = {
    'n_estimators': 205,
    'max_depth': 29,
    'min_samples_split': 8,
    'min_samples_leaf': 3,
    'max_features': 'sqrt',
    'class_weight': 'balanced'
}
```

**Evaluation Metrics (5-fold CV)**:
- Accuracy: 91.3%
- Weighted F1 Score: 91.5%

### 🚀 Production Pipeline

**Prediction Flow**:
1. AudioLoader
2. AudioTrimmer
3. FeatureExtractor
4. FeatureStatistics
5. RandomForest Prediction

**Saved Artifacts**:
- `respiratory_classifier.pkl`
- `utils.py`

### 🧪 Sample Prediction

```python
result = predict_respiratory_condition('sample.wav')
# Output: {'prediction': 'COPD', 'probability': 0.92}
```

### 🔮 Future ML Improvements
- Address data imbalance with SMOTE
- Explore deep learning (CNN/RNN models)
- Integrate patient metadata

---

## 🧪 Model Details
- **Dataset**: ICBHI 2017 Respiratory Sound Database
- **Classes**: COPD, URTI, Bronchiectasis, Healthy, Pneumonia, etc.
- **Features**: 30 DSP features (MFCCs, Chroma, ZCR, Spectral Centroid, etc.)
- **Optimization**: Optuna
- **Framework**: Scikit-learn Random Forest

---

## 📊 How Prediction Works
1. User uploads or records `.wav` file
2. Backend extracts features using Librosa
3. Model predicts condition
4. App displays prediction with confidence score

---

## 📱 Screenshots

<div align="center">
  <img src="https://github.com/user-attachments/assets/c9391010-c360-4692-a1e6-4e8eab70dfd0" width="30%" alt="Recording Screen"/>
  <img src="https://github.com/user-attachments/assets/e5ce8199-83e8-45b1-ba52-e2bb425abf2e" width="30%" alt="Results Screen"/>
</div>

---

## 🔮 Future Scope
- Add TensorFlow Lite for offline prediction
- Enhance classification with deep learning
- Include lung health progress graphs
- Expand iOS support

---

## 🧑‍💻 Contributing

Pull requests are welcome! Fork the repo and submit improvements for the frontend, model, or performance.

---
## 👨‍💻 Team Members

Meet the developers behind this project:

| Member            | GitHub Profile |
|-------------------|----------------|
| Parv Patidar      | [@Parv03-glitch](https://github.com/Parv03-glitch) |
| Sohel Pratap Singh| [@SohelPratap](https://github.com/SohelPratap) |
| Shrawan Kumar Bhagat | [@ShrawanBhagat04](https://github.com/ShrawanBhagat04) |
---

## 📜 License

MIT License

---
