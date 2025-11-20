.PHONY: fetch-assets
fetch-assets:
	ASSETS_FOLDER="assets_$$CLIENT_ID" && \
	echo "ASSETS_FOLDER=$$ASSETS_FOLDER" >> $$CM_ENV && \
	aws s3 cp "s3://$$S3_BUCKET_NAME/$$ASSETS_FOLDER.tar.gz" "$$ASSETS_FOLDER.tar.gz" && \
	tar -zxvf "$$ASSETS_FOLDER.tar.gz"

.PHONY: set-app-name
set-ios-app-name:
	/usr/libexec/PlistBuddy -c "Set :CFBundleName $$APP_NAME" -c "Set :CFBundleDisplayName $$APP_NAME" ./$$XCODE_SCHEME/Info.plist