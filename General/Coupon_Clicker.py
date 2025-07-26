# python3 -m venv /path/to/dir
# source /path/to/dir/bin/activate
# pip install pyautogui opencv-python mss numpy keyboard
# sudo apt-get install python3-tk python3-dev gnome-screenshot

import cv2
import numpy as np
import pyautogui
import mss
import time
import keyboard
import threading

# Load the template image
template_path = "clip.png"
template = cv2.imread(template_path, cv2.IMREAD_UNCHANGED)
template_gray = cv2.cvtColor(template, cv2.COLOR_BGR2GRAY)
w, h = template_gray.shape[::-1]
threshold = 0.7  # Match confidence threshold

stop_script = False

def monitor_shift_key():
    global stop_script
    while True:
        if keyboard.is_pressed("shift"):
            print("Shift key pressed. Stopping script...")
            stop_script = True
            break
        time.sleep(0.1)

def find_unique_matches(screenshot, monitor):
    gray_img = cv2.cvtColor(screenshot, cv2.COLOR_BGR2GRAY)
    result = cv2.matchTemplate(gray_img, template_gray, cv2.TM_CCOEFF_NORMED)
    locations = np.where(result >= threshold)
    points = list(zip(*locations[::-1]))

    # Deduplicate close matches
    unique_points = []
    for pt in points:
        if not any(np.linalg.norm(np.array(pt) - np.array(up)) < 10 for up in unique_points):
            unique_points.append(pt)

    # Sort bottom to top
    unique_points.sort(key=lambda p: p[1], reverse=True)

    # Convert to screen coordinates
    screen_points = [
        (monitor["left"] + pt[0] + w // 2, monitor["top"] + pt[1] + h // 2)
        for pt in unique_points
    ]
    return screen_points

# Start shift-key monitor thread
threading.Thread(target=monitor_shift_key, daemon=True).start()

# Setup monitor
with mss.mss() as sct:
    monitor = sct.monitors[2]  # Left monitor
    print(f"Using monitor: {monitor}")
    print("Select window...")
    time.sleep(3)

    while not stop_script:
        screenshot = np.array(sct.grab(monitor))
        matches = find_unique_matches(screenshot, monitor)

        if matches:
            print(f"Found {len(matches)} match(es)")
            for x, y in matches:
                if stop_script: break
                pyautogui.moveTo(x, y)
                pyautogui.click()
                time.sleep(0.1)

            if stop_script: break

            pyautogui.press("pagedown")
            time.sleep(1)
        else:
            print("No more matches found. Exiting.")
            break
