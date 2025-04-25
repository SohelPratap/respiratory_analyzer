import numpy as np
import librosa

def extract_features(y, sr):
    desired_length = sr * 10
    if len(y) < desired_length:
        y = np.pad(y, (0, desired_length - len(y)))
    else:
        y = y[:desired_length]

    features = []

    chroma = librosa.feature.chroma_stft(y=y, sr=sr)
    features.append(np.mean(chroma))
    features.append(np.std(chroma))
    features.append(np.min(chroma))

    mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=13)
    features.append(np.mean(mfcc))
    features.append(np.std(mfcc))
    features.append(np.max(mfcc))
    features.append(np.min(mfcc))

    mel = librosa.feature.melspectrogram(y=y, sr=sr)
    features.append(np.mean(mel))
    features.append(np.std(mel))
    features.append(np.max(mel))

    contrast = librosa.feature.spectral_contrast(y=y, sr=sr, n_bands=4, fmin=100.0)
    features.append(np.mean(contrast))
    features.append(np.std(contrast))
    features.append(np.max(contrast))
    features.append(np.min(contrast))

    centroid = librosa.feature.spectral_centroid(y=y, sr=sr)
    features.append(np.mean(centroid))
    features.append(np.std(centroid))
    features.append(np.max(centroid))
    features.append(np.min(centroid))

    bandwidth = librosa.feature.spectral_bandwidth(y=y, sr=sr)
    features.append(np.mean(bandwidth))
    features.append(np.std(bandwidth))
    features.append(np.max(bandwidth))
    features.append(np.min(bandwidth))

    rolloff = librosa.feature.spectral_rolloff(y=y, sr=sr)
    features.append(np.mean(rolloff))
    features.append(np.std(rolloff))
    features.append(np.max(rolloff))
    features.append(np.min(rolloff))

    zcr = librosa.feature.zero_crossing_rate(y)
    features.append(np.mean(zcr))
    features.append(np.std(zcr))
    features.append(np.max(zcr))
    features.append(np.min(zcr))

    return features