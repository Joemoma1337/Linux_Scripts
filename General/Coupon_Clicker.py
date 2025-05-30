#python3 -m venv /path/to/dir
#source /path/to/dir/bin/activate
#pip install pyautogui opencv-python
#sudo apt-get install python3-tk python3-dev gnome-screenshot

import pyautogui
import time
import math

image_path = "clip2.png" # update this for your screenshot matching
region = (0, 0, 1920, 1080)  # Adjust for your left monitor
max_empty_cycles = 2
empty_cycle_count = 0

def is_close(p1, p2, threshold=10):
    return math.hypot(p1[0] - p2[0], p1[1] - p2[1]) < threshold

def deduplicate_centers(centers, threshold=10):
    deduped = []
    for c in centers:
        if not any(is_close(c, d, threshold) for d in deduped):
            deduped.append(c)
    return deduped

print("You have 3 seconds to switch to the target window...")
time.sleep(3)

while empty_cycle_count < max_empty_cycles:
    matches = list(pyautogui.locateAllOnScreen(image_path, confidence=0.80, region=region))
    centers = [pyautogui.center(match) for match in matches]
    unique_centers = deduplicate_centers(centers)

    if unique_centers:
        empty_cycle_count = 0
        unique_centers.sort(key=lambda c: c[1], reverse=True)  # Bottom to top
        for center in unique_centers:
            pyautogui.moveTo(center)
            pyautogui.click()
            time.sleep(0.1)
    else:
        empty_cycle_count += 1
        print(f"No matches found (empty cycle {empty_cycle_count}/{max_empty_cycles})")

    pyautogui.press("pagedown")
    time.sleep(1)  # Optional: wait a bit for new content to load

print("No matches after 2 cycles. Exiting.")
