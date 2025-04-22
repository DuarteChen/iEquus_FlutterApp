import os
import re
import json

# Path to the lib folder
lib_path = "/Users/duartechen/Documents/TFC - iEquus/Flutter/iEquus/lib"

# Path to the app_en.arb file
arb_file_path = os.path.join(lib_path, "l10n/app_en.arb")

# Load the app_en.arb file
with open(arb_file_path, "r") as arb_file:
    arb_data = json.load(arb_file)

# Regex to match hardcoded strings
string_regex = re.compile(r'"([^"]+)"')

# Function to replace hardcoded strings
def replace_hardcoded_strings(file_path):
    with open(file_path, "r") as file:
        content = file.read()

    matches = string_regex.findall(content)
    for match in matches:
        # Check if the string exists in the arb file
        for key, value in arb_data.items():
            if value == match:
                # Replace the hardcoded string with the localization key
                localized_string = f"AppLocalizations.of(context)!.{key}"
                content = content.replace(f'"{match}"', localized_string)
                break

    with open(file_path, "w") as file:
        file.write(content)

# Walk through the lib folder and process Dart files
for root, _, files in os.walk(lib_path):
    for file in files:
        if file.endswith(".dart"):
            file_path = os.path.join(root, file)
            replace_hardcoded_strings(file_path)

print("Hardcoded strings replaced with localization keys.")