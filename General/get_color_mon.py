import pyautogui
import subprocess
from screeninfo import get_monitors

def get_pixel_color(x, y):
    color = pyautogui.pixel(x, y)
    return color

def check_pixel_colors():
    l_mon = get_monitors()[0]

    #Cybrary Logo
    pixel1_f8 = (l_mon.x + 445, l_mon.y + 290)
    pixel2_f8 = (l_mon.x + 660, l_mon.y + 830)
    pixel3_f8 = (l_mon.x + 1560, l_mon.y + 375)
    pixel4_f8 = (l_mon.x + 1510, l_mon.y + 830)
    color1_f8 = pyautogui.pixel(*pixel1_f8)
    color2_f8 = pyautogui.pixel(*pixel2_f8)
    color3_f8 = pyautogui.pixel(*pixel3_f8)
    color4_f8 = pyautogui.pixel(*pixel4_f8)

    #Load Bar
    pixel1_f7 = (l_mon.x + 45, l_mon.y + 1044)
    pixel2_f7 = (l_mon.x + 237, l_mon.y + 1044)
    pixel3_f7 = (l_mon.x + 1714, l_mon.y + 1044)
    pixel4_f7 = (l_mon.x + 1842, l_mon.y + 1044)
    color1_f7 = pyautogui.pixel(*pixel1_f7)
    color2_f7 = pyautogui.pixel(*pixel2_f7)
    color3_f7 = pyautogui.pixel(*pixel3_f7)
    color4_f7 = pyautogui.pixel(*pixel4_f7)

    # Print RGB values
    print(f"config2 (Cybrary Logo)")
    print(f"{color1_f8}")
    print(f"{color2_f8}")
    print(f"{color3_f8}")
    print(f"{color4_f8}")
    print(f"")
    print(f"config1 (load bar)")
    print(f"{color1_f7}")
    print(f"{color2_f7}")
    print(f"{color3_f7}")
    print(f"{color4_f7}")
    
    # Get the RGB value of the pixel
    #pixel_color = get_pixel_color(pixel_x, pixel_y)
    #print(f"RGB Value: {pixel_color}")

    # Adjust the sleep time based on your needs
    #pyautogui.sleep(1)

if __name__ == "__main__":
    check_pixel_colors()
