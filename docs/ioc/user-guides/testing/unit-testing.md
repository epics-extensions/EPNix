# Unit testing

This document is a user guide for adding unit tests
to your C and C++ functions.

## Using the gtest EPICS module

{ref}`pkg-support.gtest` is an EPICS module
that enables you to use [GoogleTest] as a framework for unit testing and mocking.

The GoogleTest framework is a well-known framework for writing unit tests in C++.
You can test C functions using GoogleTest,
but the tests definitions must be in C++.

(is-library)=
### Functions to test are in a library

:::{note}
Read this section if your top is an IOC.

If the top you want to test already is a library / a support top,
you can skip this section.
:::

To test your C/C++ functions,
it's best to have a library
containing all the functions you want to test.
This makes it easier to have your functions both in your IOC and in your tests.

For example,
if you have a {file}`myFunctions.cpp`,
don't add it to the sources of your IOC.
Instead,
create a library,
for example `myLibrary`,
and add your {file}`myFunctions.cpp` to the sources of this library.

Then,
link your IOC to `myLibrary`.

If you don't have a library,
change your {file}`src/Makefile`
so that it has these lines:

```{code-block} make
:caption: {file}`src/Makefile`: building a library

LIBRARY += myLibrary
myLibrary_SRCS += myFunctions
# Libraries needed by 'myLibrary'
myLibrary_LIBS += Com
```

Then make sure your IOC links with `myLibrary`:

```{code-block} make
:caption: {file}`src/Makefile`: linking an IOC to a library
:emphasize-lines: 10-11

# ...

#=============================
# Build the IOC application

PROD_IOC += myIoc

# ...

# Link myIoc with myLibrary
myIoc_LIBS += myLibrary_LIBS
```

### Adding gtest to the top

Add {ref}`pkg-support.gtest` to the build environment:

```{code-block} nix
:caption: {file}`ioc.nix` --- adding the ``gtest`` support module to the build environment

propagatedBuildInputs = [
  # other support modules...
  epnix.support.gtest
];
```

### Writing tests

To write your unit tests,
create a separate C++ file,
and follow the [GoogleTest documentation].

Here is an example of a test:

```{code-block} cpp
:caption: {file}`myTest.cpp`: example ``gtest`` test definition

#include <gtest/gtest.h>

#include "myLibrary.hpp"

namespace {
class MyTest : public testing::Test {
protected:
    MyTest() { /* Set-up work for each test */ }
    ~MyTest() { /* Clean up work for each test */ }
};

TEST_F(MyTest, myTest1)
{
    // Test something
    EXPECT_EQ(2 + 2, 4) << "2 * 2 must be equal to 4";
}

TEST_F(MyTest, myTest2)
{
    EXPECT_EQ(6 * 7, 42) << "6 * 7 must be equal to 42";
}

} // namespace
```

### Adding tests to the build

To add your tests to the build,
add these lines to your {file}`src/Makefile`:

```{code-block} make
:caption: {file}`src/Makefile`: adding ``gtest`` tests

GTESTPROD_HOST += myTest
myTest_SRCS += myTest.cpp
myTest_LIBS += myLibrary
GTESTS += myTest
```

(running-tests)=
### Running the tests

To run the tests in your development shell,
run:

```bash
make runtests
```

Running `nix build` also runs tests by default.

To turn off tests inside the Nix build,
add this to your configuration:

```{code-block} nix
:caption: {file}`flake.nix`: turning tests off
:emphasize-lines: 4

        # ...
        # checks.imports = [./checks/simple.nix];

        buildConfig.attrs.doCheck = false;
```

## Using the epics-base facility

epics-base provides the [epicsUnitTest.h] facility for declaring unit tests,
which can be useful if you don't want to import an external EPICS module.

[epicsUnitTest.h] is made in C,
but tests can be written in either C or C++.

### Pre-requisites

Examine gtest's {ref}`is-library`.

### Writing tests

To write epics-base unit tests,
make sure:

- You include `epicsUnitTest.h`
- You include `testMain.h`
  and use the `MAIN` macro
  to define your main function
- Your main function starts with a {samp}`testPlan({n})`,
  with *n* being the number of checks that your test will run
- Your main function returns `testDone()`
- You're using `testOk`, `testPass`, and `testFail` to add checks

Here is an example test:

```{code-block} c
:caption: {file}`myTest.cpp`: example epics-base test definition

#include <epicsUnitTest.h>
#include <testMain.h>

#include "myLibrary.hpp"

static void succeed()
{
    testPass("No issues succeeding");
}

static void checkAddition(int x)
{
    testOk(x + x == 2 * x, "x + x must be equal to 2 * x");
    testOk(x + x + x == 3 * x, "x + x + x must be equal to 3 * x");
}

MAIN(myTest)
{
    // 1 for succeed,
    // 2 for checkAddition which is called 5 times
    testPlan(1 + 5 * 2);

    succeed();

    for(int i = 0; i < 5; ++i) {
       checkAddition(i);
    }

    return testDone();
}
```

### Adding tests to the build

To add your tests to the build,
add these lines to your {file}`src/Makefile`:

```{code-block} make
:caption: {file}`src/Makefile`: adding epics-base tests

TESTPROD_HOST += myTest
myTest_SRCS += myTest.cpp
myTest_LIBS += myLibrary
TESTSCRIPTS_HOST += myTest.t
```

### Running the tests

Examine gtest's {ref}`running-tests`.

[epicsunittest.h]: https://github.com/epics-base/epics-base/blob/R7.0.8.1/modules/libcom/src/misc/epicsUnitTest.h
[googletest documentation]: https://google.github.io/googletest/
[googletest]: https://google.github.io/googletest/
