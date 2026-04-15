# Runbook

## Structure of `Makefile`
`Makefile` has the main entrypoint at the root of the `Peacock` project. Each part contains its own logical functions but they are available from root `Makefile`. Included files separated by logical point parts:

- `make/android.mk` — all commands related to android build
- `make/ios.mk` — all commans for setting up ios build
- `make/flutter.mk` — helpers for manipulating flutter project
- `make/help.mk` — self-documentation hooks
- `make/utils.mk` — folders creating, documentation generating and other utils
- `make/args.mk` — sub-helper with args implementation (Deprecated)
- `make/errors.mk` — defined errors with exit codes

### Short-help
To get short descriptions of all self-documented make commands you can simply run `make` from the root of project (All commands in help output are sorted from **A** to **Z**):
```bash
$ make
android-apk-all                Makes apks for all envs: DEV, STAGING and PROD
android-apk                    Creates android APK, renames it and places at ./outputs dir
android-bundle-all             Makes appbundles for all envs: DEV, STAGING and PROD
android-bundle                 Creates android AppBundle, renames it and places at ./outputs dir
android-config-clean           Removes stored configs
android-config-reset           Resets changed configs by original ones
android-config-store           Stores original config to ./original folder
android-config-update          Update configs depending on env [DEV|STAGING|PROD]
...
```
> Call all `make` functions from root of the project


### Flutter
| Command        | Explanation                                                                         | Usage                 |
| :------------- | :---------------------------------------------------------------------------------- | :-------------------- |
| build          | Sets up `build_runner` generate files                                               | `make build`          |
| build-clean    | Same as `build` but removes all conflicts                                           | `make build-clean`    |
| clean          | Runs `flutter clean` in all packages                                                | `make clean`          |
| coverage       | Runs all tests with generating coverage file                                        | `make coverage`       |
| coverage-clear | Clears coverage file from unneeded files (used when tested manually or through IDE) | `make coverage-clear` |
| get            | Runs `flutter pub get` in all packages                                              | `make get`            |
| locale         | Generates localizations for project                                                 | `make locale`         |
| watch          | Same as `build` but works continiously                                              | `make watch`          |

### Android
> All build commands will move with renaming result to `./outputs` directory at the root of project

Possible environments for building and using application:

- `DEV` — version will used by back-enders to test that they didn't break something
- `STAGING` — here front-enders works all the time. It's a kind of copy of production version
- `PROD` — version only for customers and tests with demo-account

#### Application building commands
| Command            | Explanation                                    | Usage                                   |
| :----------------- | :--------------------------------------------- | :-------------------------------------- |
| android-apk-all    | Builds 3 APKs for each environment             | `make android-apk-all number=10`        |
| android-apk        | Builds APK with given **env** and **number**   | `make android-apk env=DEV number=10`    |
| android-bundle-all | Same as `android-apk-all` but builds appbundle | `make android-bundle-all number=10`     |
| android-bundle     | Same as `android-apk` but builds appbundle     | `make android-bundle env=DEV number=10` |

#### Config helpers
To allow build and install few different versions of Android application we need to change its boundary `app_id` which is defined in `AndroidManifest.xml`, `Gradle` and other files. To manage changing of these variables we can use comands which replace variables by predefined ones.

| Command               | Explanation                                                               | Usage                                |
| :-------------------- | :------------------------------------------------------------------------ | :----------------------------------- |
| android-config-store  | Stores original configs (aka backup). Use before any other commands       | `make android-config-store`          |
| android-config-update | Updated configs by provided env                                           | `make android-config-update env=DEV` |
| android-config-reset  | Resets updated config with original one (original should be saved before) | `make android-config-reset`          |
| android-config-clean  | Removes all backuped configs                                              | `make android-config-clean`          |

Basically none of these command should be executed manualy. Because every build command includes storing original configs, reseting and cleaning them after build. Only if build was not successful you need to reset and clean configs manualy.

### Errors
File `make/errors.mk` has some predefined exit-codes as and error flag.

- `ANDROID_ERROR` — used when error happens on android side (basically on build stage)
- `TYPE_NOT_PROVIDED` — internal error when type for generic method was not provided. As example method `--android-build` method can return this error
- `ENV_NOT_PROVIDED` — you didn't provide `env` argument to command
- `BUILD_NUMBER_NOT_PROVIDED` — you didn't provide `number` argument to command
- `WRONG_ENV_PROVIDED` — means you provided `env` argument but it didn't match allowed one

### Utils
Also related to project utilities functions with documentations, code analysis and etc.

| Command    | Explanation                                                        | Usage                               |
| :--------- | :----------------------------------------------------------------- | :---------------------------------- |
| feature    | Creates folder structure for new feature with provided name        | `make feature smarthome`            |
| docs-build | Generates flutter base documentation to `./docs/api` directory     | `make docs-build`                   |
| docs       | Serves generated documentation as website                          | `make docs`                         |
| docs-image | Creates docker image with `Dockerfile.code-docs` with provided tag | `make docs-image tag=documentation` |

### Help
File `make/help.mk` contains all supported functionality to provide for `makefiles` self-documentation functionality. It's for `Makefile` developers only.
