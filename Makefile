.PHONY: fetch-assets
fetch-assets:
	test -n "$$CLIENT_ID" || (echo "Missing CLIENT_ID" && exit 1)
	ASSETS_FOLDER="assets_$$CLIENT_ID" && \
	echo "ASSETS_FOLDER=$$ASSETS_FOLDER" >> $$CM_ENV && \
	aws s3 cp "s3://$$S3_BUCKET_NAME/$$ASSETS_FOLDER.tar.gz" "$$ASSETS_FOLDER.tar.gz" && \
	tar -zxvf "$$ASSETS_FOLDER.tar.gz"