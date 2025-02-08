/// Executes [callback] and returns it result.
R run<R extends Object?>(R Function() callback) => callback();
