# NextBus - Find the next transit in Berlin without interaction.
- Simple app to find the relevant departures from your current location.
- Build only for Berlin transit.
- Uses BVG API as described in https://github.com/derhuerst/bvg-rest/blob/2/docs/index.md
- Uses Flutter to build both iOS and Android app.

 ## Build
 - Read Flutter documentation on how to install Flutter and configure your IDE - https://flutter.dev/docs/get-started/
 - Clone the repository.
 - Run `flutter pub get` to install packages used in the projects.
 - Open Android studio and run on any simulator or device.

<img src="documentation/departure_list.png" width="250" />
<img src="documentation/android_departure_list.png" width="250" />

## Possible Future Improvements
- Ability to save locations to access easily (see design files).
- Ability to pin a transit route as favorite so it shows up on top of the list if it's one of the departure options.
- Better error handling to ensure user is notified if the API is failing.
- Preferences to switch between metric and imperial units.
- Multiple language support (starting with German).
- Basic tests for the UI, API, and models.
