.PHONY: customize-app
customize-app: fetch-assets set-app-name set-app-icon set-bundle-id set-launch-color set-header-image set-config-plist

.PHONY: fetch-assets
fetch-assets:
	ASSETS_FOLDER="assets_$$CLIENT_ID" && \
	echo "ASSETS_FOLDER=$$ASSETS_FOLDER" >> $$CM_ENV && \
	aws s3 cp "s3://$$S3_BUCKET_NAME/$$ASSETS_FOLDER.tar.gz" "$$ASSETS_FOLDER.tar.gz" && \
	tar -zxvf "$$ASSETS_FOLDER.tar.gz"

.PHONY: set-app-name
set-app-name:
	/usr/libexec/PlistBuddy -c "Set :CFBundleName $$APP_NAME" -c "Set :CFBundleDisplayName $$APP_NAME" ./$$XCODE_SCHEME/Info.plist

.PHONY: set-app-icon
set-app-icon:
	. $$CM_ENV && \
	cp -r ./$$ASSETS_FOLDER/$$APP_ICON ./$$XCODE_SCHEME/Assets.xcassets/

.PHONY: set-bundle-id
set-bundle-id:
	sed -i '' -e 's/PRODUCT_BUNDLE_IDENTIFIER \= [^\;]*\;/PRODUCT_BUNDLE_IDENTIFIER = '$$BUNDLE_ID';/' ./$$XCODE_SCHEME.xcodeproj/project.pbxproj

.PHONY: set-launch-color
set-launch-color:
	. $$CM_ENV && \
	cp -r ./$$ASSETS_FOLDER/$$LAUNCH_SCREEN ./$$XCODE_SCHEME/Assets.xcassets/
	
.PHONY: set-header-image
set-header-image:
	. $$CM_ENV && \
	cp -r ./$$ASSETS_FOLDER/$$HEADER ./$$XCODE_SCHEME/Assets.xcassets/

.PHONY: set-config-plist
set-config-plist:
	. $$CM_ENV && \
	cp -r ./$$ASSETS_FOLDER/Config.plist ./$$XCODE_SCHEME/

.PHONY: ios-code-sign
ios-code-sign:
	keychain initialize && \
	app-store-connect fetch-signing-files $$BUNDLE_ID --type IOS_APP_STORE && \
	keychain add-certificates && \
	xcode-project use-profiles
	
.PHONY: increment-build-number
increment-build-number:
	agvtool new-version -all $$(($$(app-store-connect get-latest-testflight-build-number $$APP_STORE_ID) + 1))
	
.PHONY: build-ipa
build-ipa:
    agvtool new-version -all $$(($$(app-store-connect get-latest-testflight-build-number $$APP_STORE_ID) + 1)) && \
	xcode-project build-ipa \
		--project "$$XCODE_SCHEME.xcodeproj" \
		--scheme "$$XCODE_SCHEME" \
		--archive-xcargs "COMPILATION_CACHE_ENABLE_CACHING=True"