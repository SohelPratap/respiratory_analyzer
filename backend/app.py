from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np
import librosa
import os

app = Flask(__name__)
CORS(app)

# Load model (expects 30 features)
model = joblib.load('respiratory_classifier.pkl')

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'No file uploaded'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    try:
        temp_path = 'temp.wav'
        file.save(temp_path)

        y, sr = librosa.load(temp_path, sr=None)

        # Extract features
        chroma_stft = librosa.feature.chroma_stft(y=y, sr=sr)
        mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=13)
        mel = librosa.feature.melspectrogram(y=y, sr=sr)
        spectral_contrast = librosa.feature.spectral_contrast(y=y, sr=sr)
        spectral_centroid = librosa.feature.spectral_centroid(y=y, sr=sr)
        spectral_bandwidth = librosa.feature.spectral_bandwidth(y=y, sr=sr)
        spectral_rolloff = librosa.feature.spectral_rolloff(y=y, sr=sr)
        zcr = librosa.feature.zero_crossing_rate(y)

        # Only the required 30 features
        features = np.array([
            np.mean(chroma_stft),
            np.std(chroma_stft),
            np.min(chroma_stft),
            np.mean(mfcc),
            np.std(mfcc),
            np.max(mfcc),
            np.min(mfcc),
            np.mean(mel),
            np.std(mel),
            np.max(mel),
            np.mean(spectral_contrast),
            np.std(spectral_contrast),
            np.max(spectral_contrast),
            np.min(spectral_contrast),
            np.mean(spectral_centroid),
            np.std(spectral_centroid),
            np.max(spectral_centroid),
            np.min(spectral_centroid),
            np.mean(spectral_bandwidth),
            np.std(spectral_bandwidth),
            np.max(spectral_bandwidth),
            np.min(spectral_bandwidth),
            np.mean(spectral_rolloff),
            np.std(spectral_rolloff),
            np.max(spectral_rolloff),
            np.min(spectral_rolloff),
            np.mean(zcr),
            np.std(zcr),
            np.max(zcr),
            np.min(zcr)
        ]).reshape(1, -1)

        # Prediction
        prediction = model.predict(features)[0]
        probability = model.predict_proba(features).max()

        os.remove(temp_path)

        return jsonify({'prediction': prediction, 'probability': float(probability)})

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)