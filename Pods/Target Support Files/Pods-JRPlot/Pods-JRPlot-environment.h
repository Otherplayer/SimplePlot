
// To check if a library is compiled with CocoaPods you
// can use the `COCOAPODS` macro definition which is
// defined in the xcconfigs so it is available in
// headers also when they are imported in the client
// project.


// CorePlot
#define COCOAPODS_POD_AVAILABLE_CorePlot
#define COCOAPODS_VERSION_MAJOR_CorePlot 1
#define COCOAPODS_VERSION_MINOR_CorePlot 5
#define COCOAPODS_VERSION_PATCH_CorePlot 1

// PLCrashReporter
#define COCOAPODS_POD_AVAILABLE_PLCrashReporter
// This library does not follow semantic-versioning,
// so we were not able to define version macros.
// Please contact the author.
// Version: 1.2-rc5.

