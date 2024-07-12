#sudo apt-get update
#sudo apt-get install python3-tk python3-dev wmctrl gnome-screenshot
#pip3 install pyautogui
#pip3 install screeninfo
#pip3 install opencv-python-headless
import pyautogui
import subprocess
from screeninfo import get_monitors
import threading

# Constants
CHECK_INTERVAL = 0.1

# Helper Functions
def bring_window_to_foreground(window_title):
    """Bring a window to the foreground based on its title using wmctrl."""
    try:
        subprocess.run(["wmctrl", "-a", window_title])
    except Exception as e:
        print(f"Error bringing window to foreground: {type(e).__name__} - {e}")

def check_image_match(image_path, region, confidence=0.75):
    """Check if the image is on the screen within the specified region."""
    try:
        return pyautogui.locateOnScreen(image_path, region=region, confidence=confidence)
    except pyautogui.ImageNotFoundException:
        return None

def check_for_image(image_path, region):
    """Check for the presence of the specified image in the region."""
    while True:
        image_location = check_image_match(image_path, region)
        if image_location:
            print(f"Image '{image_path}' found at {image_location}")
            return True, image_location
        pyautogui.sleep(CHECK_INTERVAL)

def main():
    """Main function to run the automation script."""
    l_mon = get_monitors()[0]
    region = (l_mon.x + 640, l_mon.y + 480, 640, 140)  # Region within the specified box
    print(f"Region for searching 'CBT_start.png' and 'Next_Video.png': {region}")

    try:
        while True:
            # Search for CBT_start.png
            found1, loc1 = check_for_image('CBT_start.png', region)
            
            if found1:
                # At beginning of video: Start recording
                bring_window_to_foreground("obs")
                pyautogui.sleep(0.1)
                pyautogui.hotkey('F8')
                print("Started recording.")
                pyautogui.sleep(5)

                # Search for Next_Video.png after CBT_start.png is found
                while True:
                    found2, loc2 = check_for_image('CBT_start.png', region)
                    if found2:
                        #print(f"Next_Video.png found at {loc2}")
                        print(f"CBT_start.png found at {loc2}")
                        # At end of video: Stop recording
                        print("Stopped recording.")
                        bring_window_to_foreground("obs")
                        pyautogui.sleep(0.1)
                        pyautogui.hotkey('F9')
                        pyautogui.sleep(7)
                        pyautogui.click(l_mon.x + 960, l_mon.y + 540)
                        pyautogui.sleep(0.1)
                        pyautogui.moveTo(2800, 720)
                        pyautogui.sleep(3)
                        break  # Exit the inner loop to restart

    except KeyboardInterrupt:
        print("Script terminated by user.")
    except Exception as e:
        print(f"Unexpected error: {type(e).__name__} - {e}")

if __name__ == "__main__":
    thread = threading.Thread(target=main)
    thread.start()
