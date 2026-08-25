"
I know how to compress files using an external script.
I use a Bash script, ZIP and some other Linux commands.

"
Class {
	#name : 'EREventRecorderExternalZipScript',
	#superclass : 'Object',
	#category : 'EventRecorder-Server',
	#package : 'EventRecorder-Server'
}

{ #category : 'public' }
EREventRecorderExternalZipScript >> compress: aFileReference [ 
	"Compress aFileReference directory and return ZIP file name."
	| command |
	command := 'compress-category.sh {1}' format: { aFileReference basename asString }.
	self system: command.
	^ 'events-', aFileReference basename asString, '.zip'
]

{ #category : 'accessing' }
EREventRecorderExternalZipScript >> script [
	"This is an expected compress-category.sh content."
'
#!/bin/bash
# Compress a directory for a given category-name that indicates a subdirectory in ~.../events directory.
# USAGE: compress-category.sh <category-name>

CATEGORY_NAME="$1"
if [ -z "$CATEGORY_NAME" ] ; then
    exit 1;
fi

# Where category directories start
ROOT_EVENTS="gt/events"
# Category directory that should be compressed
CATEGORY_DIR="${ROOT_EVENTS}/${CATEGORY_NAME}"
# Temporary ZIP filename that is used for the compression
TMP_ZIP_FILE="$HOME/gc_www_root/events-${CATEGORY_NAME}-tmp.zip"
# ZIP filename to which CATEGORY_DIR is compressed
# Path to be changed around here :)
ZIP_FILE="$HOME/gc_www_root/events-${CATEGORY_NAME}.zip"

# remove duplicated files
# Fdupes -q -r -d -N ~/gt

# remove old temporary file, if it exists
rm -f "$TMP_ZIP_FILE"
# compress to the temporary file, then move to the ZIP_FILE on success
cd "$HOME" \
    && zip -uqr "$TMP_ZIP_FILE" "$CATEGORY_DIR" \
    && mv "$TMP_ZIP_FILE" "$ZIP_FILE"
'
]

{ #category : 'private' }
EREventRecorderExternalZipScript >> system: command [
	"Call external command."
	^ self ffiCall: #(#int #system #(#char #* #command)) module: LibC
]
