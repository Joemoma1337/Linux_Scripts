#sudo apt install gnome-screenshot
import pyautogui
#sudo apt-get update
#sudo apt-get install python3-tk python3-dev
#pip3 install pyautogui
import subprocess
#pip3 install screeninfo
from screeninfo import get_monitors
import threading

TOLERANCE = 5
CHECK_INTERVAL = 0.1

def bring_window_to_foreground(window_title):
    try:
        subprocess.run(["wmctrl", "-a", window_title])
    except Exception as e:
        print(f"Error bringing window to foreground: {type(e).__name__} - {e}")

def check_color_match(color, expected_color):
    return all(abs(c - ec) <= TOLERANCE for c, ec in zip(color, expected_color))

def check_pixel_colors():
    l_mon = get_monitors()[0]
    
    # Second set of pixels and updated expected colors for f9 (Stop Recording)
    # config1 (load bar (stop))
    pixel1_f9 = (l_mon.x + 10, l_mon.y + 10)
    pixel2_f9 = (l_mon.x + 1910, l_mon.y + 10)
    pixel3_f9 = (l_mon.x + 10, l_mon.y + 1070)
    pixel4_f9 = (l_mon.x + 1910, l_mon.y + 1070)
    pixel5_f9 = (l_mon.x + 810, l_mon.y + 510)
    expected_color1_f9 = (5, 5, 5)
    expected_color2_f9 = (5, 5, 5)
    expected_color3_f9 = (5, 5, 5)
    expected_color4_f9 = (5, 5, 5)
    expected_color5_f9 = (5, 5, 5)

    while True:
        color1_f9 = pyautogui.pixel(*pixel1_f9)
        color2_f9 = pyautogui.pixel(*pixel2_f9)
        color3_f9 = pyautogui.pixel(*pixel3_f9)
        color4_f9 = pyautogui.pixel(*pixel4_f9)
        color5_f9 = pyautogui.pixel(*pixel5_f9)

        if (check_color_match(color1_f9, expected_color1_f9) and
            check_color_match(color2_f9, expected_color2_f9) and
            check_color_match(color3_f9, expected_color3_f9) and
            check_color_match(color4_f9, expected_color4_f9) and
            check_color_match(color5_f9, expected_color5_f9)):
            bring_window_to_foreground("obs")
            pyautogui.sleep(.1)
            pyautogui.hotkey('F9')
            print("Stop Recording")
            pyautogui.sleep( 1)
            return  # Exit the function to restart the whole process

        pyautogui.sleep(CHECK_INTERVAL)

def check_for_video_icon():
    l_mon = get_monitors()[0]

    print("Searching for video_icon image...")
    while True:
        try:
            pyautogui.sleep(0.1)
            image_location1 = pyautogui.locateOnScreen('video_icon.png', confidence=0.9)
            if image_location1:
                print(image_location1)
                print("video_icon found")
                pyautogui.sleep(0.1)
                print("double click for Fullscreen")
                pyautogui.click(l_mon.x + 1125, l_mon.y + 660)
                pyautogui.sleep(.25)
                pyautogui.click(l_mon.x + 1125, l_mon.y + 660)
                print("rewind")
                pyautogui.sleep(.75)
                pyautogui.press('left')
                pyautogui.sleep(.75)
                pyautogui.press('left')
                pyautogui.sleep(3.25)
                print("play")
                pyautogui.click(l_mon.x + 1125, l_mon.y + 660)
                pyautogui.sleep(0.1)
                print("Start Recording")
                bring_window_to_foreground("obs")
                pyautogui.sleep(0.1)
                pyautogui.hotkey('F8')
                pyautogui.moveTo(2550, 400)
                pyautogui.sleep(0.1)
                return  # Exit the loop and start checking pixel colors
            else:
                raise Exception("video_icon not found")
        except Exception as e:
            try:
                pyautogui.sleep(0.1)
                print(e)
                image_location2 = pyautogui.locateOnScreen('section_quiz.png', confidence=0.9)
                if image_location2:
                    print("section_quiz found")
                    pyautogui.click(l_mon.x + 1600, l_mon.y + 120)
                    pyautogui.sleep(0.1)
                    pyautogui.moveTo(2550, 400)
                    return  # Exit the loop and start checking pixel colors
            except Exception as e:
                print(e)
                pyautogui.sleep(0.1)

def main():
    try:
        while True:
            check_for_video_icon()
            check_pixel_colors()
    except KeyboardInterrupt:
        print("Script terminated by user.")

if __name__ == "__main__":
    thread = threading.Thread(target=main)
    thread.start()
