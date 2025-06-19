// Configurazione Firebase
class FirebaseConfig {
  static String get apiKey => 'YOUR_API_KEY';
  static String get authDomain => 'YOUR_AUTH_DOMAIN';
  static String get projectId => 'YOUR_PROJECT_ID';
  static String get storageBucket => 'YOUR_STORAGE_BUCKET';
  static String get messagingSenderId => 'YOUR_MESSAGING_SENDER_ID';
  static String get appId => 'YOUR_APP_ID';

  static Map<String, dynamic> get config => {
        'apiKey': apiKey,
        'authDomain': authDomain,
        'projectId': projectId,
        'storageBucket': storageBucket,
        'messagingSenderId': messagingSenderId,
        'appId': appId,
      };

  static Future<void> init() async {
    // Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
}
