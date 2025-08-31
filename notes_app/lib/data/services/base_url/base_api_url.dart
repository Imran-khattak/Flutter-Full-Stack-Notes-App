class ApiConfig {
  // For physical device
  static const String physicalDeviceBaseUrl = 'http://192.168.0.104:5001/v1';
  // For Android emulator
  static const String emulatorBaseUrl = 'http://10.0.2.2:5001/v1';
  // For iOS simulator
  static const String simulatorBaseUrl = 'http://127.0.0.1:5001/v1';

  static String get baseUrl {
    // You can determine this based on your testing needs
    return physicalDeviceBaseUrl; // Use this for physical device testing
  }
}
