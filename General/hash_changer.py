import os
import hashlib

# --- CONFIGURATION ---
#Windows:
#folder_path = r'C:\Users\YourName\Videos'
#Linux:
folder_path = '/home/user/Videos'
ENABLE_HASHING = False  # Set to True to see hashes, False to just run
# ---------------------

def get_file_hash(file_path):
    """Calculates SHA-256 hash in chunks."""
    sha256_hash = hashlib.sha256()
    try:
        with open(file_path, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return sha256_hash.hexdigest()
    except Exception as e:
        return f"Error: {e}"

def process_file(file_path):
    try:
        original_hash = None
        if ENABLE_HASHING:
            original_hash = get_file_hash(file_path)
        
        # Append the null byte to change the hash
        with open(file_path, 'ab') as f:
            f.write(b'\0') 
            
        relative_path = os.path.relpath(file_path, folder_path)
        
        if ENABLE_HASHING:
            new_hash = get_file_hash(file_path)
            print(f"Processed: {relative_path}")
            print(f"  [PRE]  {original_hash}")
            print(f"  [POST] {new_hash}")
            print("-" * 30)
        else:
            print(f"Modified: {relative_path}")
        
    except Exception as e:
        print(f"Could not process {file_path}: {e}")

if __name__ == "__main__":
    if os.path.exists(folder_path):
        mode = "WITH hash verification" if ENABLE_HASHING else "WITHOUT hashing (Fast Mode)"
        print(f"Starting scan: {folder_path}")
        print(f"Mode: {mode}\n")
        
        for root, dirs, files in os.walk(folder_path):
            for filename in files:
                full_path = os.path.join(root, filename)
                process_file(full_path)
                
        print("\nAll done!")
    else:
        print(f"Error: Path {folder_path} not found.")
