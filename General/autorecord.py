import pyautogui
import subprocess
from screeninfo import get_monitors
import threading

TOLERANCE = 40
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
    #config1 (load bar (stop))
    pixel1_f9 = (l_mon.x + 45, l_mon.y + 1044)
    pixel2_f9 = (l_mon.x + 237, l_mon.y + 1044)
    pixel3_f9 = (l_mon.x + 1714, l_mon.y + 1044)
    pixel4_f9 = (l_mon.x + 1842, l_mon.y + 1044)
    expected_color1_f9 = (255, 255, 255)
    expected_color2_f9 = (13, 179, 80)
    expected_color3_f9 = (13, 179, 80)
    expected_color4_f9 = (255, 255, 255)

    color1_f9 = pyautogui.pixel(*pixel1_f9)
    color2_f9 = pyautogui.pixel(*pixel2_f9)
    color3_f9 = pyautogui.pixel(*pixel3_f9)
    color4_f9 = pyautogui.pixel(*pixel4_f9)

    bring_window_to_foreground("obs")
    pyautogui.sleep(0.1)

    if (check_color_match(color1_f9, expected_color1_f9) and
        check_color_match(color2_f9, expected_color2_f9) and
        check_color_match(color3_f9, expected_color3_f9) and
        check_color_match(color4_f9, expected_color4_f9)):
        pyautogui.hotkey('F9')
        print("Stop Recording")
        pyautogui.sleep(1)
        #exit fullscreen
        print("Exit Fullscreen")
        pyautogui.moveTo(l_mon.x + 1884, l_mon.y + 1050)
        pyautogui.sleep(.1)
        pyautogui.click()
        pyautogui.sleep(1)
        #click 'continue'
        print("Click 'Continue'")
        #pyautogui.moveTo(l_mon.x + 250, l_mon.y + 355)
        #pyautogui.sleep(.1)
        #pyautogui.click()
        print("Searching for Continue image...")
        image_location = pyautogui.locateCenterOnScreen('next.png', confidence=0.8)

        if image_location:
            print("Continue image found at:", image_location)
            pyautogui.click(image_location)
        else:
            print("Continue image not found")
        pyautogui.sleep(8)
        #pyautogui.moveTo(l_mon.x + 1000, l_mon.y + 600)
        #pyautogui.click()
        #pyautogui.sleep(.1)
        # Replace "Enter Fullscreen" with image search
        print("Searching for Fullscreen image...")
        image_location = pyautogui.locateCenterOnScreen('image_to_detect.png', confidence=0.8)

        if image_location:
            print("Fullscreen image found at:", image_location)
            pyautogui.click(image_location)
        else:
            print("Fullscreen image not found")
        
        pyautogui.sleep(1)
        print("Adjust speed")
        pyautogui.moveTo(l_mon.x + 1850, l_mon.y + 1050)
        pyautogui.click()
        pyautogui.sleep(.5)
        pyautogui.moveTo(l_mon.x + 1850, l_mon.y + 990)
        pyautogui.click()
        pyautogui.sleep(.5)
        pyautogui.moveTo(l_mon.x + 1850, l_mon.y + 910)
        pyautogui.click()
        pyautogui.sleep(.5)
        pyautogui.moveTo(l_mon.x + 1000, l_mon.y + 600)
        pyautogui.click()
        pyautogui.sleep(.5)
        print("Play")
        pyautogui.moveTo(l_mon.x + 1000, l_mon.y + 600)
        pyautogui.sleep(.1)
        pyautogui.click()
        pyautogui.sleep(1)
        print("Pause")
        pyautogui.click()
        pyautogui.sleep(1)
        print("Play")
        pyautogui.click()
        pyautogui.sleep(1)
        print("Pause")
        pyautogui.click()
        pyautogui.sleep(1)
        print("Restart")
        pyautogui.press('left')
        pyautogui.sleep(.25)
        pyautogui.press('left')
        pyautogui.sleep(.25)
        pyautogui.press('left')
        pyautogui.sleep(.25)
        pyautogui.press('left')
        pyautogui.sleep(.25)
        pyautogui.press('left')
        pyautogui.sleep(.25)
        pyautogui.press('left')
        pyautogui.sleep(.25)
        print("Play")
        pyautogui.moveTo(l_mon.x + 1000, l_mon.y + 600)
        pyautogui.sleep(.1)
        pyautogui.click()
        pyautogui.sleep(.1)
        print("Bring to foreground")
        bring_window_to_foreground("obs")
        pyautogui.sleep(.1)
        print("Start recording")
        pyautogui.hotkey('F8')
        pyautogui.sleep(.1)
        pyautogui.moveTo(2550, 400)
        pyautogui.click()

    pyautogui.sleep(CHECK_INTERVAL)

def main():
    try:
        while True:
            check_pixel_colors()
    except KeyboardInterrupt:
        print("Script terminated by user.")

if __name__ == "__main__":
    thread = threading.Thread(target=main)
    thread.start()
