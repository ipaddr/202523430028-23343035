/// Simulates fetching remote data asynchronously.
///
/// Demonstrates `async`/`await` and [Future]: the function waits 2 seconds
/// (as if contacting a server) then returns a result string.
Future<String> fetchData() async {
  await Future.delayed(const Duration(seconds: 2));
  return "Data fetched successfully!";
}

/// Emits the integers from 1 to [to], one per second.
///
/// Demonstrates Dart's `async*` generator syntax and [Stream]: each `yield`
/// pushes a value downstream without blocking the caller.
Stream<int> countStream(int to) async* {
  for (int i = 1; i <= to; i++) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
  }
}
