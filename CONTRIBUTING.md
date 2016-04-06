# Development process

Please read the Working Process/Quickstart Guide in [[README.md]] first.

For any modification of the observatory-extension, such as adding new features,
refactoring or bug-fixing, a topic branch must be created out of the `develop`
branch and be used for the development process.

Modifications are done inside `src/pg/sql`.

Take into account:

*  Tests must be added for any new functionality
   (inside `src/pg/test` as well as to
   detect any bugs that are being fixed.
*  Add or modify the corresponding documentation files in the `doc` folder.
*  Naming Conventions: we will use CamelCase with a prefix, as it is done in postgis. E.g: `OBS_GetSegmentationSnapshot`
   Prefix function names intended for public use with `OBS_`
   and private functions (to be used only internally inside
   the extension)  with `_OBS_`.

Once the code is ready to be tested, update the local development installation
with `sudo make install`.
This will update the 'dev' version of the extension in `src/pg/` and
make it available to PostgreSQL.

Run the tests with `make test`.

Update extension in a working database with:

* `ALTER EXTENSION observatory VERSION TO 'current';`
  `ALTER EXTENSION observatory VERSION TO 'dev';`

Note: we keep the current development version install as 'dev' always;
we update through the 'current' alias to allow changing the extension
contents but not the version identifier. This will fail if the
changes involve incompatible function changes such as a different
return type; in that case the offending function (or the whole extension)
should be dropped manually before the update.

If the extension has not previously been installed in a database,
it can be installed directly with:

* `CREATE EXTENSION observatory WITH VERSION 'dev';`

Before proceeding to the release process a peer review of the code is
a must.

Once the feature or bugfix is completed and all the tests are passing
a Pull-Request shall be created on the topic branch, reviewed by a peer
and then merged back into the `develop` branch when all CI tests pass.

When the changes in the `develop` branch are to be released in a new
version of the extension, a PR must be created on the `develop` branch.

The release manage will take hold of the PR at this moment to proceed
to the release process for a new revision of the extension.

## Relevant development tasks available in the Makefile

```
* `make help` show a short description of the available targets

* `sudo make install` will generate the extension scripts for the development
  version ('dev'/'current').
  Intended for use by developers.

* `make test` will run the tests for the installed development extension.
  Intended for use by developers.
```
