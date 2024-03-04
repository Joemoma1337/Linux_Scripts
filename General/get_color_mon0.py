import pyautogui
from screeninfo import get_monitors

def get_leftmost_monitor():
    monitors = get_monitors()
    if monitors:
        return monitors[0]
    else:
        raise Exception("No monitors found")

def get_pixel_color(x, y):
    color = pyautogui.pixel(x, y)
    return color

def watch_pixels():
    leftmost_monitor = get_leftmost_monitor()
    # Adjust the coordinates to match the leftmost monitor
    pixel_x = leftmost_monitor.x + 150
    pixel_y = leftmost_monitor.y + 150
    pixel_color = get_pixel_color(pixel_x, pixel_y)
    print(f"Pixel 1: {pixel_color}")
    pixel_x = leftmost_monitor.x + 830
    pixel_y = leftmost_monitor.y + 553
    pixel_color = get_pixel_color(pixel_x, pixel_y)
    print(f"Pixel 2: {pixel_color}")
    pixel_x = leftmost_monitor.x + 995
    pixel_y = leftmost_monitor.y + 542
    pixel_color = get_pixel_color(pixel_x, pixel_y)
    print(f"Pixel 3: {pixel_color}")

    # Get the RGB value of the pixel
    #pixel_color = get_pixel_color(pixel_x, pixel_y)
    #print(f"RGB Value: {pixel_color}")

    # Adjust the sleep time based on your needs
    #pyautogui.sleep(1)

if __name__ == "__main__":
    watch_pixels()
