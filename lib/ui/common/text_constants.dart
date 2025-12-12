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
}
