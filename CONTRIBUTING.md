# Coding standards

This project generally follows the standards set by the [OCLint](https://github.com/oclint/oclint) team.

* 4 literal spaces (no tabs).
* 120 columns maximum. No exceptions.
* Align long method calls with the label colons.
* If a multi-line method call cannot be aligned on the colons, then it is acceptable to move that line back until it does. It is acceptable if the line begins at column 0 if the selector argument simply cannot align at all.
* Opening bracket on same line such as `if (condition) {`. The `else` part should always be in between the `}` bracket and the `{` bracket: `} else {`.
* Specific files are allowed to have some compiler warnings removed. Please do not use `Wno-*` for any new files or files not already using such a flag.
* For the time being, no Swift code, even if the class is new.
* No spacing between open and close brackets: `if ( a )`. Write `if (a)`, `if (a_function_call()) {`.
* Assignment within an `if` or `while` statement is allowed only with double brackets: `if ((a = something())) {`.
* If extra performance is needed, C and C++ (`.mm` extension) are allowed. Anything with complex C++ syntax should be well explained.
