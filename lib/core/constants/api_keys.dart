class ApiKeys {
  /// Replace with your Gemini API key from https://makersuite.google.com/
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

  static bool get isGeminiConfigured =>
      geminiApiKey != 'AIzaSyCMDWKVYkSelsaGfayDNm1ADq--YLFzJ-g' && geminiApiKey.isNotEmpty;
}
