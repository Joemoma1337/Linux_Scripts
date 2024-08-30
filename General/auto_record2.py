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
    region = (l_mon.x + 640, l_mon.y + 485, 655, 135)  # Region within the specified box
    print(f"Region for searching 'CBT_start.png': {region}")

    try:
        while True:
            # Search for CBT_start.png
            found1 = check_for_image('CBT_start2.png', region)
            
            if found1:
                print("CBT_start.png found.")
                # At beginning of video: Start recording
                bring_window_to_foreground("obs")
                pyautogui.sleep(0.1)
                pyautogui.moveTo(2800, 720)
                pyautogui.sleep(0.1)
                pyautogui.hotkey('F8')
                print("Started recording.")
                pyautogui.sleep(15)

                # Loop until one of the target images is found
                while True:
                    # Search for all target images
                    found2 = check_for_image('CBT_stop.png', region)
                    #found3 = check_for_image('CBT_challenge.png', region)
                    #found4 = check_for_image('CBT_quiz.png', region)

                    if found2:
                        print("CBT_stop.png found. Stopped recording")
                        bring_window_to_foreground("obs")
                        pyautogui.sleep(0.1)
                        pyautogui.hotkey('F9')
                        pyautogui.sleep(5)
                        # Actions for CBT_stop.png
                        break  # Exit the loop after handling the found image
                        
                    #if found3:
                        #print("CBT_challenge.png found. Stopped recording")
                        #bring_window_to_foreground("obs")
                        #pyautogui.sleep(0.1)
                        #pyautogui.hotkey('F9')
                        #pyautogui.sleep(2)
                        #pyautogui.click(l_mon.x + 1650, l_mon.y + 155)
                        #pyautogui.sleep(2)
                        ## Actions for CBT_challenge.png
                        #break
#
                    #if found4:
                        #print("CBT_quiz.png found. Stopped recording")
                        #bring_window_to_foreground("obs")
                        #pyautogui.sleep(0.1)
                        #pyautogui.hotkey('F9')
                        #pyautogui.sleep(2)
                        #pyautogui.click(l_mon.x + 1650, l_mon.y + 155)
                        #pyautogui.sleep(2)
                        ## Actions for CBT_quiz.png
                        #break

    except KeyboardInterrupt:
        print("Script terminated by user.")
    except Exception as e:
        print(f"Unexpected error: {type(e).__name__} - {e}")

if __name__ == "__main__":
    thread = threading.Thread(target=main)
    thread.start()
