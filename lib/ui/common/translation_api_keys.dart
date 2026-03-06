/// Maps text constants to alternative API keys for translation lookup.
/// Use when the API returns keys in a different format than the derived
/// camelCase (e.g. snake_case, different casing).
///
/// Example: If API returns "parked_car" instead of "parkedCar", add:
///   TextConstants.parkedCar: ['parked_car'],
const Map<String, List<String>> translationApiKeys = {};
