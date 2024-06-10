class AuthErrors {
  static String getErrorMessage(String code){
    switch (code){
      case "user-not-found":
        return "No user found for that email";
      case "wrong-password":
        return "Wrong password provided, try with another password";
      case "invalid-email":
        return "Please use a valid email";
      case "weak-password":
        return "Please use a strong password";
      case "email-already-in-use":
        return "Email is already in use";
      case "username-already-in-use":
        return "Username is already taken";
      case "password-not-match":
        return "Passwords don\'t match";
      default:
        return "An error occurred, please try again";
    }
  }
}