NAME = DisableKey

BUILD_PATH = build

XCODE_PROJECT_PATH = $(NAME).xcodeproj
XCODE_SCHEME = $(NAME)
XCODE_ARCHIVE_PATH = $(BUILD_PATH)/$(NAME).xcarchive
XCODE_ARCHIVE_BUNDLE_PATH = $(XCODE_ARCHIVE_PATH)/Products/Applications/$(NAME).app

TARGET_PATH = $(XCODE_ARCHIVE_BUNDLE_PATH)

ARCHIVE_PATH = $(BUILD_PATH)/$(NAME).app.zip

.PHONY: all
all: $(ARCHIVE_PATH)

.PHONY: claen
clean:
	git clean -dfX

$(XCODE_ARCHIVE_BUNDLE_PATH):
	xcodebuild \
		-project "$(XCODE_PROJECT_PATH)" \
		-scheme "$(XCODE_SCHEME)" \
		-derivedDataPath "$(BUILD_PATH)" \
		-archivePath "$(XCODE_ARCHIVE_PATH)" \
		archive

# Use `xcodebuild -exportArchive` to sign archive.
# For now, we don't sign archive so directly using archive bundle.
#$(TARGET_PATH): $(XCODE_ARCHIVE_BUNDLE_PATH)
#	xcodebuild \
#		-exportArchive \
#		...

$(ARCHIVE_PATH): $(TARGET_PATH)
	ditto -c -k --sequesterRsrc --keepParent $< $@
