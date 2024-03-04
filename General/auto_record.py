import pyautogui
import subprocess
from screeninfo import get_monitors

#Requirements:
#sudo apt -y install python3-pip gnome-screenshot wmctrl
#pip3 install pyautogui
#pip3 install screeninfo

def get_leftmost_monitor():
    monitors = get_monitors()
    if monitors:
        return monitors[0]
    else:
        raise Exception("No monitors found")

def get_pixel_color(x, y):
    color = pyautogui.pixel(x, y)
    return color

def check_color_match(color, expected_color, tolerance=10):
    # Check if each channel value is within the acceptable range (±tolerance)
    return all(abs(c - ec) <= tolerance for c, ec in zip(color, expected_color))

def bring_window_to_foreground(window_title):
    try:
        # Use wmctrl to bring the window to the foreground
        subprocess.run(["wmctrl", "-a", window_title])
    except Exception as e:
        print(f"Error bringing window to foreground: {e}")

def check_pixel_colors():
    leftmost_monitor = get_leftmost_monitor()

    # Define the pixel coordinates for each pixel
    pixel1 = (leftmost_monitor.x + 150, leftmost_monitor.y + 150)
    pixel2 = (leftmost_monitor.x + 830, leftmost_monitor.y + 553)
    pixel3 = (leftmost_monitor.x + 995, leftmost_monitor.y + 542)

    # Define the expected RGB values with a tolerance of ±5 for each channel
    expected_color1 = (235, 236, 239)
    expected_color2 = (27, 39, 49)
    expected_color3 = (255, 188, 2)

    # Get the RGB values of the pixels
    color1 = get_pixel_color(*pixel1)
    color2 = get_pixel_color(*pixel2)
    color3 = get_pixel_color(*pixel3)


    # Debugging output
    #print(f"Color 1: {color1}")
    #print(f"Color 2: {color2}")
    #print(f"Color 3: {color3}")

    # Bring OBS Studio to the foreground
    bring_window_to_foreground("obs")

    # Check if the conditions are met with a tolerance of ±10 for each channel
    if (check_color_match(color1, expected_color1, tolerance=10) and
        check_color_match(color2, expected_color2, tolerance=10) and
        check_color_match(color3, expected_color3, tolerance=10)):
        # Introduce a delay before the hotkey press
        #pyautogui.sleep(.1)
        
        # If conditions are met, perform the desired action (e.g., press CTRL + ALT)
        pyautogui.hotkey('F8')
        print("Key combination triggered")

        # Introduce a delay after the hotkey press
        pyautogui.sleep(5)

    # Adjust the sleep time based on your needs
    pyautogui.sleep(0.5)

if __name__ == "__main__":
    while True:
        check_pixel_colors()
        # Adjust the sleep time based on your needs
        pyautogui.sleep(0.5)
