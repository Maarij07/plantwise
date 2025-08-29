#!/usr/bin/env python3
"""
YOLOv8 Model Conversion Script
Converts PyTorch model (.pt) to ONNX format for Flutter integration
"""

import os
import sys
import subprocess
import platform
from pathlib import Path

def install_package(package):
    """Install a package using pip"""
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
        return True
    except subprocess.CalledProcessError as e:
        print(f"Failed to install {package}: {e}")
        return False

def check_and_install_dependencies():
    """Check and install required dependencies"""
    required_packages = [
        "ultralytics",
        "torch",
        "torchvision", 
        "onnx",
        "onnxruntime"
    ]
    
    print("Checking dependencies...")
    
    for package in required_packages:
        try:
            __import__(package.replace('-', '_'))
            print(f"✓ {package} is already installed")
        except ImportError:
            print(f"✗ {package} not found, installing...")
            if not install_package(package):
                return False
    
    return True

def find_model_file():
    """Find the best.pt model file"""
    model_dir = Path("D:/temp/development/flutter/model-plantwise")
    
    # Look for best.pt in common locations
    search_paths = [
        model_dir / "best.pt",
        model_dir / "runs" / "detect" / "train" / "weights" / "best.pt",
        model_dir / "runs" / "detect" / "train2" / "weights" / "best.pt",
        model_dir / "runs" / "detect" / "train3" / "weights" / "best.pt",
    ]
    
    # Also search recursively for any best.pt file
    for pt_file in model_dir.rglob("best.pt"):
        search_paths.append(pt_file)
    
    for path in search_paths:
        if path.exists():
            print(f"Found model at: {path}")
            return str(path)
    
    print("Could not find best.pt model file")
    print("Searched in:")
    for path in search_paths[:4]:  # Show first 4 search paths
        print(f"  - {path}")
    return None

def convert_to_onnx(model_path, output_dir=None):
    """Convert YOLOv8 model to ONNX format"""
    try:
        from ultralytics import YOLO
        
        # Load the model
        print(f"Loading YOLOv8 model from: {model_path}")
        model = YOLO(model_path)
        
        # Set output directory
        if output_dir is None:
            output_dir = Path(model_path).parent
        
        output_path = Path(output_dir) / "model.onnx"
        
        print("Converting to ONNX format...")
        print("This may take a few minutes...")
        
        # Export to ONNX
        model.export(
            format='onnx',
            imgsz=640,  # Standard YOLOv8 input size
            dynamic=False,  # Static input shape for better compatibility
            simplify=True,  # Simplify the model
            opset=11,  # ONNX opset version (11 is widely supported)
        )
        
        # The exported file will be in the same directory as the source model
        source_dir = Path(model_path).parent
        onnx_file = source_dir / f"{Path(model_path).stem}.onnx"
        
        if onnx_file.exists():
            print(f"✓ Successfully converted to ONNX: {onnx_file}")
            
            # Copy to Flutter assets if requested
            flutter_assets = Path("assets/models")
            flutter_assets.mkdir(parents=True, exist_ok=True)
            
            target_path = flutter_assets / "plant_disease_model.onnx"
            
            try:
                import shutil
                shutil.copy2(str(onnx_file), str(target_path))
                print(f"✓ Copied ONNX model to Flutter assets: {target_path}")
                
                # Also show file size
                size_mb = target_path.stat().st_size / (1024 * 1024)
                print(f"Model size: {size_mb:.2f} MB")
                
            except Exception as e:
                print(f"Warning: Could not copy to Flutter assets: {e}")
                print(f"Please manually copy {onnx_file} to assets/models/plant_disease_model.onnx")
            
            return True
        else:
            print("❌ ONNX export failed - output file not found")
            return False
            
    except ImportError as e:
        print(f"❌ Missing required package: {e}")
        print("Please install ultralytics: pip install ultralytics")
        return False
    except Exception as e:
        print(f"❌ Conversion failed: {e}")
        return False

def main():
    """Main conversion function"""
    print("YOLOv8 to ONNX Conversion Script")
    print("=" * 40)
    
    # Check Python version
    python_version = platform.python_version()
    print(f"Python version: {python_version}")
    
    if sys.version_info >= (3, 13):
        print("⚠️  Warning: Python 3.13 may have compatibility issues")
        print("   Consider using Python 3.11 or 3.12 if conversion fails")
    
    # Install dependencies
    if not check_and_install_dependencies():
        print("❌ Failed to install required dependencies")
        return False
    
    # Find model file
    model_path = find_model_file()
    if not model_path:
        print("❌ Could not find YOLOv8 model file")
        return False
    
    # Convert to ONNX
    success = convert_to_onnx(model_path)
    
    if success:
        print("\n✅ Conversion completed successfully!")
        print("\nNext steps:")
        print("1. Update your Flutter app to use ONNX runtime")
        print("2. Test the model with real plant images")
        print("3. Verify disease detection accuracy")
    else:
        print("\n❌ Conversion failed")
        print("Try using a different Python version (3.11 or 3.12)")
    
    return success

if __name__ == "__main__":
    main()
