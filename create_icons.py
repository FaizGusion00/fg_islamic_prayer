from PIL import Image, ImageDraw
import os

# Define the sizes for different densities
sizes = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192
}

# Base directory for Android resources
base_dir = 'android/app/src/main/res'

def create_islamic_icon(size):
    """Create an Islamic-themed launcher icon"""
    # Create a new image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Colors
    bg_color = (46, 139, 139, 255)  # Teal
    accent_color = (255, 215, 0, 255)  # Gold
    white = (255, 255, 255, 255)
    
    # Draw circular background
    margin = size // 16
    draw.ellipse([margin, margin, size-margin, size-margin], fill=bg_color)
    
    # Draw crescent moon
    moon_size = size // 3
    moon_x = size // 2 - moon_size // 4
    moon_y = size // 2 - moon_size // 2
    
    # Outer circle for crescent
    draw.ellipse([moon_x - moon_size//4, moon_y, moon_x + moon_size//2, moon_y + moon_size], fill=accent_color)
    # Inner circle to create crescent shape
    draw.ellipse([moon_x, moon_y + moon_size//8, moon_x + moon_size//2, moon_y + moon_size - moon_size//8], fill=bg_color)
    
    # Draw star
    star_size = size // 8
    star_x = size // 2 + moon_size // 4
    star_y = size // 2 - moon_size // 3
    
    # Simple star shape (5-pointed)
    star_points = []
    import math
    for i in range(10):
        angle = i * math.pi / 5
        if i % 2 == 0:
            radius = star_size
        else:
            radius = star_size // 2
        x = star_x + radius * math.cos(angle - math.pi/2)
        y = star_y + radius * math.sin(angle - math.pi/2)
        star_points.append((x, y))
    
    draw.polygon(star_points, fill=accent_color)
    
    # Draw simple mosque silhouette at bottom
    mosque_height = size // 6
    mosque_width = size // 2
    mosque_x = size // 2 - mosque_width // 2
    mosque_y = size - margin - mosque_height
    
    # Main building
    draw.rectangle([mosque_x, mosque_y, mosque_x + mosque_width, mosque_y + mosque_height], fill=white)
    
    # Dome
    dome_size = mosque_width // 3
    dome_x = mosque_x + mosque_width // 2 - dome_size // 2
    dome_y = mosque_y - dome_size // 2
    draw.ellipse([dome_x, dome_y, dome_x + dome_size, dome_y + dome_size], fill=white)
    
    # Minaret
    minaret_width = mosque_width // 8
    minaret_height = mosque_height
    minaret_x = mosque_x + mosque_width + minaret_width
    draw.rectangle([minaret_x, mosque_y, minaret_x + minaret_width, mosque_y + minaret_height], fill=white)
    
    return img

def main():
    print("Creating launcher icons for all densities...")
    
    for density, size in sizes.items():
        # Create directory if it doesn't exist
        dir_path = os.path.join(base_dir, f'mipmap-{density}')
        os.makedirs(dir_path, exist_ok=True)
        
        # Create icon
        icon = create_islamic_icon(size)
        
        # Save icon
        icon_path = os.path.join(dir_path, 'ic_launcher.png')
        icon.save(icon_path, 'PNG')
        
        print(f"Created {density} icon: {icon_path} ({size}x{size})")
    
    print("All launcher icons created successfully!")

if __name__ == '__main__':
    main()