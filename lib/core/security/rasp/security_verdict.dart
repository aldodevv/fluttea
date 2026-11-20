sealed class SecurityVerdict {
  const new();

  const factory allow() = SecurityVerdictAllow;
  const factory warn(List<String> reasons) = SecurityVerdictWarn;
  const factory restrict(List<String> reasons) = SecurityVerdictRestrict;
  const factory block(List<String> reasons) = SecurityVerdictBlock;
  const factory wipe(List<String> reasons) = SecurityVerdictWipe;

  bool get isAllowed => this is SecurityVerdictAllow;
  bool get isBlocked => this is SecurityVerdictBlock || this is SecurityVerdictWipe;
  bool get shouldWipe => this is SecurityVerdictWipe;
}

final class SecurityVerdictAllow extends SecurityVerdict {
  const new();

  @override
  String toString() => 'SecurityVerdict.allow';
}

final class SecurityVerdictWarn extends SecurityVerdict {
  const new(this.reasons);

  final List<String> reasons;

  @override
  String toString() => 'SecurityVerdict.warn(reasons: $reasons)';
}

final class SecurityVerdictRestrict extends SecurityVerdict {
  const new(this.reasons);

  final List<String> reasons;

  @override
  String toString() => 'SecurityVerdict.restrict(reasons: $reasons)';
}

final class SecurityVerdictBlock extends SecurityVerdict {
  const new(this.reasons);

  final List<String> reasons;

  @override
  String toString() => 'SecurityVerdict.block(reasons: $reasons)';
}

final class SecurityVerdictWipe extends SecurityVerdict {
  const new(this.reasons);

  final List<String> reasons;

  @override
  String toString() => 'SecurityVerdict.wipe(reasons: $reasons)';
}
