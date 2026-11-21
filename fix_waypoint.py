import re

with open("Meshtastic/Views/Nodes/Helpers/Map/WaypointForm.swift", "r", encoding="utf-8", errors="replace") as f:
    content = f.read()

# Fix first TextField (Name) - replace the multiline version with simple version
content = re.sub(
    r'TextField\(\s*"Name",\s*text: \$name,\s*axis: \.vertical\s*\)',
    r'TextField("Name", text: $name)',
    content
)

# Fix second TextField (Description) - replace the multiline version with simple version
content = re.sub(
    r'TextField\(\s*"Description",\s*text: \$description,\s*axis: \.vertical\s*\)',
    r'TextField("Description", text: $description)',
    content
)

with open("Meshtastic/Views/Nodes/Helpers/Map/WaypointForm.swift", "w", encoding="utf-8") as f:
    f.write(content)

print("Done")