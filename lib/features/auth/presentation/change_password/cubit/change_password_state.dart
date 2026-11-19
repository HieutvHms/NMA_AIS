import 'package:equatable/equatable.dart';

enum ChangePasswordStatus { initial, submitting, success, failure }

enum ChangePasswordErrorType { wrongCurrentPassword, general }

enum PasswordStrength {
  none(0, ''),
  weak(1, 'Yếu'),
  medium(2, 'Trung bình'),
  good(3, 'Khá'),
  strong(4, 'Mạnh');

  final int level;
  final String label;

  const PasswordStrength(this.level, this.label);
}

class ChangePasswordState extends Equatable {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  final bool obscureOld;
  final bool obscureNew;
  final bool obscureConfirm;

  final ChangePasswordStatus status;
  final String? errorMessage;
  final ChangePasswordErrorType? errorType;

  const ChangePasswordState({
    this.oldPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.obscureOld = true,
    this.obscureNew = true,
    this.obscureConfirm = true,
    this.status = ChangePasswordStatus.initial,
    this.errorMessage,
    this.errorType,
  });

  static final _upperRegex = RegExp(r'[A-Z]');
  static final _lowerRegex = RegExp(r'[a-z]');
  static final _digitRegex = RegExp(r'[0-9]');

  // 4 quy tắc kiểm tra mật khẩu mới
  bool get hasMinLength => newPassword.length >= 8;

  bool get hasUpperAndLower =>
      _upperRegex.hasMatch(newPassword) && _lowerRegex.hasMatch(newPassword);

  bool get hasDigit => _digitRegex.hasMatch(newPassword);

  bool get differsFromOld =>
      newPassword.isNotEmpty && newPassword != oldPassword;

  bool get allRulesPassed =>
      hasMinLength && hasUpperAndLower && hasDigit && differsFromOld;

  /// Độ mạnh 4 mức dựa trên số quy tắc đạt được khi đã bắt đầu nhập mật khẩu mới.
  PasswordStrength get strength {
    if (newPassword.isEmpty) return PasswordStrength.none;

    var score = 0;
    if (hasMinLength) score++;
    if (hasUpperAndLower) score++;
    if (hasDigit) score++;
    if (differsFromOld) score++;

    switch (score) {
      case 0:
      case 1:
        return PasswordStrength.weak;
      case 2:
        return PasswordStrength.medium;
      case 3:
        return PasswordStrength.good;
      default:
        return PasswordStrength.strong;
    }
  }

  bool get hasConfirmInput => confirmPassword.isNotEmpty;

  bool get isConfirmMatched =>
      confirmPassword.isNotEmpty && confirmPassword == newPassword;

  bool get isConfirmMismatched =>
      confirmPassword.isNotEmpty && confirmPassword != newPassword;

  bool get isSubmitting => status == ChangePasswordStatus.submitting;

  /// Chỉ bật nút submit khi đã nhập mật khẩu hiện tại, đạt đủ 4 quy tắc và xác nhận khớp.
  // bool get canSubmit =>
  //     !isSubmitting &&
  //     oldPassword.trim().isNotEmpty &&
  //     allRulesPassed &&
  //     isConfirmMatched;

  /// Lỗi hiển thị ngay dưới ô "Mật khẩu hiện tại".
  String? get currentPasswordError =>
      status == ChangePasswordStatus.failure &&
          errorType == ChangePasswordErrorType.wrongCurrentPassword
      ? (errorMessage ?? 'Mật khẩu hiện tại không đúng.')
      : null;

  ChangePasswordState copyWith({
    String? oldPassword,
    String? newPassword,
    String? confirmPassword,
    bool? obscureOld,
    bool? obscureNew,
    bool? obscureConfirm,
    ChangePasswordStatus? status,
    String? errorMessage,
    ChangePasswordErrorType? errorType,
    bool clearError = false,
  }) {
    return ChangePasswordState(
      oldPassword: oldPassword ?? this.oldPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscureOld: obscureOld ?? this.obscureOld,
      obscureNew: obscureNew ?? this.obscureNew,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorType: clearError ? null : (errorType ?? this.errorType),
    );
  }

  @override
  List<Object?> get props => [
    oldPassword,
    newPassword,
    confirmPassword,
    obscureOld,
    obscureNew,
    obscureConfirm,
    status,
    errorMessage,
    errorType,
  ];
}
