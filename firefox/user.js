user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.download.alwaysOpenPanel", false);
user_pref("browser.download.always_ask_before_handling_new_types", false);
user_pref("browser.download.useDownloadDir", true);
user_pref("browser.fullscreen.autohide", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.safebrowsing.downloads.remote.enabled", true);
user_pref(
  "browser.startup.homepage",
  "file:///home/igor/projects/startpage/index.html"
);
user_pref("browser.tabs.inTitlebar", 1);
user_pref("browser.uidensity", 1);
user_pref("browser.urlbar.suggest.engines", true);
user_pref("dom.push.enabled", true);
user_pref("identity.fxaccounts.enabled", true);
user_pref("layout.css.prefers-color-scheme.content-override", 0);
user_pref("media.hardwaremediakeys.enabled", false);
user_pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);
user_pref("services.sync.declinedEngines", "creditcards,passwords");
user_pref("services.sync.engine.passwords", false);
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("gfx.webrender.all", true);
user_pref("browser.toolbars.bookmarks.visibility", "never");

///  NATURAL SMOOTH SCROLLING V4 "SHARP" - AveYo, 2020-2022             preset     [default]
///  copy into firefox/librewolf profile as user.js, add to existing, or set in about:config
user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12); //NSS    [120]
user_pref("general.smoothScroll.msdPhysics.enabled", true); //NSS  [false]
user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 200); //NSS   [1250]
user_pref("general.smoothScroll.msdPhysics.regularSpringConstant", 250); //NSS   [1000]
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS", 25); //NSS     [12]
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio", "2.0"); //NSS    [1.3]
user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant", 250); //NSS   [2000]
user_pref("general.smoothScroll.currentVelocityWeighting", "1.0"); //NSS ["0.25"]
user_pref("general.smoothScroll.stopDecelerationWeighting", "1.0"); //NSS  ["0.4"]

/// adjust multiply factor for mousewheel - or set to false if scrolling is way too fast
user_pref("mousewheel.system_scroll_override.horizontal.factor", 100); //NSS    [200]
user_pref("mousewheel.system_scroll_override.vertical.factor", 100); //NSS    [200]
user_pref("mousewheel.system_scroll_override_on_root_content.enabled", true); //NSS   [true]
user_pref("mousewheel.system_scroll_override.enabled", true); //NSS   [true]

/// adjust pixels at a time count for mousewheel - cant do more than a page at once if <100
user_pref("mousewheel.default.delta_multiplier_x", 100); //NSS    [100]
user_pref("mousewheel.default.delta_multiplier_y", 100); //NSS    [100]
user_pref("mousewheel.default.delta_multiplier_z", 100); //NSS    [100]

///  this preset will reset couple extra variables for consistency
user_pref("apz.allow_zooming", true); //NSS   [true]
user_pref("apz.force_disable_desktop_zooming_scrollbars", false); //NSS  [false]
user_pref("apz.paint_skipping.enabled", true); //NSS   [true]
user_pref("apz.windows.use_direct_manipulation", true); //NSS   [true]
user_pref("dom.event.wheel-deltaMode-lines.always-disabled", false); //NSS  [false]
user_pref("general.smoothScroll.durationToIntervalRatio", 200); //NSS    [200]
user_pref("general.smoothScroll.lines.durationMaxMS", 150); //NSS    [150]
user_pref("general.smoothScroll.lines.durationMinMS", 150); //NSS    [150]
user_pref("general.smoothScroll.other.durationMaxMS", 150); //NSS    [150]
user_pref("general.smoothScroll.other.durationMinMS", 150); //NSS    [150]
user_pref("general.smoothScroll.pages.durationMaxMS", 150); //NSS    [150]
user_pref("general.smoothScroll.pages.durationMinMS", 150); //NSS    [150]
user_pref("general.smoothScroll.pixels.durationMaxMS", 150); //NSS    [150]
user_pref("general.smoothScroll.pixels.durationMinMS", 150); //NSS    [150]
user_pref("general.smoothScroll.scrollbars.durationMaxMS", 150); //NSS    [150]
user_pref("general.smoothScroll.scrollbars.durationMinMS", 150); //NSS    [150]
user_pref("general.smoothScroll.mouseWheel.durationMaxMS", 200); //NSS    [200]
user_pref("general.smoothScroll.mouseWheel.durationMinMS", 50); //NSS     [50]
user_pref("layers.async-pan-zoom.enabled", true); //NSS   [true]
user_pref("layout.css.scroll-behavior.spring-constant", "250"); //NSS    [250]
user_pref("mousewheel.transaction.timeout", 500); //NSS   [1500]
user_pref("mousewheel.acceleration.factor", 3); //NSS     [10]
user_pref("mousewheel.acceleration.start", 0); //NSS     [-1]
user_pref("mousewheel.min_line_scroll_amount", 50); //NSS      [5]
user_pref("toolkit.scrollbox.horizontalScrollDistance", 5); //NSS      [5]
user_pref("toolkit.scrollbox.verticalScrollDistance", 3); //NSS      [3]
