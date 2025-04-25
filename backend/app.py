from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import librosa
import numpy as np
import os
from utils import extract_features

app = Flask(__name__)
CORS(app)

# Load trained model
model = joblib.load("respiratory_classifier.pkl")

@app.route("/predict", methods=["POST"])
def predict():
    if 'file' not in request.files:
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No file selected"}), 400

    try:
        temp_path = "temp.wav"
        file.save(temp_path)

        # Load and extract features
        y, sr = librosa.load(temp_path, sr=None)
        features = extract_features(y, sr)
        features = np.array(features).reshape(1, -1)

        # Predict
        prediction = model.predict(features)[0]
        probability = model.predict_proba(features).max()

        os.remove(temp_path)

        return jsonify({
            "prediction": prediction,
            "probability": float(probability)
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True)