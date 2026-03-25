// Firefox profile overrides for privacy and a quieter default UI.

// Load custom CSS from chrome/userChrome.css and chrome/userContent.css.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Privacy and telemetry.
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");
user_pref("browser.ping-centre.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("browser.crashReports.unsubmittedCheck.enabled", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("browser.discovery.enabled", false);

// Quiet down Firefox surfaces that tend to leak usage data or add clutter.
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.urlbar.quicksuggest.sponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.suggest.searches", false);

// Privacy defaults.
user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("dom.security.https_only_mode", true);
user_pref("dom.security.https_only_mode_ever_enabled", true);

// Convenience.
user_pref("browser.toolbars.bookmarks.visibility", "always");
user_pref("browser.ctrlTab.sortByRecentlyUsed", false);
user_pref("middlemouse.paste", false);
