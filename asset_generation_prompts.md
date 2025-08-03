# PlantWise Asset Generation Prompts

Here are atomic, detailed prompts you can use with ChatGPT (DALL-E) to generate PlantWise assets one at a time, ensuring each asset is a single object designed in your app's style:

---

## 🎨 Universal Asset Specifications (Apply to all prompts)

- Style: Flat vector illustration, minimalist and clean  
- Color Palette: Primary Green (#2E7D32), Secondary Green (#8BC34A), Warm White (#F8F9FA), soft gray and earthy brown accents  
- Background: Transparent  
- Design: Rounded corners, smooth curves, no shadows or 3D effects  
- Mood: Friendly, fresh, natural, approachable  
- Format: SVG preferred, PNG acceptable  
- Size: Mentioned individually per asset  

---

## 🪴 Core Plant Assets

**1. Small succulent in round pot**  
Prompt:  
```
Create a flat vector illustration of a small succulent plant in a round ceramic pot for the PlantWise app. The image should be 120x120 pixels with a transparent background. Use the color palette Primary Green (#2E7D32) and Secondary Green (#8BC34A), with a white pot and subtle terracotta accents. Style should be minimalist, with smooth curves and clean lines, friendly and consistent with PlantWise's natural aesthetic. Please provide as an SVG file.
```

**2. Leafy houseplant in ceramic pot**  
Prompt:  
```
Design a flat vector illustration of a leafy houseplant in a modern ceramic pot for the PlantWise app. Size 120x120 pixels with a transparent background. Color palette should include vibrant greens (Primary and Secondary Green), a white pot with gray accents. Style should be clean, rounded, and minimalist with simple leaf shapes. SVG format preferred.
```

**3. Small tree in decorative pot**  
Prompt:  
```
Create a flat vector illustration of a small indoor tree in a decorative pot, sized 120x120 pixels with transparent background for the PlantWise app. Use green hues from PlantWise palette, and a terracotta colored pot with simple decorations. The style is minimalist and friendly with smooth shapes and no shadows. Provide as SVG.
```

**4. Flowering plant in pot**  
Prompt:  
```
Design a flat vector illustration of a flowering plant with visible blooms in a ceramic pot. Image size 120x120 pixels with transparent background. Use PlantWise greens and warm colors for flowers (pinks or yellows), with a light-colored pot. Style minimalist and clean with rounded features. SVG preferred.
```

**5. Herb plant in small pot**  
Prompt:  
```
Create a flat vector illustration of a small herb plant (e.g., basil or mint) in a simple pot. Size 120x120 pixels with transparent background. Use fresh green shades and a plain ceramic pot in natural hues. Keep the style flat, simple, and friendly. Provide SVG format.
```

---

## 🛠️ Gardening Tools & Care

**6. Watering can with water droplets**  
Prompt:  
```
Design a flat vector illustration of a watering can with water droplets flowing from its spout for the PlantWise app. Size 120x120 pixels with transparent background. The watering can should be primarily primary green (#2E7D32) with lighter green (#8BC34A) accents. Water droplets are light blue (#42A5F5). Style is friendly and rounded with no shadows. SVG preferred.
```

**7. Small shovel / trowel**  
Prompt:  
```
Create a flat vector illustration of a small garden shovel (trowel) with gray handle and green blade for the PlantWise app. Size 120x120 pixels, transparent background. Clean lines with rounded edges, minimalist style. SVG format.
```

**8. Pruning shears**  
Prompt:  
```
Design a flat vector illustration of pruning shears with green handles and metallic blades for the PlantWise app. Size 120x120 pixels, transparent background. Style is simple, rounded, and flat with no 3D effects. Provide as SVG.
```

---

## 📱 UI & Interface Elements

**9. Calendar icon with leaf accent**  
Prompt:  
```
Create a flat vector illustration of a simple calendar icon with a small green leaf accent on the top corner. Size 64x64 pixels, transparent background. Colors use PlantWise green palette (#2E7D32, #8BC34A) and light grays. Style is minimal and clean. SVG format preferred.
```

**10. Notification bell with leaf accent**  
Prompt:  
```
Design a flat vector notification bell icon with a small green leaf accent on the side. Size 48x48 pixels, transparent background. Use soft gray for the bell and PlantWise green for the leaf (#2E7D32). Style is UI friendly, flat, and clean. Provide SVG.
```

**11. User profile avatar placeholder with plant motif**  
Prompt:  
```
Create a flat vector user avatar placeholder with a simple human silhouette crowned with small green leaves. Size 120x120 pixels, transparent background. Use PlantWise colors (#2E7D32, #8BC34A, #F8F9FA). Style is friendly, natural, and flat. SVG preferred.
```

---

## 📊 Progress & Achievement

**12. Plant care progress bar with leaf marker**  
Prompt:  
```
Design a flat vector horizontal progress bar themed around plant growth for the PlantWise app. Size 200x40 pixels, transparent background. The bar should have a gradient from light green (#8BC34A) to dark green (#2E7D32). Include a small leaf icon at the progress tip and subtle plant growth markers along the bar. Style is clean, motivational, and flat. SVG preferred.
```

**13. Achievement badge: First Plant (Seedling)**  
Prompt:  
```
Create a flat vector achievement badge representing a "First Plant" milestone. Circular 80x80 pixels with transparent background. Show a small seedling sprout with two leaves centered. Use PlantWise greens and warm accent colors. Style is minimal and friendly. Provide SVG.
```

---

## 🌱 Additional Plant Care Icons

**14. Water drop icon**  
Prompt:  
```
Create a flat vector illustration of a single water drop icon for the PlantWise app. Size 48x48 pixels with transparent background. Use light blue (#42A5F5) with subtle highlights. Style is clean, minimal, and friendly. SVG format preferred.
```

**15. Sunlight/Light icon**  
Prompt:  
```
Design a flat vector sun icon with gentle rays for the PlantWise app. Size 48x48 pixels with transparent background. Use warm yellow (#FFD54F) with soft orange accents. Style should be friendly, rounded, and minimalist. Provide SVG.
```

**16. Temperature thermometer icon**  
Prompt:  
```
Create a flat vector thermometer icon for plant care in the PlantWise app. Size 48x48 pixels with transparent background. Use soft grays and a red/orange gradient for the mercury. Style is clean and modern. SVG preferred.
```

**17. Humidity droplet icon**  
Prompt:  
```
Design a flat vector humidity icon showing a droplet with small water vapor lines for the PlantWise app. Size 48x48 pixels with transparent background. Use light blue tones and subtle gray accents. Style is minimal and clean. Provide SVG.
```

---

These prompts are designed so each asset is a single, focused object. You can use these sequentially to build a comprehensive asset library in the same style, ensuring perfect consistency and quality.

## Usage Instructions

1. Copy the specific prompt for the asset you need
2. Paste it into ChatGPT with DALL-E access
3. Request modifications if needed while maintaining the style guide
4. Save the generated assets to your `assets/images/` directory
5. Update your Flutter app's asset references in `pubspec.yaml`

## Asset Organization

Recommended folder structure in your Flutter project:
```
assets/
  images/
    plants/
      succulent.svg
      leafy_plant.svg
      small_tree.svg
      flowering_plant.svg
      herb_plant.svg
    tools/
      watering_can.svg
      trowel.svg
      pruning_shears.svg
    ui/
      calendar_leaf.svg
      notification_bell.svg
      avatar_placeholder.svg
    progress/
      progress_bar.svg
      first_plant_badge.svg
    care_icons/
      water_drop.svg
      sunlight.svg
      thermometer.svg
      humidity.svg
```
