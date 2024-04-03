# `[Foundation][macOS 14/iOS 17] Serious word break regression in StringProtocol.range(of:options:range:locale:)`

This is filed as [rdar://FB13706707](rdar://FB13706707).

## Overview

The documentation for the `options` parameter passed to Swift's `StringProtocol.range(of:options:range:locale:)` says:

https://developer.apple.com/documentation/swift/stringprotocol/range(of:options:range:locale:)
https://developer.apple.com/documentation/swift/string/compareoptions
https://developer.apple.com/documentation/foundation/nsstring/compareoptions

> static var regularExpression: NSString.CompareOptions
>
> The search string is treated as an ICU-compatible regular expression. If set, no other options can apply except caseInsensitive and anchored. You can use this option only with the rangeOfString:… methods and replacingOccurrences(of:with:options:range:).

The `\b` regular expression escape is documented as:

> Match if the current position is a word boundary. Boundaries occur at the transitions between word (\w) and non-word (\W) characters, with combining marks ignored. For better word boundaries, see useUnicodeWordBoundaries.

Before macOS 14 / iOS 17, the `\b` escape passed to `StringProtocol.range(of:options:range:locale:)` was correctly ICU-compatible and detected word breaks using the ICU definition.

With macOS 14 / iOS 17 and later, the `\b` escape passed to `StringProtocol.range(of:options:range:locale:)` is incorrectly treated as if `useUnicodeWordBoundaries` was set, but only for Swift `String.range(of:options:range:locale:)`.

Note that `NSString.range(of:options:range:locale:)` still works correctly in Swift; only `String.range(of:options:range:locale:)` is broken.

## Expected Behavior

The `\b` escape passed to `StringProtocol.range(of:options:range:locale:)` should detect word breaks using the ICU definition on iOS 17 and macOS 15.

## Actual Behavior

The `\b` escape passed to `StringProtocol.range(of:options:range:locale:)` detects word breaks using the Swift Regex / Unicode TR#29 definition on iOS 17 and macOS 15, as if the `.useUnicodeWordBoundaries` option for `NSRegularExpression.Options` is set.

## Repro

To reproduce, run:

```
git clone https://github.com/bhamiltoncx/sonoma-regex-bug-repro && cd sonoma-regex-bug-repro && swift test
```

All tests in the repro pass as expected on iOS 16 and macOS 14.

On iOS 17 and macOS 15 and above, the test `testWordBoundarySwiftStringRangeOfString()` in the repro fails:

```
Test Suite 'All tests' started at 2024-04-03 10:39:23.228.
Test Suite 'sonoma_regex_bug_reproPackageTests.xctest' started at 2024-04-03 10:39:23.229.
Test Suite 'SonomaRegexBugTestSwift' started at 2024-04-03 10:39:23.229.
Test Case '-[sonoma_regex_bug_repro.SonomaRegexBugTestSwift testWordBoundaryNSRegularExpression]' started.
Test Case '-[sonoma_regex_bug_repro.SonomaRegexBugTestSwift testWordBoundaryNSRegularExpression]' passed (0.002 seconds).
Test Case '-[sonoma_regex_bug_repro.SonomaRegexBugTestSwift testWordBoundaryNSStringStringRangeOfString]' started.
Test Case '-[sonoma_regex_bug_repro.SonomaRegexBugTestSwift testWordBoundaryNSStringStringRangeOfString]' passed (0.000 seconds).
Test Case '-[sonoma_regex_bug_repro.SonomaRegexBugTestSwift testWordBoundarySwiftStringRangeOfString]' started.
/Users/benhamilton/Developer/sonoma_regex_bug_repro/Tests/sonoma_regex_bug_repro/sonoma_regex_bug_repro.swift:29: error: -[sonoma_regex_bug_repro.SonomaRegexBugTestSwift testWordBoundarySwiftStringRangeOfString] : XCTAssertEqual failed: ("nil") is not equal to ("Optional(Range(Swift.String.Index(_rawBits: 327693)..<Swift.String.Index(_rawBits: 589837)))")
Test Case '-[sonoma_regex_bug_repro.SonomaRegexBugTestSwift testWordBoundarySwiftStringRangeOfString]' failed (0.028 seconds).
Test Suite 'SonomaRegexBugTestSwift' failed at 2024-04-03 10:39:23.259.
Executed 3 tests, with 1 failure (0 unexpected) in 0.030 (0.030) seconds
Test Suite 'sonoma_regex_bug_reproPackageTests.xctest' failed at 2024-04-03 10:39:23.259.
Executed 3 tests, with 1 failure (0 unexpected) in 0.030 (0.030) seconds
Test Suite 'All tests' failed at 2024-04-03 10:39:23.260.
Executed 3 tests, with 1 failure (0 unexpected) in 0.030 (0.031) seconds
```

