# Observatory extension

CartoDB extension that implements the row-level functions needed by the Observatory Service.

## Code organization

```
.
├── doc     # documentation
├── release # released versions
└── src     # source code
    └── pg
        ├── sql
        └── test
            ├── expected
            ├── fixtures
            └── sql
```

# Development workflow

We distinguish two roles regarding the development cycle:

* *developers* will implement new functionality and bugfixes into
  the codebase and will request for new releases of the extension.
* A *release manager* will attend these requests and will handle
  the release process. The release process is sequential:
  no concurrent releases will ever be in the works.

We use the default `develop` branch as the basis for development.
The `master` branch is used to merge and tag releases to be
deployed in production.

Developers shall create a new topic branch from `develop` for any new feature
or bugfix and commit their changes to it and eventually merge back into
the `develop` branch. When a new release is required a Pull Request
will be open against the `develop` branch.

The `develop` pull requests will be handled by the release manage,
who will merge into master where new releases are prepared and tagged.
The `master` branch is the sole responsibility of the release masters
and developers must not commit or merge into it.

## Development Guidelines

For a detailed description of the development process please see
the [CONTRIBUTING.md](CONTRIBUTING.md) guide.

Any modification to the source code
shall always be done in a topic branch created from the `develop` branch.

Tests, documentation and peer code reviews are required for all
modifications.

The tests are executed by running this from the top directory:
```
sudo make install
make test
```
## Release

The release and deployment process is described in the
[RELEASE.md](RELEASE.md) guide and it is the responsibility of the designated
release manager.
