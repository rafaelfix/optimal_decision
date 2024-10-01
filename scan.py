import os

def read_folder_structure(root_dir, output_file):
    with open(output_file, 'w') as f:
        for dirpath, dirnames, filenames in os.walk(root_dir):
            f.write(f"Directory: {dirpath}\n")
            if dirnames:
                f.write(f" Subdirectories: {dirnames}\n")
            if filenames:
                f.write(f" Files: {filenames}\n")
            f.write("-" * 40 + "\n")

if __name__ == "__main__":
    # Set the directory you want to start from
    root_directory = input("Enter the root directory to scan (leave blank to scan the current directory): ")
    
    if not root_directory:
        root_directory = os.getcwd()  # Use the current working directory if none is provided

    # Define the output text file
    output_file = "folder_structure.txt"

    # Read folder structure and write to text file
    read_folder_structure(root_directory, output_file)
    
    print(f"Folder structure has been written to {output_file}")
