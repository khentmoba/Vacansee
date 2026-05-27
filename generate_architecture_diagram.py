import os
import sys

def generate_diagram():
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        print("PIL (Pillow) is not installed. Installing it now...")
        import subprocess
        subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])
        from PIL import Image, ImageDraw, ImageFont

    # Dimensions and settings
    width, height = 800, 600
    background_color = (255, 255, 255)  # White background
    image = Image.new('RGB', (width, height), background_color)
    draw = ImageDraw.Draw(image)

    # Styling colors for black and white
    box_fill_color = (245, 245, 245)    # Very light gray for boxes
    border_color = (0, 0, 0)             # Black borders
    text_color = (0, 0, 0)               # Black text
    subtext_color = (80, 80, 80)         # Dark gray subtext
    arrow_color = (0, 0, 0)              # Black arrows

    # Box coordinates
    box_width = 600
    box_height = 110
    left_margin = (width - box_width) // 2
    
    # 3 Layers vertical positions
    y_positions = [60, 250, 440]
    
    layers_data = [
        {
            "title": "PRESENTATION LAYER",
            "subtitle": "Responsive Flutter Web Frontend (Dart)",
            "details": "Client-side Widget Trees | Compiled static assets served via Vercel CDN"
        },
        {
            "title": "APPLICATION LAYER",
            "subtitle": "Supabase Auth + Edge Functions (TypeScript / Deno)",
            "details": "User authentication flows | Serverless edge integrations with Resend API"
        },
        {
            "title": "DATA LAYER",
            "subtitle": "Supabase PostgreSQL Cloud Database",
            "details": "Row Level Security (RLS) policies | Database Triggers | pg_cron scheduler"
        }
    ]

    # Draw layers
    for i, y in enumerate(y_positions):
        # Draw light gray filled box
        draw.rectangle(
            [(left_margin, y), (left_margin + box_width, y + box_height)],
            fill=box_fill_color,
            outline=border_color,
            width=2
        )

        # Write text
        data = layers_data[i]
        
        # Draw title (bold simulation via offset if font not present, or simple text)
        draw.text(
            (left_margin + 30, y + 15),
            data["title"],
            fill=text_color,
            font=None
        )
        
        # Draw subtitle
        draw.text(
            (left_margin + 30, y + 45),
            data["subtitle"],
            fill=subtext_color,
            font=None
        )
        
        # Draw details
        draw.text(
            (left_margin + 30, y + 75),
            data["details"],
            fill=subtext_color,
            font=None
        )

    # Draw arrows connecting layers
    def draw_arrow(start_y, end_y, label):
        mid_x = width // 2
        # Vertical line
        draw.line([(mid_x, start_y), (mid_x, end_y)], fill=arrow_color, width=2)
        # Arrowhead
        draw.polygon([(mid_x - 6, end_y - 8), (mid_x + 6, end_y - 8), (mid_x, end_y)], fill=arrow_color)
        # Label backplate (white to overlay on top of vertical line)
        draw.rectangle([(mid_x - 90, start_y + 15), (mid_x + 90, start_y + 35)], fill=background_color)
        # Label text
        draw.text((mid_x - 85, start_y + 20), label, fill=text_color, font=None)

    draw_arrow(y_positions[0] + box_height, y_positions[1], "(HTTPS / WSS / REST APIs)")
    draw_arrow(y_positions[1] + box_height, y_positions[2], "(SQL Connections / Triggers)")

    # Save image
    output_path = "system_architecture.png"
    image.save(output_path)
    print(f"Success: Grayscale system architecture diagram generated successfully at '{output_path}'")

if __name__ == "__main__":
    generate_diagram()
