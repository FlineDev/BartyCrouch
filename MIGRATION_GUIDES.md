# Migration Guides

This project follows [Semantic Versioning](http://semver.org).

Please follow the appropriate guide below when **upgrading to a new major version** of BartyCrouch (e.g. 1.5 -> 2.0).

## Upgrade from 3.x to 4.x
- All subcommands except `lint` were bundled into the `update` subcommand.
- Choosing specific subcommands and passing options was moved to the configuration file `.bartycrouch.toml`. See the [appropriate section](https://github.com/Flinesoft/BartyCrouch#configuration) in the README.
- Update your build script to the [new simplified version](https://github.com/Flinesoft/BartyCrouch#build-script). Also make sure it's run as one of the first steps.
- The `--override-comments` (`-c`) option on the `code` subcommand is now always turned on, no need to configure.
- The `--extract-loc-strings` (`-e`) option on the `code` subcommand is now always turned on, no need to configure.
- Consider using the new [`transform` task](https://github.com/Flinesoft/BartyCrouch#localization-workflow-via-transform) instead of – or in addition to – the `code` task.

## Upgrade from 2.x to 3.x

- Change structure `bartycrouch -s "$BASE_PATH"` to `bartycrouch interfaces -p "$BASE_PATH"`
- Change structure `bartycrouch -t "{ id: <API_ID> }|{ secret: <API_SECRET> }" -s "$BASE_PATH" -l en` to `bartycrouch translate -p "$BASE_PATH" -l en -i "<API_ID>" -s "<API_SECRET>"`
- Use automatic file search with `-p` (was `-s` before) instead of options `-i`, `-o`, `-e` (those were deleted)
- Rename usages of option "force" (`-f`) to be "override" (`-o`)

It is recommended to update your build script to the [currently suggested](#build-script) one if you were using it.

## Upgrade from 1.x to 2.x

- Change command structure `bartycrouch "$BASE_PATH" -a` to `bartycrouch -s "$BASE_PATH"`
- Remove `-c` option if you were using it, BartyCrouch 2.x creates missing keys by default
- Use the new `-t` `-s` `-l` options instead of adding all Strings files manually, e.g.:

Simplify this build script code

```shell
bartycrouch -t $CREDS -i "$EN_PATH/Localizable.strings" -a -c
bartycrouch -t $CREDS -i "$EN_PATH/Main.strings" -a
bartycrouch -t $CREDS -i "$EN_PATH/LaunchScreen.strings" -a
bartycrouch -t $CREDS -i "$EN_PATH/CustomView.strings" -a
```

by replacing it with this:

```shell
bartycrouch -t "$CREDS" -s "$PROJECT_DIR" -l en
```


## Upgrade from 0.x to 1.x

- `--input-storyboard` and `-in` were **renamed** to `--input` and `-i`
- `--output-strings-files` and `-out` were **renamed** to `--output` and `-o`
- Multiple paths passed to `-output` are now **separated by whitespace instead of comma**
- e.g. `-out "path/one,path/two"` should now be `-o "path/one" "path/two"`
- `--output-all-languages` and `-all` were **renamed** to `--auto` and `-a`
