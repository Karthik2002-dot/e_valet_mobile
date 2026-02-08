class TextConstants {
  TextConstants._();

  static const dashboard = 'Dashboard';
  static const slots = 'Slots';
  static const parkedCar = 'Parked Car';
  static const valets = 'Valets';
  static const carLogs = 'Car Logs';
  static const profile = 'Profile';
  static const logout = 'Logout';

  static const emptyText = '';
  static const headerWelcome = 'Welcome,';
  static const headerName = 'Sample Name';

  // QR Scanner
  static const orEnterKey = 'Or Enter Key';

  // Manual Request
  static const pleaseEnterCardNumber = 'Please enter a card number';
  static const pleaseEnterValidCardNumber = 'Please enter a valid card number';
  static const manualRequest = 'MANUAL REQUEST';
  static const processingText = 'PROCESSING...';
  static const failedToCreateRequest = 'Failed to create manual request...';

  // Assign Driver
  static const failedToAssignDriver = 'Failed to assign driver';

  static const welcomeTitle = 'Welcome to Café Niloufer Valet Service';
  static const welcomeSubtitle = "I'm Sample Name, your valet for today.";
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
      'Enter your phone number to receive OTP';
  static const String sendResetInstructions = 'Send OTP';
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
  static const String resendOtp = 'Resend OTP';
  static const String resendingOtp = 'Resending...';
  static const String newPasswordLabel = 'New Password';
  static const String newPasswordHint = 'Enter your new password';
  static const String submitNewPassword = 'Submit New Password';
  static const String submittingNewPassword = 'Submitting...';
  static const String newPasswordRequired = 'Please enter a new password.';
  static const String passwordRequirements =
      'Password must contain uppercase, lowercase, number and special character and more than 8 characters';
  static const String validationPasswordNoSpaces =
      'Password cannot contain spaces';

  // Driver Home & Profile
  static const String driverHomeTitle = 'Driver Home';
  static const String driverFallbackName = 'Driver';
  static const String userFallbackName = 'User';
  static String readyToParkMessage(String driverName) =>
      'Hi $driverName, Ready to Park?';
  static const String scanKeyTagInstruction =
      'Scan the key tag to start the parking process.';
  static const String enterTagNumberLink = 'Or enter the tag number';
  static const String pleaseTurnOnlineToPark =
      'Please Turn Online To Park a Car';
  static const String cannotParkCarOffline =
      'Can\'t park Car unless you turn Online';

  // Clock-in too far (after login)
  static const String clockInTooFarTitle = 'Too Far From Outlet';
  static const String clockInTooFarSubtitle =
      'You are too far from the check-in location to go online.';
  static const String submitButton = 'Submit';
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

  // QR Code Scanner
  static const String processingQrCode = 'Processing QR Code...';
  static const String scannedDataLabel = 'Scanned Data:';
  static const String scannedLabel = 'Scanned:';
  static const String errorProcessingQrCode = 'Error Processing QR Code';
  static const String qrCodeScannedSuccessfully =
      'QR Code scanned successfully';

  // Break Messages
  static const String takingBreak = 'Taking a Break';
  static const String relaxAndRestart = 'Relax and Restart!';
  static const String endBreak = 'End Break';

  // Manual Tag Entry
  static const String enterTagNumberTitle = 'Enter the Tag Number to Proceed';
  static const String tagNumberLabel = 'Tag Number';
  static const String tagNumberHint = 'Enter Badge Number';
  static const String scanTagNumberLink = 'Or scan the tag number';

  // QR Status Messages
  static const String scannedSuccess = 'Scanned Success';
  static const String cardNumberLabel = 'Card Number';
  static const String cardLabel = 'Card: ';
  static const String rescanButton = 'Rescan';
  static const String errorLabel = 'Error';

  // Camera Screen
  static const String captureCarInstruction =
      'Capture the car clearly with location\nlandmarks';
  static const String photoMode = 'PHOTO MODE';
  static const String cameraNotAvailable = 'No camera available on this device';
  static const String errorInitializingCamera = 'Error initializing camera';
  static const String errorTogglingFlash = 'Error toggling flash';
  static const String cameraNotReady = 'Camera not ready';
  static const String errorCapturingPhoto = 'Error capturing photo';
  static const String photoCaptured = 'Photo captured';

  // Preview/Review Screen
  static const String reviewEntry = 'Review Entry';
  static const String reParkingEntryReview = 'Re-Parking Entry Review';
  static const String submitRePark = 'Submit Re-Park';
  static const String retakeButton = 'Retake';
  static const String submittingCarPhoto = 'Submitting car photo...';

  // Image Validation Messages
  static const String vehicleNotFound = 'Vehicle not found in image';
  static const String numberPlateNotFound = 'Vehicle number plate not found';
  static const String errorValidatingImage = 'Error validating image';
  static const String errorProcessingImage = 'Error processing image';

  // Session/Retrieval Related
  static const String badgeNumber = 'Badge Number';
  static const String parkedBy = 'Parked By';
  static const String unknown = 'Unknown';
  static const String retrievalRequest = 'Retrieval Request';
  static const String noActiveRetrievalRequests =
      'No active retrieval requests';
  static const String acceptRequest = 'Accept Request';

  // Handover Related
  static const String confirmHandover = 'Confirm Handover';
  static const String customerMissing = 'Customer Missing';
  static const String confirmationHandover = 'Confirmation Handover';
  static const String enterTwoDigitCode =
      'Enter the 2-digit code provided by the user to complete the handover.';
  static const String customerHasNoPhone = 'Customer has no phone?';

  // Customer Missing Dialog
  static const String reparkConfirmationTitle =
      'Are you sure to re-park the car?';
  static const String reparkConfirmationMessage =
      'This will cancel the retrieval and you must park the car again.';
  static const String proceedToRepark = 'Proceed to Re-Park';
  static const String cancel = 'Cancel';

  // Arrival Related
  static const String slideToConfirmArrival = 'Confirm Arrival';
  static const String slideToConfirmHandover = 'Confirm Handover';
  static const String slideToCustomerMissing = 'Customer Missing';
  static const String locateCarUsingPhoto = 'LOCATE CAR USING THE PHOTO';

  // Permission Messages
  static const String locationPermissionRequiredHandover =
      'Location permission is required to confirm handover';
  static const String locationPermissionRequiredArrival =
      'Location permission is required to confirm arrival';

  // Phone Number
  static const String countryCode = '+91';

  // Car Success Screen
  static const String successfullyParked = 'Successfully Parked';
  static const String returnToHome = 'Return To Home';

  // Validation Messages (Manual Entry)
  static const String validationEnterValidTagNumber =
      'Please enter a valid tag number';
  static const String validationEnterTagNumber = 'Please enter the tag number';
  static const String validationEnterValidNumber =
      'Please enter a valid number';
  static const String tagSubmissionError =
      'The QR code you scanned or the tag number you entered is invalid or already used. Please kindly check the QR code or tag number.';

  // Dashboard (Operator)
  static const String dashboardOverview = 'Dashboard Overview';
  static const String retryButton = 'Retry';
  static const String availableTags = 'Available Tags';
  static const String availableValets = 'Available Valets';
  static const String vehiclesInTransit = 'Vehicles In Transit';
  static const String totalVehiclesParked = 'Total Vehicles Parked';

  // Car Logs Screen (Operator)
  static const String carLogsTitle = 'Car Logs';
  static const String carLogsDescription = 'View vehicle activity logs';
  static const String carLogsKpiTotalParked = 'Total Cars';
  static const String carLogsKpiInTransit = 'Cars In Transit';
  static const String carLogsKpiHandovered = 'Cars Handovered';
  static const String carLogsKpiInLot = 'Parked Cars';
  static const String totalTrips = 'Total Trips';
  static const String totalDistance = 'Total Distance';
  static const String totalTripsValue = '456';
  static const String totalDistanceValue = '2340 km';

  // Car Logs Table Headers
  static const String carLogsTagNumber = 'Card Number';
  static const String carLogsCarStatus = 'Car Status';
  static const String carLogsDuration = 'Duration';
  static const String carLogsParkLocation = 'Park Location';
  static const String carLogsParkedBy = 'Parked By';
  static const String carLogsParkedAt = 'Parked At';
  static const String carLogsHandoverAt = 'Handover At';

  // Car Logs Search and Messages
  static const String carLogsSearchHint =
      'Search by card numnber, or parked by...';
  static const String carLogsNoDataMessage = 'No car logs available';
  static const String carLogsErrorMessage = 'Error loading car logs';

  // Car Logs Pagination
  static const String paginationShowLabel = 'Show:';

  // Drivers Screen (Operator)
  static const String driversTitle = 'Drivers';
  static const String driversDescription = 'Manage and monitor all drivers';
  static const String totalDrivers = 'Total Drivers';
  static const String activeToday = 'Active Today';
  static const String totalDriversValue = '24';
  static const String activeTodayValue = '18';

  // Slots Screen (Operator)
  static const String parkingSlotsTitle = 'Parking Slots';
  static const String parkingSlotsDescription =
      'Manage and monitor parking slots';
  static const String available = 'Available';
  static const String occupied = 'Occupied';
  static const String availableValue = '12';
  static const String occupiedValue = '8';
  static const String parkedCarTitle = 'Parked Car';
  static const String parkedCarDescription = 'Manage and monitor parked cars';
  static const String noCarsParked = 'No Cars Parked';

  // QR Reader
  static const String cameraErrorReinitializing =
      'Camera error. Reinitializing...';

  // Operator Home (Legacy)
  static const String operatorHomeTitle = 'Operator Home';
  static const String welcomeOperator = 'Welcome, Operator! (Menu: ';

  // Operator Dashboard Data
  static const String retrievalRequests = 'Retrieval Requests';
  static const String availableDrivers = 'Available Drivers';
  static const String digitalKeyRack = 'Digital Key Rack';
  static const String noPendingRetrievalRequests =
      'No pending retrieval requests';
  static const String noAvailableDrivers = 'No available drivers at the moment';
  static const String noVehiclesInKeyRack = 'No vehicles in key rack';

  // Assign Driver Dialog
  static const String assignDriverTitle = 'Assign Driver';
  static const String selectDriverInstruction =
      'Select a driver to assign this retrieval request';

  // Valet Dashboard
  static const String valetDashboardTitle = 'Valet Dashboard';
  static const String valetDashboardDescription =
      'Monitor and manage your valet team';
  static const String totalValets = 'Total Valets';
  static const String onavailableValets = 'Available';
  static const String onDutyValets = 'On Duty';
  static const String onBreakValets = 'On Break';
  static const String offlineValets = 'Offline';
  static const String searchByNameOrPhone = 'Search By Name Or Phone...';

  // Valet Status Labels
  static const String statusAvailable = 'Available';
  static const String statusOnDuty = 'On Duty';
  static const String statusOnBreak = 'On Break';
  static const String statusOffline = 'Offline';
  static const headerOnBreak = 'On Break';
  static const statusLabel = 'Status';
  static const statusOnline = 'Online';
  static const statusValueOnline = 'online';
  static const statusValueOffline = 'offline';

  // Valet Card Labels
  static const String carsPickedUpLabel = 'Cars Picked Up : ';
  static const String carsHandedOverLabel = 'Cars Hand overed : ';
  static const String onBreakDurationLabel = 'On-Break Duration : ';
  static const String minsLabel = ' mins';
  static const String noValetsFound = 'No valets found';

  static const String confirmAssignment = 'Confirm Assignment';
  static const String cancelText = 'Cancel';
  static const String confirm = 'Confirm';
  static const String parkedByLabel = 'Parked By ';
  static const String assignedToLabel = 'Assigned To ';
  static const String recommendedBy = 'Recommended - Parked this vehicle';
  static const String recommendedFor = 'Recommended for';

  static const String sessionContinue =
      'Your session has been not completed please click on continue to proceed';
  static const String continueLabel = 'Continue';

  // Car Log Details Popup
  static const String carLogDetailsTitle = 'Car Log Details';
  static const String carStatusLabel = 'Car Status';
  static const String cancelButton = 'Cancel';
  static String failedToUpdateStatus(String error) =>
      'Failed to update status: $error';

  // No Internet
  static const String noInternetTitle =
      'Internet is slow or not there';
  static const String noInternetSubtitle =
      'Please check your connection and try again.';
  static const String retryConnection = 'Retry';
}
