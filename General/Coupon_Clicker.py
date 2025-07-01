#python3 -m venv /path/to/dir
#source /path/to/dir/bin/activate
#pip install pyautogui opencv-python mss numpy
#sudo apt-get install python3-tk python3-dev gnome-screenshot

import cv2
import numpy as np
import pyautogui
import mss
import time

# Load the template image
template_path = "clip.png"
template = cv2.imread(template_path, cv2.IMREAD_UNCHANGED)
template_gray = cv2.cvtColor(template, cv2.COLOR_BGR2GRAY)
w, h = template_gray.shape[::-1]
threshold = 0.7  # Match confidence threshold

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

# Setup monitor
with mss.mss() as sct:
    monitor = sct.monitors[2]  # Left monitor
    print(f"Using monitor: {monitor}")

    while True:
        found_any = False

        # First pass
        screenshot = np.array(sct.grab(monitor))
        matches = find_unique_matches(screenshot, monitor)
        if matches:
            found_any = True
            for x, y in matches:
                pyautogui.moveTo(x, y)
                pyautogui.click()
                time.sleep(0.1)
        else:
            print("No matches on first scan.")

        # Page down
        pyautogui.press("pagedown")
        time.sleep(1)

        # Second pass
        screenshot = np.array(sct.grab(monitor))
        matches = find_unique_matches(screenshot, monitor)
        if matches:
            found_any = True
            for x, y in matches:
                pyautogui.moveTo(x, y)
                pyautogui.click()
                time.sleep(0.1)
        else:
            print("No matches after page down.")

        if not found_any:
            print("No matches in both scans. Exiting.")
            break

        time.sleep(1)
