from pynput import keyboard
import pyautogui
import time

def on_press(key):
    try:
        if key == keyboard.Key.f4:
            execute_sequence()
    except AttributeError:
        pass

def execute_sequence():
    """Perform the key sequence."""
    print("Starting sequence...")

    # Press Alt + Tab
    pyautogui.hotkey('ctrl', 'c')
    time.sleep(0.1)

    # Press Alt + Tab
    pyautogui.hotkey('alt', 'tab')
    time.sleep(0.2)
    
    # Press Down Arrow
    pyautogui.press('down')
    time.sleep(0.1)
    
    # Press F2
    pyautogui.press('f2')
    time.sleep(0.1)
    
    # Press Ctrl + V
    pyautogui.hotkey('ctrl', 'v')
    time.sleep(0.1)
    
    # Press Enter
    pyautogui.press('enter')
    time.sleep(0.1)
    
    # Press Alt + Tab
    pyautogui.hotkey('alt', 'tab')
    print("Sequence complete.")

    

# Start listening for key presses
with keyboard.Listener(on_press=on_press) as listener:
    listener.join()
