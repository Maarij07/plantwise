#!/usr/bin/env python3
"""
Script to copy the trained YOLOv8 model to the Flutter assets directory.

This is a workaround for the TensorFlow Lite export issues with Python 3.13.
Once you have a .tflite model file, you can use this script to copy it.
"""
import os
import shutil

def copy_model():
    # Source path (your trained model)
    model_source = r"D:\temp\development\flutter\model-plantwise\runs\detect\yolov8_custom_finetuned\weights\best.pt"
    
    # Destination directory
    assets_models_dir = r"D:\temp\development\flutter\plantwise\assets\models"
    
    # Create directory if it doesn't exist
    os.makedirs(assets_models_dir, exist_ok=True)
    
    print("🔍 Looking for model files...")
    
    # Check if we have the PyTorch model
    if os.path.exists(model_source):
        print(f"✅ Found PyTorch model: {model_source}")
        
        # For now, let's check what files we have in the model directory
        model_dir = os.path.dirname(model_source)
        print(f"📁 Model directory contents:")
        
        for file in os.listdir(model_dir):
            file_path = os.path.join(model_dir, file)
            if os.path.isfile(file_path):
                size = os.path.getsize(file_path) / (1024 * 1024)  # Size in MB
                print(f"   📄 {file} ({size:.2f} MB)")
                
                # If it's already a .tflite file, copy it!
                if file.endswith('.tflite'):
                    dest_path = os.path.join(assets_models_dir, 'plant_disease_model.tflite')
                    shutil.copy2(file_path, dest_path)
                    print(f"✅ Copied TensorFlow Lite model to: {dest_path}")
                    return True
    
    # Check if there's already a TensorFlow Lite model in the expected location
    tflite_dest = os.path.join(assets_models_dir, 'plant_disease_model.tflite')
    if os.path.exists(tflite_dest):
        print(f"✅ TensorFlow Lite model already exists: {tflite_dest}")
        return True
    
    print("❌ No TensorFlow Lite model found.")
    print("📝 Next steps:")
    print("   1. Convert your PyTorch model (.pt) to TensorFlow Lite (.tflite)")
    print("   2. Place the .tflite file at: assets/models/plant_disease_model.tflite")
    print("   3. Your Flutter app will automatically use the real model!")
    
    return False

if __name__ == "__main__":
    copy_model()
