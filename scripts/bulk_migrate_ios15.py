#!/usr/bin/env python3
"""
Bulk migration script for iOS 15 backport.
Run this on macOS AFTER xcodegen generates the project.

Changes:
1. NavigationStack -> CompatNavigationStack (with imports)
2. NavigationLink(value:) -> CompatNavigationLink
3. .navigationDestination -> .compatNavigationDestination
4. @Observable -> ObservableObject + @Published
5. SwiftData imports -> CoreDataStack + CoreDataEntity
"""

import os
import re
from pathlib import Path

# Directories to process (Widgets & MeshtasticMessages are disabled targets)
SOURCE_DIRS = [
    "Meshtastic/Views",
    "Meshtastic/Services",
    "Meshtastic/Helpers",
    "Meshtastic/Model",
    "Meshtastic/Persistence",
    "Meshtastic/Router",
    "Meshtastic/Extensions",
    "Meshtastic/AppIntents",
    "Meshtastic/CarPlay",
    "Shared",
]

# File extensions
EXTENSIONS = [".swift"]

# Track changes
changes = []

def process_file(filepath):
    """Process a single Swift file."""
    with open(filepath, 'r') as f:
        content = f.read()

    original = content

    # 1. Add NavigationStackShim import if using NavigationStack
    if "NavigationStack" in content and "NavigationStackShim" not in content:
        # Find import section
        import_pattern = r'^import\s+\w+'
        imports = re.findall(import_pattern, content, re.MULTILINE)
        if imports:
            last_import = imports[-1]
            content = content.replace(
                f"import {last_import}",
                f"import {last_import}\nimport NavigationStackShim"
            )
        else:
            content = "import NavigationStackShim\n" + content

    # 2. NavigationStack -> CompatNavigationStack (but not in comments/strings)
    # This is tricky - we need to be careful
    content = re.sub(
        r'\bNavigationStack\b(?![A-Z])',
        'CompatNavigationStack',
        content
    )

    # 3. NavigationLink(value:) -> CompatNavigationLink
    # This is complex - need to handle various forms
    content = re.sub(
        r'NavigationLink\s*\(\s*value\s*:',
        'CompatNavigationLink(value:',
        content
    )

    # 4. .navigationDestination(for:) -> .compatNavigationDestination(for:)
    content = re.sub(
        r'\.navigationDestination\s*\(\s*for\s*:',
        '.compatNavigationDestination(for:',
        content
    )

    # 5. @Observable -> ObservableObject (class level)
    # This is the most complex - need to convert property wrappers too
    # Pattern: @MainActor @Observable \n final class Foo {
    content = re.sub(
        r'@MainActor\s+@Observable\s*\n\s*(final\s+class\s+\w+)',
        r'@MainActor\nfinal class \1: ObservableObject',
        content
    )
    content = re.sub(
        r'@Observable\s*\n\s*(final\s+class\s+\w+)',
        r'\1: ObservableObject',
        content
    )
    content = re.sub(
        r'@Observable\s*\n\s*(class\s+\w+)',
        r'\1: ObservableObject',
        content
    )

    # 6. Add ObservableObjectShim import if using ObservableObject
    if "ObservableObject" in content and "ObservableObjectShim" not in content and "@Observable" not in content:
        imports = re.findall(r'^import\s+\w+', content, re.MULTILINE)
        if imports:
            last_import = imports[-1]
            if "ObservableObjectShim" not in content:
                content = content.replace(
                    f"import {last_import}",
                    f"import {last_import}\nimport ObservableObjectShim"
                )

    # 7. SwiftData imports -> CoreData
    content = re.sub(
        r'import\s+SwiftData',
        'import CoreData',
        content
    )

    # 8. ModelContext -> NSManagedObjectContext
    content = re.sub(
        r'\bModelContext\b',
        'NSManagedObjectContext',
        content
    )

    # 9. ModelContainer -> NSPersistentContainer
    content = re.sub(
        r'\bModelContainer\b',
        'NSPersistentContainer',
        content
    )

    # 10. @Query -> @FetchRequest (rough approximation)
    content = re.sub(
        r'@Query\s*\(',
        '@FetchRequest(',
        content
    )

    # 11. .modelContext -> .managedObjectContext
    content = re.sub(
        r'\.modelContext\b',
        '.managedObjectContext',
        content
    )

    # 12. PersistenceController -> CoreDataStack
    content = re.sub(
        r'\bPersistenceController\b',
        'CoreDataStack',
        content
    )

    # 13. FetchDescriptor -> NSFetchRequest (rough - MUST BE MANUALLY FIXED)
    content = re.sub(
        r'FetchDescriptor<\s*(\w+)\s*>',
        r'NSFetchRequest<\1>(entityName: "\1") // TODO: Verify entity name matches',
        content
    )

    # 14. #Predicate -> NSPredicate (rough - will need manual fix)
    content = re.sub(
        r'#Predicate\s*\{[^}]+\}',
        'NSPredicate(format: "") // TODO: Convert #Predicate',
        content
    )

    if content != original:
        changes.append((filepath, len(content) - len(original)))
        with open(filepath, 'w') as f:
            f.write(content)
        return True
    return False

def main():
    print("Starting bulk migration for iOS 15 backport...")
    print("=" * 60)

    total_files = 0
    modified_files = 0

    for src_dir in SOURCE_DIRS:
        path = Path(src_dir)
        if not path.exists():
            print(f"Skipping {src_dir} (not found)")
            continue

        for ext in EXTENSIONS:
            for filepath in path.rglob(f"*{ext}"):
                total_files += 1
                if process_file(filepath):
                    modified_files += 1
                    print(f"  Modified: {filepath}")

    print("=" * 60)
    print(f"Total files processed: {total_files}")
    print(f"Files modified: {modified_files}")
    print("\n⚠️  IMPORTANT: This script does automatic regex replacements.")
    print("   You MUST review all changes manually!")
    print("   Key manual fixes needed:")
    print("   - @Observable classes: convert properties to @Published")
    print("   - #Predicate -> NSPredicate manually")
    print("   - FetchDescriptor -> NSFetchRequest with proper predicates")
    print("   - NavigationLink(value:) -> CompatNavigationLink (check each usage)")
    print("   - SwiftData relationships -> CoreData relationships")
    print("   - @Query -> @FetchRequest with sortDescriptors")

if __name__ == "__main__":
    main()