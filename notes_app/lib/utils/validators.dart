class TValidator {
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    // Check for minimum password length
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    // Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }

    // Check for numbers
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }

    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  // // Updated Validator Function
  //   static String? validatePhoneNumber(String? value) {
  //     if (value == null || value.isEmpty) {
  //       return 'Phone number is required.';
  //     }

  //     // Remove spaces and other formatting characters
  //     String cleanedValue = value.replaceAll(RegExp(r'[^\d+]'), '');

  //     // Check if it starts with country code (+)
  //     if (!cleanedValue.startsWith('+')) {
  //       return 'Please include country code (e.g., +92)';
  //     }

  //     // Extract country code and phone number
  //     final RegExp countryCodeRegex = RegExp(r'^\+(\d{1,4})(.*)$');
  //     final match = countryCodeRegex.firstMatch(cleanedValue);

  //     if (match == null) {
  //       return 'Invalid phone number format';
  //     }

  //     final countryCode = match.group(1)!;
  //     final phoneNumber = match.group(2)!;

  //     // Validate country code exists
  //     if (!_isValidCountryCode(countryCode)) {
  //       return 'Invalid country code (+$countryCode)';
  //     }

  //     // Validate phone number length based on country code
  //     return _validatePhoneNumberByCountry(countryCode, phoneNumber);
  //   }

  // // Helper function to check valid country codes
  //   static bool _isValidCountryCode(String countryCode) {
  //     // Add more country codes as needed
  //     const validCountryCodes = [
  //       '1', // US/Canada
  //       '92', // Pakistan
  //       '91', // India
  //       '44', // UK
  //       '33', // France
  //       '49', // Germany
  //       '86', // China
  //       '81', // Japan
  //       '61', // Australia
  //       '971', // UAE
  //       '966', // Saudi Arabia
  //       '90', // Turkey
  //       '20', // Egypt
  //       '27', // South Africa
  //       '55', // Brazil
  //       '52', // Mexico
  //       '39', // Italy
  //       '34', // Spain
  //       '7', // Russia
  //       '82', // South Korea
  //     ];

  //     return validCountryCodes.contains(countryCode);
  //   }

  // // Helper function to validate phone number by country
  //   static String? _validatePhoneNumberByCountry(
  //       String countryCode, String phoneNumber) {
  //     if (phoneNumber.isEmpty) {
  //       return 'Phone number cannot be empty';
  //     }

  //     // Remove any remaining non-digit characters
  //     final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

  //     switch (countryCode) {
  //       case '1': // US/Canada
  //         if (digits.length != 10) {
  //           return 'US/Canada phone numbers must be 10 digits';
  //         }
  //         // Additional validation for US numbers (first digit can't be 0 or 1)
  //         if (digits.startsWith('0') || digits.startsWith('1')) {
  //           return 'Invalid US/Canada phone number format';
  //         }
  //         break;

  //       case '92': // Pakistan
  //         if (digits.length != 10) {
  //           return 'Pakistan phone numbers must be 10 digits';
  //         }
  //         // Pakistan mobile numbers start with 3xx
  //         if (!digits.startsWith('3')) {
  //           return 'Pakistan mobile numbers must start with 3';
  //         }
  //         break;

  //       case '91': // India
  //         if (digits.length != 10) {
  //           return 'India phone numbers must be 10 digits';
  //         }
  //         // Indian mobile numbers start with 6, 7, 8, or 9
  //         if (!RegExp(r'^[6-9]').hasMatch(digits)) {
  //           return 'India mobile numbers must start with 6, 7, 8, or 9';
  //         }
  //         break;

  //       case '44': // UK
  //         if (digits.length < 10 || digits.length > 11) {
  //           return 'UK phone numbers must be 10-11 digits';
  //         }
  //         break;

  //       case '33': // France
  //         if (digits.length != 9) {
  //           return 'France phone numbers must be 9 digits';
  //         }
  //         break;

  //       case '49': // Germany
  //         if (digits.length < 10 || digits.length > 12) {
  //           return 'Germany phone numbers must be 10-12 digits';
  //         }
  //         break;

  //       case '86': // China
  //         if (digits.length != 11) {
  //           return 'China phone numbers must be 11 digits';
  //         }
  //         if (!digits.startsWith('1')) {
  //           return 'China mobile numbers must start with 1';
  //         }
  //         break;

  //       case '81': // Japan
  //         if (digits.length != 10 && digits.length != 11) {
  //           return 'Japan phone numbers must be 10-11 digits';
  //         }
  //         break;

  //       case '971': // UAE
  //         if (digits.length != 9) {
  //           return 'UAE phone numbers must be 9 digits';
  //         }
  //         if (!digits.startsWith('5')) {
  //           return 'UAE mobile numbers must start with 5';
  //         }
  //         break;

  //       case '966': // Saudi Arabia
  //         if (digits.length != 9) {
  //           return 'Saudi Arabia phone numbers must be 9 digits';
  //         }
  //         if (!digits.startsWith('5')) {
  //           return 'Saudi mobile numbers must start with 5';
  //         }
  //         break;

  //       default:
  //         // General validation for other countries
  //         if (digits.length < 7 || digits.length > 15) {
  //           return 'Phone number must be 7-15 digits';
  //         }
  //         break;
  //     }

  //     return null; // Valid phone number
  //   }

  // // Alternative simpler validator (if you want basic validation only)
  //   static String? validatePhoneNumberSimple(String? value) {
  //     if (value == null || value.isEmpty) {
  //       return 'Phone number is required.';
  //     }

  //     // Remove spaces and formatting
  //     String cleanedValue = value.replaceAll(RegExp(r'[^\d+]'), '');

  //     // Check if it starts with +
  //     if (!cleanedValue.startsWith('+')) {
  //       return 'Please include country code (e.g., +92)';
  //     }

  //     // Check minimum length (+1 + at least 7 digits)
  //     if (cleanedValue.length < 9) {
  //       return 'Phone number is too short';
  //     }

  //     // Check maximum length (+1234 + max 15 digits)
  //     if (cleanedValue.length > 19) {
  //       return 'Phone number is too long';
  //     }

  //     // Check if country code and number contain only digits after +
  //     final phonePattern = RegExp(r'^\+\d{1,4}\d{7,15}$');
  //     if (!phonePattern.hasMatch(cleanedValue)) {
  //       return 'Invalid phone number format';
  //     }

  //     return null;
  //   }

  // // Helper method to format phone number for display (optional)
  //   static String formatPhoneNumber(String phoneNumber) {
  //     // Remove all non-digit characters except +
  //     String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

  //     if (cleaned.startsWith('+92') && cleaned.length == 13) {
  //       // Format Pakistan number: +92 3xx xxx xxxx
  //       return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
  //     } else if (cleaned.startsWith('+1') && cleaned.length == 12) {
  //       // Format US number: +1 xxx xxx xxxx
  //       return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8)}';
  //     }

  //     return phoneNumber; // Return original if no specific format
  //   }

  // Add more custom validators as needed for your specific requirements.

  // Even simpler validator (recommended for your use case)
  static String? validatePhoneNumberSimple(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required.';
    }

    // Remove all spaces and special characters except +
    String cleanedValue = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Must start with +
    if (!cleanedValue.startsWith('+')) {
      return 'Please include country code (e.g., +92)';
    }

    // Must have at least 10 characters (+X and 8 digits minimum)
    if (cleanedValue.length < 10) {
      return 'Phone number is too short';
    }

    // Must not exceed 20 characters
    if (cleanedValue.length > 18) {
      return 'Phone number is too long';
    }

    // Must contain only + and digits
    if (!RegExp(r'^\+\d+$').hasMatch(cleanedValue)) {
      return 'Phone number can only contain + and digits';
    }

    return null; // Valid
  }
}
