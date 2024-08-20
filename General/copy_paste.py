from pynput import keyboard
import pyautogui
import subprocess
import time

def bring_window_to_foreground(window_title):
    """Bring a window to the foreground based on its title using wmctrl."""
    try:
        result = subprocess.run(["wmctrl", "-a", window_title], capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error bringing window '{window_title}' to foreground: {result.stderr.strip()}")
        else:
            print(f"Successfully brought '{window_title}' to the foreground.")
    except Exception as e:
        print(f"Error bringing window '{window_title}' to foreground: {type(e).__name__} - {e}")

def execute_sequence():
    """Perform the sequence of bringing windows to foreground."""
    try:
        pyautogui.hotkey('ctrl', 'c')
        time.sleep(0.1)
        # Bring "Files" (Nautilus) window to the foreground
        bring_window_to_foreground("folder")
        time.sleep(0.2)  # Wait for 1 second

        pyautogui.press('down')
        time.sleep(0.05)
        pyautogui.press('f2')
        time.sleep(0.05)
        pyautogui.hotkey('ctrl', 'v')
        time.sleep(0.05)
        pyautogui.press('enter')
        time.sleep(0.05)

        # Bring "sublime" window to the foreground
        #bring_window_to_foreground("sublime")
        print("Sequence complete.")

    except Exception as e:
        print(f"Error executing sequence: {type(e).__name__} - {e}")

def on_press(key):
    try:
        if key == keyboard.Key.f4:
            execute_sequence()
    except AttributeError:
        pass

# Start listening for key presses
with keyboard.Listener(on_press=on_press) as listener:
    listener.join()
