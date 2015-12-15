# Specta

A light-weight TDD / BDD framework for Objective-C & Cocoa.

### FEATURES

* RSpec-like BDD DSL
* Super quick and easy to set up
* Runs on top of XCTest
* Excellent Xcode integration

### SCREENSHOT

![Specta Screenshot](http://github.com/petejkim/stuff/raw/master/images/specta-screenshot.png)

### SETUP

Use [CocoaPods](http://github.com/CocoaPods/CocoaPods)

```ruby
target :MyApp do
  # your app dependencies
end

target :MyAppTests do
  pod 'Specta',      '~> 0.2.1'
  # pod 'Expecta',     '~> 0.2.3'   # expecta matchers
  # pod 'OCMock',      '~> 2.2.1'   # OCMock
  # pod 'OCHamcrest',  '~> 3.0.0'   # hamcrest matchers
  # pod 'OCMockito',   '~> 1.0.0'   # OCMock
  # pod 'LRMocky',     '~> 0.9.1'   # LRMocky
end
```

or

1. Clone from Github.
2. Run `rake` in project root to build.
3. Add a "Cocoa/Cocoa Touch Unit Testing Bundle" target if you don't already have one.
4. Copy and add all header files in `products` folder to the Test target in your Xcode project.
5. For **OS X projects**, copy and add `libSpecta-macosx.a` in `products` folder to the Test target in your Xcode project.  
   For **iOS projects**, copy and add `libSpecta-ios-universal.a` in `products` folder to the Test target in your Xcode project.
6. Add `-ObjC` and `-all_load` to the "Other Linker Flags" build setting for the Spec/Test target in your Xcode project.
7. Add the following to your test code.

```objective-c
#import "Specta.h"
```

Standard XCTest matchers such as `XCTAssertEqualObjects` and `XCTAssertNil` work, but you probably want to add a nicer matcher framework - [Expecta](http://github.com/petejkim/expecta/) to your setup. Or if you really prefer, [OCHamcrest](https://github.com/jonreid/OCHamcrest) works fine too. Also, add a mocking framework: [OCMock](http://ocmock.org/).

## WRITING SPECS

```objective-c
#import "Specta.h"

SharedExamplesBegin(MySharedExamples)
// Global shared examples are shared across all spec files.

sharedExamplesFor(@"a shared behavior", ^(NSDictionary *data) {
  it(@"should do some stuff", ^{
    id obj = data[@"key"];
    // ...
  });
});

SharedExamplesEnd

SpecBegin(Thing)

describe(@"Thing", ^{
  sharedExamplesFor(@"another shared behavior", ^(NSDictionary *data) {
    // Locally defined shared examples can override global shared examples within its scope.
  });

  beforeAll(^{
    // This is run once and only once before all of the examples
    // in this group and before any beforeEach blocks.
  });

  beforeEach(^{
    // This is run before each example.
  });

  it(@"should do stuff", ^{
    // This is an example block. Place your assertions here.
  });

  it(@"should do some stuff asynchronously", ^AsyncBlock {
    // Async example blocks need to invoke done() callback.
    done();
  });

  itShouldBehaveLike(@"a shared behavior", @{@"key" : @"obj"});

  itShouldBehaveLike(@"another shared behavior", ^{
    // Use a block that returns a dictionary if you need the context to be evaluated lazily,
    // e.g. to use an object prepared in a beforeEach block.
    return @{@"key" : @"obj"};
  });

  describe(@"Nested examples", ^{
    it(@"should do even more stuff", ^{
      // ...
    });
  });

  pending(@"pending example");

  pending(@"another pending example", ^{
    // ...
  });

  afterEach(^{
    // This is run after each example.
  });

  afterAll(^{
    // This is run once and only once after all of the examples
    // in this group and after any afterEach blocks.
  });
});

SpecEnd
```

* `beforeEach` and `afterEach` are also aliased as `before` and `after` respectively.
* `describe` is also aliased as `context`.
* `it` is also aliased as `example` and `specify`.
* `itShouldBehaveLike` is also aliased as `itBehavesLike`.
* Use `pending` or prepend `x` to `describe`, `context`, `example`, `it`, and `specify` to mark examples or groups as pending.
* Use `^AsyncBlock` as shown in the example above to make examples wait for completion. `done()` callback needs to be invoked to let Specta know that your test is complete. The default timeout is 10.0 seconds but this can be changed by calling the function `setAsyncSpecTimeout(NSTimeInterval timeout)`.
* `(before|after)(Each/All)` also accept `^AsyncBlock`s.
* Do `#define SPT_CEDAR_SYNTAX` before importing Specta if you prefer to write `SPEC_BEGIN` and `SPEC_END` instead of `SpecBegin` and `SpecEnd`.
* Prepend `f` to your `describe`, `context`, `example`, `it`, and `specify` to set focus on examples or groups. When specs are focused, all unfocused specs are skipped.
* To use original XCTest reporter, set an environment variable named `SPECTA_REPORTER_CLASS` to `SPTXCTestReporter` in your test scheme.

### CONTRIBUTION GUIDELINES

* Please use only spaces and indent 2 spaces at a time.
* Please prefix instance variable names with a single underscore (`_`).
* Please prefix custom classes and functions defined in the global scope with `SPT`.

## LICENSE

Copyright (c) 2012-2013 [Specta Team](https://github.com/specta?tab=members). This software is licensed under the [MIT License](http://github.com/petejkim/specta/raw/master/LICENSE).