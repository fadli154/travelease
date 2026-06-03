// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TravelEase';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get signOut => 'Sign Out';

  @override
  String get profile => 'Profile';

  @override
  String get preferences => 'Preferences';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get indonesian => 'Indonesian';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get savedDestinations => 'Saved Destinations';

  @override
  String get overview => 'Overview';

  @override
  String get location => 'Location';

  @override
  String get rating => 'Rating';

  @override
  String get ticket => 'Ticket';

  @override
  String get reviews => 'Reviews';

  @override
  String get openInGoogleMaps => 'Open in Google Maps';

  @override
  String get favorite => 'Favorite';

  @override
  String get saved => 'Saved';

  @override
  String get review => 'Review';

  @override
  String get writeAReview => 'Write a Review';

  @override
  String get submit => 'Submit';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Are you sure you want to delete this?';

  @override
  String get save => 'Save';

  @override
  String get addDestination => 'Add Destination';

  @override
  String get editDestination => 'Edit Destination';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get ticketPrice => 'Ticket Price';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get account => 'Account';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get roleLabel => 'Role';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleUser => 'User';

  @override
  String get appearance => 'Appearance';

  @override
  String get session => 'Session';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get logout => 'Logout';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get notSignedInSubtitle =>
      'Sign in to save favorites, access your profile, and more.';

  @override
  String get demoAvatarNote => 'Demo mode: avatar generated from your name.';

  @override
  String get signInSubtitle => 'Sign in to continue exploring';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get register => 'Register';

  @override
  String get createAccount => 'Create account';

  @override
  String get joinTravelEase => 'Join TravelEase';

  @override
  String get registerSubtitle => 'Save favorites and plan your next trip.';

  @override
  String get fullName => 'Full name';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get nameTooShort => 'Name is too short';

  @override
  String get passwordRequiredRegister => 'Please enter a password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get createAccountBtn => 'Create Account';

  @override
  String get or => 'or';

  @override
  String get signUpWithGoogle => 'Sign up with Google';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get homeWelcomeTitle => 'Where will you go next?';

  @override
  String get featured => 'Featured';

  @override
  String get featuredSubtitle => 'Top-rated picks for you';

  @override
  String get popular => 'Popular';

  @override
  String get popularSubtitle => 'Trending destinations across Indonesia';

  @override
  String get searchHint => 'Beach, temple, city, island...';

  @override
  String get search => 'Search';

  @override
  String get searchUnavailable => 'Search unavailable';

  @override
  String get all => 'All';

  @override
  String destinationsSearchCount(num count) {
    return '$count destinations · tap a category or search';
  }

  @override
  String get noResults => 'No results found';

  @override
  String get discoverIndonesia => 'Discover Indonesia';

  @override
  String get noResultsSubtitle => 'Try another keyword or clear filters.';

  @override
  String get discoverIndonesiaSubtitle =>
      'Search by name, location, or pick a category above.';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get signInToSaveFavorites => 'Sign in to save favorites';

  @override
  String get signInToSaveFavoritesSubtitle =>
      'Create a free account to bookmark your favorite destinations.';

  @override
  String get errorLoadFavorites => 'Could not load favorites';

  @override
  String get favoritesEmpty => 'Favorites Empty';

  @override
  String get favoritesEmptySubtitle =>
      'Save places you love — tap the heart icon on any destination.';

  @override
  String get errorLoadDestinations => 'Could not load destinations';

  @override
  String get errorLoadDestinationsSubtitle =>
      'Check your internet connection or Firestore rules.';

  @override
  String get emptyDestinations => 'No destinations yet';

  @override
  String get emptyDestinationsSubtitle =>
      'Tap + Add to create your first destination.';

  @override
  String error(String errorDetail) {
    return 'Error: $errorDetail';
  }

  @override
  String helloName(String name) {
    return 'Hello, $name';
  }

  @override
  String get analyticsOverview => 'TravelEase analytics overview';

  @override
  String get summary => 'Summary';

  @override
  String get destinations => 'Destinations';

  @override
  String get users => 'Users';

  @override
  String get favorites => 'Favorites';

  @override
  String get destinationsByCategory => 'Destinations by category';

  @override
  String get barChart => 'Bar chart';

  @override
  String get recentReviews => 'Recent reviews';

  @override
  String get noReviewsYet => 'No reviews yet.';

  @override
  String get noComment => 'No comment';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get authErrorDetailFallback =>
      'If this keeps happening, try email sign-in or contact support.';

  @override
  String get logoutSuccessTitle => 'Logged out successfully';

  @override
  String get logoutSuccessDesc =>
      'You have been logged out. See you next time!';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmDesc => 'You will be returned to the login screen.';

  @override
  String get skip => 'Skip';

  @override
  String get back => 'Back';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get onboardingTitle1 => 'Discover Amazing Destinations';

  @override
  String get onboardingSubtitle1 =>
      'Explore the best places across Indonesia with stunning photos and details.';

  @override
  String get onboardingTitle2 => 'Plan Your Perfect Journey';

  @override
  String get onboardingSubtitle2 =>
      'Find locations on the map and navigate with Google Maps in one tap.';

  @override
  String get onboardingTitle3 => 'Save Favorites and Share Reviews';

  @override
  String get onboardingSubtitle3 =>
      'Bookmark trips you love and help others with honest reviews.';

  @override
  String get aiScanner => 'AI Scanner';

  @override
  String get favoriteRemoved => 'Favorite removed successfully';

  @override
  String get favoriteAdded => 'Favorite added successfully';

  @override
  String get scrollDownReview => 'Scroll down to write a review';

  @override
  String get maps => 'Maps';

  @override
  String get freeTicket => 'Free / N/A';

  @override
  String get noDescription => 'No description available for this destination.';

  @override
  String reviewsCount(num count) {
    return '$count reviews';
  }

  @override
  String get noReviewsCount => 'No reviews yet';

  @override
  String couldNotOpenMap(String error) {
    return 'Could not open map: $error';
  }

  @override
  String get scannerTitleActive => 'Travel AI Scanner Active';

  @override
  String get scannerTitlePaused => 'Travel AI Scanner Paused';

  @override
  String objectsCount(num count) {
    return '$count objects';
  }

  @override
  String get voice => 'Voice';

  @override
  String get speed => 'Speed';

  @override
  String get conf => 'Conf';

  @override
  String get voiceSpeedLabel => 'Voice speed';

  @override
  String get voiceCooldownLabel => 'Voice repetition interval';

  @override
  String get sensitivityLabel => 'Sensitivity detection';

  @override
  String get startScan => 'Start Scan';

  @override
  String get stopScan => 'Stop Scan';

  @override
  String get detectedResult => 'Detected Result';

  @override
  String get confidence => 'Confidence';

  @override
  String get origin => 'Origin';

  @override
  String get landmarkInfo => 'Landmark Info';

  @override
  String get foodInfo => 'Food Info';

  @override
  String get locationLabel => 'Location';

  @override
  String get originLabel => 'Origin';

  @override
  String get descriptionLabel => 'Description';
}
