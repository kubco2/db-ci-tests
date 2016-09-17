# Collection or CI tests for database packages @ Fedora

This repository includes various tests that will be run for verifying database packages in Fedora.

Dependencies for these tests are the following fedora packages: `koji` `createrepo` `git` `wget` `vim`

To run all tests for a package `mariadb` on Fedora, run the `./run.sh` with name(s) of the package:
```
./run.sh mariadb
```
or run `run.sh` script in particular package directory:
```
cd packages/mariadb
./run.sh
```

To run all tests for all packages, run the same command without arguments:
```
./run.sh
```

To run only particular test (e.g. install validation in -updates-candidate repository) for package `mariadb` on Fedora, go to the particular directory and run:
```
cd packages/mariadb/install
./run.sh
```

To download a specific NVR from koji and run tests against it, run:
```
./run-nvr.sh <package> <nvr>
```
For example:
```
./run-nvr.sh mariadb mariadb-10.1.17-1.fc25
```

##Structure of tests
```
    ├── run.sh      -- main entrypoint to run the tests
    ├── run-nvr.sh  -- main entrypoint to run the tests for a specific NVR from koji
    ├── common      -- contains files common for all tests
    ├── packages -- contains tests for all packages
        │
        ├── mariadb             -- contains tests for the mariadb package
        │   ├── enabled_tests   -- sorted list of enabled tests for mariadb package
        │   ├── run.sh          -- runs all tests listed in enabled_tests file
        │   ├── basic-usage     -- a test for checking basic usage of a package
        │   │       ├── run.sh      -- the main script of the test
        │   │       ├── err         -- expected stderr (oprional)
        │   │       ├── out         -- expected stdout (optional)
        │   │       └── retcode     -- expected return code (optional)
        │   └── install         -- a test for installation of the package
        │           └── run.sh      -- the main script of the test
```

When "run.sh" is run, it compares stdout, stderr and return code with valuse specified in
the test directory. Eg.

    packages/mariadb/tests/check-version/out

When no expected stdout or stderr defined, it compares just return code.
When no return code is specified, the test is succesfull when it returns 0.

###Results
Simple results (passed/failed) are written to stdout. Acctual results (stdout, 
stderr and return code) can be faund in the directory under /tmp, that is printed
to the stdout:

```
Running tests for rh-python34-rh ...
[FAILED]	install
[FAILED]	check-version
[PASSED]	uninstall

1 tests passed, 2 tests failed.

Failed tests:
	  install check-version uninstall
Logs are stored in /tmp/db-results-s6Fhun
NOT ALL TESTS PASSED SUCCESSFULLY
```
