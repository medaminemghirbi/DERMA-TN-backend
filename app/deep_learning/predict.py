import os
import sys
import tensorflow as tf
import numpy as np

# Load the model
model_path = 'app/deep_learning/mobile_net.h5'
model = tf.keras.models.load_model(model_path)

# Define the image size (ensure this matches the size used during training)
img_size = (240, 240)

# Define class names
class_names = [
    'Actinic keratosis', 'Basal Cell Carcinoma', 'Benign keratosis',
    'Dermatofibroma', 'Melanocytic nevus', 'Melanoma',
    'Squamous cell carcinoma', 'Vascular lesion'
]

def predict_disease(model, img_path):
    # Load and preprocess the image
    img = tf.keras.utils.load_img(img_path, target_size=img_size, color_mode='rgb')
    img_array = tf.keras.utils.img_to_array(img) / 255.0
    img_array = np.expand_dims(img_array, axis=0)

    # Make the prediction with verbose=0 to suppress the progress bar
    preds = model.predict(img_array, verbose=0)
    
    # Get the top prediction
    top_pred_index = np.argmax(preds[0])
    top_probability = round(preds[0][top_pred_index] * 100, 2)

    # Return the class name and probability
    return class_names[top_pred_index], top_probability

if __name__ == '__main__':
    # Ensure the image path is provided as a command-line argument
    if len(sys.argv) < 2:
        print("Error: Please provide the image path as an argument.")
        sys.exit(1)

    # Get the image path from command-line arguments
    img_path = sys.argv[1]

    if not os.path.exists(img_path):
        print(f"Error: Image file '{img_path}' not found.")
        sys.exit(1)

    # Predict the disease
    class_name, probability = predict_disease(model, img_path)

    # Output the prediction results
    print(f"Predicted class: {class_name}")
    print(f"Probability: {probability}")
