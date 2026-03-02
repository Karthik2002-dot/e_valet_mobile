import 'package:flutter/foundation.dart';
import 'package:niloufer_valet_mobile/services/translations/translations_cache.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

/// Holds the current translation map in memory so the UI can read translated
/// strings synchronously. Call [load] on app start and after the user changes
/// language so the app rebuilds with new translations.
class AppTranslationsNotifier extends ChangeNotifier {
  Map<String, String>? _translations;
  String? _currentLanguageCode;

  /// Local fallbacks for keys that may be missing from the API.
  /// Hindi (hi) and Telugu (te): Driver screen, Operator screen, Guidelines, Help
  static const Map<String, Map<String, String>> _localFallbacks = {
    'hi': {
      'guidelines': 'दिशानिर्देश',
      'help': 'सहायता',
      // Driver screen
      'onBreak': 'विश्राम पर',
      'hi': 'नमस्ते',
      'parkVehicle': 'वाहन पार्क करें',
      'retrieveVehicle': 'वाहन लाएं',
      // Operator screen
      'dashboardOverview': 'डैशबोर्ड अवलोकन',
      'availableTags': 'उपलब्ध टैग',
      'availableValets': 'उपलब्ध वैलेट',
      'vehiclesInTransit': 'ट्रांजिट में वाहन',
      'totalVehiclesParked': 'कुल पार्क किए गए वाहन',
      'retrievalRequests': 'पुनर्प्राप्ति अनुरोध',
      'requestedAt': 'अनुरोधित समय',
      'parkedBy': 'द्वारा पार्क किया',
      'cardNumber': 'कार्ड नंबर',
      'assignedTo': 'को नियुक्त',
      'retrievalRequested': 'पुनर्प्राप्ति अनुरोध',
      'assigned': 'नियुक्त',
      'accepted': 'स्वीकृत',
      'arrived': 'पहुंचे',
      'noPendingRetrievalRequests': 'कोई लंबित पुनर्प्राप्ति अनुरोध नहीं',
      'noAvailableDriversAtTheMoment': 'इस समय कोई उपलब्ध ड्राइवर नहीं',
      'enterCardNumber': 'कार्ड नंबर दर्ज करें',
      'manualRequest': 'मैन्युअल अनुरोध',
      'taking a Break': 'विश्राम ले रहा है',
      'takingABreak': 'विश्राम ले रहे हैं',
      'relax and restart': 'रिलैक्स और रीस्टार्ट!',
      'relaxAndRestart!': 'आराम करें और फिर से शुरू करें!',
      'endBreak': 'विश्राम समाप्त करें',
      'vehicleDetails': 'वाहन विवरण',
      'enterCardNumberOrScanTheQRInTheCardBelow.':
          'कार्ड नंबर दर्ज करें या नीचे दिए गए कार्ड में QR स्कैन करें।',
      'scan': 'स्कैन',
      'submit': 'सबमिट करें',
      'capture a photo of the car': 'वाहन का फोटो कैप्चर करें।',
      'captureAPhotoOfTheCar.': 'वाहन का फोटो कैप्चर करें।',
      'capture the car clearly with location landmarks':
          'वाहन को स्थान के चिह्नों के साथ स्पष्ट रूप से कैप्चर करें।',
      'captureTheCarClearlyWithLocationLandmarks':
          'वाहन को स्थान के चिह्नों के साथ स्पष्ट रूप से कैप्चर करें।',
      'your session has been not completed please click on continue to proceed':
          'आपका सेशन पूरा नहीं हुआ है कृपया कॉन्टीन्यू पर क्लिक करें जारी रखने के लिए',
      'yourSessionHasBeenNotCompletedPleaseClickOnContinueToProceed':
          'आपका सत्र पूरा नहीं हुआ है। कृपया जारी रखने के लिए कंटिन्यू पर क्लिक करें',
      'continue': 'जारी रखने के लिए',
      'reviewEntry': 'रिव्यू एंट्री',
      'retake': 'रीटेक करें',
      'parkingLocation': 'पार्किंग लोकेशन',
      'parkingLocationHint': 'पार्किंग स्थान या लोकेशन दर्ज करें (जैसे A-12)',
      'enter parking spot or location (e.g. A....)':
          'पार्किंग स्थान या लोकेशन दर्ज करें (जैसे A-12)',
      'enterParkingSpotOrLocation(E.g.A-12)':
          'पार्किंग स्थान या लोकेशन दर्ज करें (जैसे A-12)',
      'done': 'डॉन करें',
      'successfullyParked': 'सफलतापूर्वक पार्क किया गया',
      'returnToHome': 'होम पर लौटें',
      'retrievalRequest': 'पुनर्प्राप्ति अनुरोध',
      'collectKeys': 'कुंजिका एकत्रित करें',
      'please click the button below once you\'ve entered the lobby':
          'कृपया लॉबी में प्रवेश करने के बाद नीचे दिए गए बटन पर क्लिक करें।',
      'pleaseClickTheButtonBelowOnceYou\'veEnteredTheLobby.':
          'कृपया लॉबी में प्रवेश करने के बाद नीचे दिए गए बटन पर क्लिक करें।',
      'confirm arrival': 'आगमन की पुष्टि करें',
      'confirmArrival': 'आगमन की पुष्टि करें',
      'confirm handover': 'हांडओवर को सत्यापित करें',
      'customer missing': 'ग्राहक गायब है',
      // Valet Dashboard (Operator)
      'valetDashboard': 'वैलेट डैशबोर्ड',
      'monitorAndManageYourValetTeam':
          'अपनी वैलेट टीम की निगरानी और प्रबंधन करें',
      'searchByNameOrPhone...': 'नाम या फोन से खोजें...',
      'totalValets': 'कुल वैलेट',
      'available': 'उपलब्ध',
      'onDuty': 'ड्यूटी पर',
      'offline': 'ऑफलाइन',
      'carsPickedUp:': 'कार उठाए गए : ',
      'carsHandOvered:': 'कार सौंपी गई : ',
      'on-breakDuration:': 'विश्राम अवधि : ',
      'clockIn:': 'क्लॉक इन : ',
      'clockOut:': 'क्लॉक आउट : ',
      'lastActivity:': 'अंतिम गतिविधि : ',
      'mins': ' मिनट',
      'logout': 'लॉगआउट',
      'error': 'त्रुटि',
      'retry': 'पुनः प्रयास करें',
      'name': 'नाम',
      'phone': 'फोन',
      'status': 'स्थिति',
      'close': 'बंद करें',
      'noValetsFound': 'कोई वैलेट नहीं मिला',
    },
    'te': {
      'guidelines': 'మార్గదర్శకాలు',
      'help': 'సహాయం',
      // Driver screen
      'onBreak': 'విశ్రాంతిలో',
      'hi': 'నమస్కారం',
      'parkVehicle': 'వాహనాన్ని పార్క్ చేయండి',
      'retrieveVehicle': 'వాహనాన్ని తిరిగి పొందండి',
      // Operator screen
      'dashboardOverview': 'డాష్‌బోర్డ్ అవలోకనం',
      'availableTags': 'అందుబాటులో ఉన్న ట్యాగ్‌లు',
      'availableValets': 'అందుబాటులో ఉన్న వాలెట్‌లు',
      'vehiclesInTransit': 'ట్రాన్జిట్‌లో వాహనాలు',
      'totalVehiclesParked': 'మొత్తం పార్క్ చేయబడిన వాహనాలు',
      'retrievalRequests': 'పునరుద్ధరణ అభ్యర్థనలు',
      'requestedAt': 'అభ్యర్థించిన సమయం',
      'parkedBy': 'పార్క్ చేసినవారు',
      'assignedTo': 'కేటాయించబడింది',
      'cardNumber': 'కార్డ్ నంబర్',
      'retrievalRequested': 'పునరుద్ధరణ అభ్యర్థించబడింది',
      'assigned': 'కేటాయించబడింది',
      'accepted': 'ఆమోదించబడింది',
      'arrived': 'వచ్చారు',
      'noPendingRetrievalRequests': 'పెండింగ్ పునరుద్ధరణ అభ్యర్థనలు లేవు',
      'noAvailableDriversAtTheMoment': 'ప్రస్తుతం అందుబాటులో డ్రైవర్లు లేరు',
      'enterCardNumber': 'కార్డ్ నంబర్ నమోదు చేయండి',
      'manualRequest': 'మాన్యువల్ అభ్యర్థన',
      'taking a Break': 'విశ్రాంతిలో',
      'takingABreak': 'విశ్రాంతి తీసుకుంటున్నారు',
      'relax and Restart': 'రిలాక్స్ మరియు రిస్టార్ట్!',
      'relaxAndRestart!': 'ఆరామం చేయండి మరియు మళ్ళీ ప్రారంభించండి!',
      'endBreak': 'విశ్రాంతి ముగించండి',
      'vehicleDetails': 'వాహన వివరాలు',
      'enterCardNumberOrScanTheQRInTheCardBelow.':
          'కార్డ్ నంబర్ నమోదు చేయండి లేదా కింద ఉన్న కార్డ్‌లోని QR స్క్యాన్ చేయండి।',
      'scan': 'స్క్యాన్',
      'submit': 'సబ్మిట్ చేయండి',
      'capture a photo of the car': 'వాహనం యొక్క ఫోటో తీయండి।',
      'captureAPhotoOfTheCar.': 'వాహనం యొక్క ఫోటో తీయండి।',
      'capture the car clearly with location landmarks':
          'స్థాన గుర్తులతో వాహనాన్ని స్పష్టంగా క్యాప్చర్ చేయండి।',
      'captureTheCarClearlyWithLocationLandmarks':
          'స్థాన గుర్తులతో వాహనాన్ని స్పష్టంగా క్యాప్చర్ చేయండి।',
      'your session has been not completed please click on continue to proceed':
          'మీ సెషన్ పూర్తి చేయబడలేదు. దయచేసి క్రమించడానికి కంటిన్యూ క్లిక్ చేయండి',
      'yourSessionHasBeenNotCompletedPleaseClickOnContinueToProceed':
          'మీ సెషన్ పూర్తి చేయబడలేదు. దయచేసి క్రమించడానికి కంటిన్యూ క్లిక్ చేయండి',
      'continue': 'క్రమించడానికి',
      'reviewEntry': 'రివ్యూ ఎంట్రీ',
      'retake': 'రిటేక్ చేయండి',
      'parkingLocation': 'పార్కింగ్ లాకేషన్',
      'parkingLocationHint': 'పార్కింగ్ స్థానం లేదా స్థానం ఇవ్వండి (ఉదా. A-12)',
      'enter parking spot or location (e.g. A....)':
          'పార్కింగ్ స్థానం లేదా స్థానం ఇవ్వండి (ఉదా. A-12)',
      'enterParkingSpotOrLocation(E.g.A-12)':
          'పార్కింగ్ స్థానం లేదా స్థానం ఇవ్వండి (ఉదా. A-12)',
      'done': 'డోన్ చేయండి',
      'successfullyParked': 'సఫలతాపూర్వకంగా పార్క్ చేయబడింది',
      'returnToHome': 'హోమ్ కి తిరిగి వెళ్ళండి',
      'retrievalRequest': 'పునరుద్ధరణ అభ్యర్థన',
      'collectKeys': 'కుంజికాలు సంగ్రహించండి',
      'please click the button below once you\'ve entered the lobby':
          'దయచేసి లాబీలోకి ప్రవేశించిన తర్వాత క్రింద ఉన్న బటన్ క్లిక్ చేయండి।',
      'pleaseClickTheButtonBelowOnceYou\'veEnteredTheLobby.':
          'దయచేసి లాబీలోకి ప్రవేశించిన తర్వాత క్రింద ఉన్న బటన్ క్లిక్ చేయండి।',
      'confirm arrival': 'ఆగమనాన్ని నిర్ధారించండి',
      'confirmArrival': 'ఆగమనాన్ని నిర్ధారించండి',
      'confirm handover': 'హాండోవర్ సర్వే చేయండి',
      'customer missing': 'క్రీడాకర్ లేదు',
      // Valet Dashboard (Operator)
      'valetDashboard': 'వాలెట్ డాష్‌బోర్డ్',
      'monitorAndManageYourValetTeam':
          'మీ వాలెట్ బృందాన్ని పర్యవేక్షించండి మరియు నిర్వహించండి',
      'searchByNameOrPhone...': 'పేరు లేదా ఫోన్ ద్వారా శోధించండి...',
      'totalValets': 'మొత్తం వాలెట్‌లు',
      'available': 'అందుబాటులో',
      'onDuty': 'డ్యూటీలో',
      'offline': 'ఆఫ్‌లైన్',
      'carsPickedUp:': 'కార్లు తీసుకున్నారు : ',
      'carsHandOvered:': 'కార్లు హస్తాంతరం చేయబడ్డాయి : ',
      'on-breakDuration:': 'విశ్రాంతి వ్యవధి : ',
      'clockIn:': 'క్లాక్ ఇన్ : ',
      'clockOut:': 'క్లాక్ అవుట్ : ',
      'lastActivity:': 'చివరి కార్యాచరణ : ',
      'mins': ' నిమిషాలు',
      'logout': 'లాగౌట్',
      'error': 'దోషం',
      'retry': 'మళ్ళీ ప్రయత్నించండి',
      'name': 'పేరు',
      'phone': 'ఫోన్',
      'status': 'స్థితి',
      'close': 'మూసివేయండి',
      'noValetsFound': 'వాలెట్‌లు కనుగొనబడలేదు',
    },
  };

  /// Converts a display string (e.g. "Parked Car", "Dashboard") to the API key
  /// format (e.g. "parkedCar", "dashboard") so we can look up in the API response.
  static String _displayStringToApiKey(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return value.toLowerCase();
    final first = parts.first.toLowerCase();
    if (parts.length == 1) return first;
    final rest = parts
        .skip(1)
        .map((p) =>
            p.isEmpty ? p : p[0].toUpperCase() + p.substring(1).toLowerCase())
        .join();
    return first + rest;
  }

  /// Returns the translated string for [textConstant] (e.g. [TextConstants.logout]).
  /// Derives the API key from the string; returns translation or [textConstant] as fallback.
  String get(String textConstant) {
    final apiKey = _displayStringToApiKey(textConstant);
    final value = _translations?[apiKey];
    if (value != null && value.isNotEmpty) return value;
    // Use local fallback for Guidelines and Help when API doesn't have them
    final langCode = _currentLanguageCode?.toLowerCase();
    if (langCode != null && langCode.isNotEmpty) {
      final fallback = _localFallbacks[langCode]?[apiKey] ??
          _localFallbacks[langCode.split('-').first]?[apiKey];
      if (fallback != null && fallback.isNotEmpty) return fallback;
    }
    return textConstant;
  }

  /// Loads translations from [TranslationsCache] and notifies listeners so the
  /// app rebuilds. Call after app start (e.g. in provider create) and after
  /// the user selects a new language in the language dropdown.
  Future<void> load() async {
    try {
      final response = await TranslationsCache().getTranslations();
      _translations = response?.translations;
      _currentLanguageCode = response?.language;
      notifyListeners();
    } catch (_) {
      // Keep previous translations on error
    }
  }
}
