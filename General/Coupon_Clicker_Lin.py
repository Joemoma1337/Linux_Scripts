"""
Coupon Clipper - Linux Version
-----------------------------------
SYSTEM DEPENDENCIES (Run these first):
sudo apt-get update
sudo apt-get install python3-tk python3-dev libx11-dev

PYTHON DEPENDENCIES:
pip install -r requirements.txt
OR
pip install opencv-python numpy pyautogui mss pynput ewmh
"""
import cv2
import numpy as np
import pyautogui
import mss
import time
from pynput import keyboard
from ewmh import EWMH

# --- Config ---
MATCH_THRESHOLD = 0.8
SCROLL_DELAY = 1.0 
REFRESH_DELAY = 6.0 
MAX_EMPTY_PASSES = 1 

# --- Setup ---
ewmh = EWMH()
template = cv2.imread("clip.png", cv2.IMREAD_GRAYSCALE)
if template is None:
    print("Error: clip.png not found!")
    exit()
tw, th = template.shape[::-1]

stop_script = False

# --- Shift Key Listener ---
def on_press(key):
    global stop_script
    if key == keyboard.Key.shift or key == keyboard.Key.shift_r:
        print("\n[STOP] Shift key detected. Terminating...")
        stop_script = True
        return False 

listener = keyboard.Listener(on_press=on_press)
listener.start()

def get_monitor_agnostic_win_data():
    windows = ewmh.getClientList()
    for win in windows:
        name = ewmh.getWmName(win)
        if name and "coupons" in name.decode('utf-8').lower():
            geom = win.get_geometry()
            trans = win.translate_coords(ewmh.root, 0, 0)
            return {
                "top": trans.y,
                "left": trans.x,
                "width": geom.width,
                "height": geom.height
            }, win
    return None, None

# --- Main Logic ---
monitor, win_obj = get_monitor_agnostic_win_data()
if not monitor:
    print("Window not found. Please ensure the BJ's Coupon page is open.")
    exit()

ewmh.setActiveWindow(win_obj)
ewmh.display.flush()
time.sleep(1)

empty_passes = 0
total_clicked = 0

with mss.mss() as sct:
    while not stop_script and empty_passes < MAX_EMPTY_PASSES:
        print(f"\n--- SCANNING PASS (Clipped Total: {total_clicked}) ---")
        clicked_this_pass = 0
        
        while not stop_script:
            try:
                sct_img = sct.grab(monitor)
            except Exception as e:
                print(f"Capture Error: {e}")
                break

            frame = cv2.cvtColor(np.array(sct_img), cv2.COLOR_BGRA2GRAY)
            res = cv2.matchTemplate(frame, template, cv2.TM_CCOEFF_NORMED)
            loc = np.where(res >= MATCH_THRESHOLD)
            
            points = []
            for pt in zip(*loc[::-1]):
                if not any(abs(pt[0] - p[0]) < 15 and abs(pt[1] - p[1]) < 15 for p in points):
                    points.append(pt)
            
            if points:
                # --- REVERSED SORTING LOGIC ---
                # Sort by Y descending (bottom first), then X descending (right first)
                points.sort(key=lambda p: (p[1], p[0]), reverse=True)
                
                print(f"Found {len(points)} coupons. Clicking bottom-to-top, right-to-left...")
                
                for pt in points:
                    if stop_script: break
                    click_x = monitor["left"] + pt[0] + tw // 2
                    click_y = monitor["top"] + pt[1] + th // 2
                    pyautogui.click(click_x, click_y)
                    clicked_this_pass += 1
                    total_clicked += 1
                    time.sleep(0.15) # Slightly longer delay to allow for UI shift
                
                # Scroll down to reveal more
                pyautogui.press("pagedown")
                time.sleep(SCROLL_DELAY)
            else:
                break

        if stop_script: break

        if clicked_this_pass > 0:
            print(f"Completed pass. Refreshing page...")
            empty_passes = 0 
            pyautogui.press("f5")
            time.sleep(REFRESH_DELAY)
        else:
            empty_passes += 1
            if empty_passes < MAX_EMPTY_PASSES:
                print("Checking for hidden updates via refresh...")
                pyautogui.press("f5")
                time.sleep(REFRESH_DELAY)

print(f"\n--- SCRIPT FINISHED ---")
print(f"Total coupons clipped: {total_clicked}")
