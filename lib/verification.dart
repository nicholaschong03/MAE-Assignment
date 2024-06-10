bool verifyEmail(String email) {
  // Check if email is not empty and contains '@' and ends with '.com' or '.my'
  return email.isNotEmpty && email.contains('@') && (email.endsWith('.com') || email.endsWith('.my'));
}

bool verifyPassword(String password) {
  // Check if password is not empty and has at least 8 characters, 1 capital letter, 1 number, and 1 special character
  RegExp passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$');
  return password.isNotEmpty && passwordRegex.hasMatch(password);
}

bool verifyPhoneNumber(String phoneNumber) {
  // Check if phone number is in number form and has the correct length based on the prefix
  if (phoneNumber.startsWith('11')) {
    return int.tryParse(phoneNumber) != null && phoneNumber.length == 10;
  } else {
    return int.tryParse(phoneNumber) != null && phoneNumber.length == 9;
  }
}