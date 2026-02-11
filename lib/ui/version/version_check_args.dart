/// Arguments passed from splash after SplashCompleted, used by version check
/// and permissions screens for post-version/permissions navigation.
class VersionCheckArgs {
  final bool isAuthenticated;
  final List<String> roles;

  const VersionCheckArgs({
    required this.isAuthenticated,
    required this.roles,
  });
}
