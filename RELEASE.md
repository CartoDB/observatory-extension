# Release & Deployment Process

Please read the Working Process/Quickstart Guide in [README.md]]
and the Development guidelines in [[CONTRIBUTING.md]].

The release process of a new version of the extension
shall be performed by the designated *Release Manager*.

Having checked PR to be released it shall be
merged back into the `master` branch to prepare the new release.

The version number in `pg/observatory.control` must first be updated.
To do so [Semantic Versioning 2.0](http://semver.org/) is in order.

Thew `NEWS.md` will be updated.

The next command must be executed to produce the main installation
script for the new release, `release/observatory--X.Y.Z.sql`:
```
make release
```

Then, the release manager shall produce upgrade and downgrade scripts
to migrate to/from the previous release. In the case of minor/patch
releases this simply consist in extracting the functions that have changed
and placing them in the proper `release/observatory--X.Y.Z--A.B.C.sql`
file.

The new release can be deployed for staging/smoke tests with this command:

```
sudo make deploy
```

This will copy the current 'X.Y.Z' released version of the extension to
PostgreSQL.

The `sudo make deploy` operation can be also used for installing
the new version after it has been released.

To install a specific version 'X.Y.Z' different from the current one
(which must be present in `releases/`) you can:

```
sudo make deploy RELEASE_VERSION=X.Y.Z
```


## Relevant release & deployment tasks available in the Makefile

```
* `make help` show a short description of the available targets

* `make release` will generate a new release (version number defined in
  `src/pg/observatory.control`) into `release/`.
  Intended for use by the release manager.

* `sudo make deploy` will install the current release X.Y.Z from the
  `release/` files into PostgreSQL.
  Intended for use by the release manager and deployment jobs.

* `sudo make deploy RELEASE_VERSION=X.Y.Z` will install specified version
  previously generated in `release/`
  into PostgreSQL.
  Intended to be used by the release manager and deployment jobs.
```
