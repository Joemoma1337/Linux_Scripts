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

def check_image_match(image_path, region, confidence=0.9):
    """Check if the image is on the screen within the specified region."""
    try:
        return pyautogui.locateOnScreen(image_path, region=region, confidence=confidence)
    except pyautogui.ImageNotFoundException:
        return None

def check_for_image(image_path, region):
    """Check for the presence of the specified image in the region."""
    return check_image_match(image_path, region) is not None

def main():
    """Main function to run the automation script."""
    l_mon = get_monitors()[0]
    region = (l_mon.x + 375, l_mon.y + 210, 50, 50)  # Region within the specified box
    print(f"Region for searching 'TCM_start.png': {region}")

    try:
        while True:
            # Search for TCM_start.png
            found1 = check_for_image('TCM_start.png', region)
            
            if found1:
                print("TCM_start.png found.")
                pyautogui.click(l_mon.x + 1125, l_mon.y + 540)
                pyautogui.sleep(0.2)
                pyautogui.click(l_mon.x + 1125, l_mon.y + 540)
                pyautogui.sleep(2.5)
                pyautogui.press('left')
                pyautogui.sleep(0.2)
                pyautogui.press('left')
                pyautogui.sleep(0.75)
                pyautogui.click(l_mon.x + 1125, l_mon.y + 540)
                pyautogui.sleep(0.1)
                # At beginning of video: Start recording
                bring_window_to_foreground("obs")
                pyautogui.sleep(0.1)
                pyautogui.moveTo(2800, 720)
                pyautogui.sleep(0.1)
                pyautogui.hotkey('F8')
                print("Started recording.")
                pyautogui.sleep(5)

                # Loop until one of the target images is found
                while True:
                    # Search for all target images
                    found2 = check_for_image('TCM_stop.png', region)
                    found3 = check_for_image('TCM_challenge.png', region)
                    found4 = check_for_image('TCM_quiz.png', region)

                    if found2:
                        print("TCM_stop.png found. Stopped recording")
                        bring_window_to_foreground("obs")
                        pyautogui.sleep(0.1)
                        pyautogui.hotkey('F9')
                        pyautogui.sleep(2)
                        # Actions for TCM_stop.png
                        break  # Exit the loop after handling the found image
                        
                    if found3:
                        print("TCM_challenge.png found. Stopped recording")
                        bring_window_to_foreground("obs")
                        pyautogui.sleep(0.1)
                        pyautogui.hotkey('F9')
                        pyautogui.sleep(2)
                        pyautogui.click(l_mon.x + 1650, l_mon.y + 155)
                        pyautogui.sleep(2)
                        # Actions for TCM_challenge.png
                        break

                    if found4:
                        print("TCM_quiz.png found. Stopped recording")
                        bring_window_to_foreground("obs")
                        pyautogui.sleep(0.1)
                        pyautogui.hotkey('F9')
                        pyautogui.sleep(2)
                        pyautogui.click(l_mon.x + 1650, l_mon.y + 155)
                        pyautogui.sleep(2)
                        # Actions for TCM_quiz.png
                        break

    except KeyboardInterrupt:
        print("Script terminated by user.")
    except Exception as e:
        print(f"Unexpected error: {type(e).__name__} - {e}")

if __name__ == "__main__":
    thread = threading.Thread(target=main)
    thread.start()
