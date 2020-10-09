Notes.

Graphical design.
- there is no special graphical design applied - it depends on customer's preferences and usually is provided by a separate team/graphic designer

City pictures.
- not all city pictures are available on server due to lack of time to prepare it.
- pictures are cached in document folder; so when picture is already downloaded, it is not downloaded again;
- due to assumed cache policy a new picture can be downloaded again (renewed) after app reinstall;
- there are various possibilities here to implement, e.g. checking picture signature on server and download/or not based on this info
- city pictures can be available in 2 resolutions - depending where they need to be used; for table view lower resolution (so smaller file size) would be better (faster download); for detailed screen full (apropriate) resultion can be used;

Setup Apperance.
- it is done now in AppDelegate by call to static utils method, however is some cases it can be more convenient to define category (extension) on a given UI class and call the method from the category. This is especially useful when more than just one style customization is needed.

LaunchScreen.
- due to lack of time it is left almost empty. There should be a splash screen designed.

Localization.
- there is strings Localization initialized - so all displayable in user interface strings are localized
- due to time shortage - only one localized file has been prepared (English)

Constants.
- global constants like url addresses, colors, etc are put to a separated module

Unit tests.
- due to lack of time I focused on more complicated tests of asynchronous tasks and delegates.
- simpler UT and UI tests should be added

Further considerations:
- optimize city image loading not to load all at once, but to load in portions based on "cellVisibility" property
