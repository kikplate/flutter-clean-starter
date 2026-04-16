import 'package:fpdart/fpdart.dart';

import '../failures/failure.dart';

/// Task that may fail with [Failure] or succeed with [T].
typedef ApiTask<T> = TaskEither<Failure, T>;
