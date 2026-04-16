.PHONY: get analyze test build watch clean

get:
	flutter pub get

analyze:
	flutter analyze

test:
	flutter test

build:
	dart run build_runner build --delete-conflicting-outputs

watch:
	dart run build_runner watch --delete-conflicting-outputs

clean:
	flutter clean && flutter pub get
