class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateBookTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Book title is required';
    }
    if (value.length < 2) {
      return 'Title must be at least 2 characters';
    }
    return null;
  }

  static String? validateAuthor(String? value) {
    if (value == null || value.isEmpty) {
      return 'Author name is required';
    }
    if (value.length < 2) {
      return 'Author name must be at least 2 characters';
    }
    return null;
  }
}
