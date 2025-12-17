class TextConstants {
  TextConstants._();

  static const headerWelcome = 'Welcome,';
  static const headerName = 'Sample Name';
  static const headerOnBreak = 'On Break';

  static const statusLabel = 'Status';
  static const statusOnline = 'Online';
  static const statusOffline = 'Offline';

  static const welcomeTitle = 'Welcome to Café Niloufer Valet Service';
  static const welcomeSubtitle = "I\'m Sample Name, your valet for today.";
  static const qrInstruction =
      'Please scan this QR code so I can take care of your car and keep you updated on WhatsApp.';

  static const statusOnlineMessage = 'You are now Online';
  static const statusOfflineMessage = 'You are now Offline';
  static const breakEnabledMessage = 'Break mode enabled';
  static const breakDisabledMessage = 'Break mode disabled';

  // Validation Messages
  static const String validationEmailRequired = 'Please enter your email';
  static const String validationEmailInvalid = 'Please enter a valid email';
  static const String validationPasswordRequired = 'Please enter your password';
  static String validationPasswordMinLength(int minLength) =>
      'Password must be at least $minLength characters';
  static const String loginAccessDenied =
      'Access denied. Only ADMIN or PILOT users can access this application.';

  // Default Hint Texts
  static const String defaultEmailHint = 'Enter your email';
  static const String defaultPasswordHint = 'Enter your password';

  // Login
  static const String loginPrompt = 'Please Login to Continue';
  static const String phoneNumberLabel = 'Phone Number';
  static const String phoneNumberHint = 'Enter Phone Number';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter Your Password';
  static const String loginButton = 'Login';
  static const String loginButtonLoading = 'Logging in...';
  static const String forgotPassword = 'Forgot Password?';

  // Forgot Password
  static const String forgotPasswordTitle = 'Forgot Password';
  static const String forgotPasswordDescription =
      'Enter your phone number to receive password reset instructions';
  static const String sendResetInstructions = 'Send Reset Instructions';
  static const String sendResetInstructionsLoading = 'Sending...';

  // Password Reset OTP
  static const String enterOtpTitle = 'Enter OTP';
  static const String enterNewPasswordTitle = 'Enter New Password';
  static String otpSentTo(String phoneNumber) =>
      'We sent a 6-digit code to $phoneNumber';
  static const String verifyOtp = 'Verify OTP';
  static const String verifyingOtp = 'Verifying...';
  static const String otpVerifiedSetPassword =
      'OTP verified. Set a new password.';
  static const String enterSixDigitOtp = 'Please enter the 6-digit OTP.';
  static const String resetTokenMissing =
      'Reset token missing. Please request OTP again.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String newPasswordLabel = 'New Password';
  static const String newPasswordHint = 'Enter your new password';
  static const String submitNewPassword = 'Submit New Password';
  static const String submittingNewPassword = 'Submitting...';
  static const String newPasswordRequired = 'Please enter a new password.';

  // Operator Home & Profile
  static const String operatorHomeTitle = 'Operator Home';
  static const String operatorFallbackName = 'Operator';
  static const String phoneLabel = 'Phone';
  static const String emailLabel = 'Email';
  static const String usernameLabel = 'Username';
  static const String joinedLabel = 'Joined';
  static const String resetPassword = 'Reset Password';
  static const String profileMenuTitle = 'Profile';
  static const String logoutMenuTitle = 'Logout';

  // Change Password Dialog
  static const String passwordChangedSuccess = 'Password changed successfully';
  static const String currentPasswordLabel = 'Current Password';
  static const String currentPasswordHint = 'Enter your current password';
  static const String confirmNewPasswordLabel = 'Confirm New Password';
  static const String confirmNewPasswordHint = 'Confirm your new password';
  static const String close = 'Close';
  static const String update = 'Update';

  // Block Dropdown
  static const String blockLabel = 'Block';
  static String selectLabel(String label) => 'Select $label';
  static const String searchBlockHint = 'Search block...';

  // Footer
  static const String poweredBy = 'Powered By';
}
