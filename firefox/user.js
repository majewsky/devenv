// disable "New Tab" page
user_pref("browser.startup.page", 0); //blank page
user_pref("browser.startup.homepage", "about:blank");
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.newtab.preload", false);

//do not suggest open tabs as an autocomplete option
user_pref("browser.urlbar.suggest.openpage", false);

//always ask where to store downloaded files
user_pref("browser.download.useDownloadDir", false);
user_pref("browser.download.lastDir", "/home/stefan/Downloads");

//restrict events that can open popup windows
user_pref("dom.popup_allowed_events", "click dblclick pointerup submit");

//block all third-party cookies
user_pref("network.cookie.cookieBehavior", 1);

//clear most state on shutdown
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("privacy.clearOnShutdown.cache", true);
user_pref("privacy.clearOnShutdown.cookies", true);
user_pref("privacy.clearOnShutdown.downloads", true);
user_pref("privacy.clearOnShutdown.formdata", true);
user_pref("privacy.clearOnShutdown.history", false); // KEEP browsing history
user_pref("privacy.clearOnShutdown.offlineApps", true);
user_pref("privacy.clearOnShutdown.sessions", true);
user_pref("privacy.clearOnShutdown.siteSettings", false); // KEEP site preferences

//no thanks
user_pref("layout.spellcheckDefault", 0);

//no autoplay, even after mouse gestures
user_pref("media.autoplay.enabled", false);
user_pref("media.autoplay.enabled.user-gestures-needed", false);
user_pref("media.autoplay.default", 5); // 5 = block all autoplay

////////////////////////////////////////////////////////////////////////////////
// locale settings

user_pref("browser.search.region", "DE");
user_pref("intl.accept_languages", "en-US, en");
//respect LC_TIME <https://bugzilla.mozilla.org/show_bug.cgi?id=1464592>
user_pref("intl.regional_prefs.use_os_locales", true);

////////////////////////////////////////////////////////////////////////////////
// privacy (explanations for these are in
// <https://github.com/ghacksuserjs/ghacks-user.js/blob/master/user.js>)

user_pref("browser.search.geoip.url", "");
user_pref("browser.search.geoSpecificDefaults", false);
user_pref("browser.search.geoSpecificDefaults.url", "");
user_pref("browser.search.update", false);

user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("browser.discovery.enabled", false);

user_pref("app.shield.optoutstudies.enabled", false);

user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.available", "off");
user_pref("extensions.formautofill.creditCards.enabled", false);
user_pref("extensions.formautofill.heuristics.enabled", false);

user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.dns.disablePrefetchFromHTTPS", true);
user_pref("network.predictor.enabled", false);
user_pref("network.predictor.enable-prefetch", false);
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("browser.send_pings", false);
user_pref("browser.send_pings.require_same_host", true);

user_pref("keyword.enabled", false);
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.suggest.searches", false);

user_pref("browser.fixup.alternate.enabled", false);
user_pref("browser.urlbar.trimURLs", false);
user_pref("layout.css.visited_links_enabled", false);
user_pref("browser.urlbar.usepreloadedtopurls.enabled", false);
user_pref("browser.urlbar.speculativeConnect.enabled", false);

user_pref("browser.formfill.enable", false);
user_pref("signon.autofillForms", false);

user_pref("browser.cache.disk.enable", false);
user_pref("browser.sessionstore.privacy_level", 2);
user_pref("browser.sessionstore.resume_from_crash", false);

user_pref("security.ssl.require_safe_negotiation", true);
user_pref("security.tls.version.min", 3); // 3 = TLS 1.2
user_pref("security.ssl.disable_session_identifiers", true);
user_pref("security.tls.enable_0rtt_data", false);
user_pref("security.OCSP.require", true);

//would like to have `security.mixed_content.block_display_content = true`,
//but it breaks too much stuff
user_pref("security.mixed_content.upgrade_display_content", true);

//note to self: limiting the Referer may break some sites - this sends a full
//Referer, but only for same domain
user_pref("network.http.referer.XOriginPolicy", 1);
user_pref("network.http.referer.XOriginTrimmingPolicy", 0);
user_pref("privacy.donottrackheader.enabled", true);

user_pref("media.gmp-widevinecdm.visible", false);
user_pref("media.gmp-widevinecdm.enabled", false);
user_pref("media.eme.enabled", false);

user_pref("dom.event.clipboardevents.enabled", false);
user_pref("dom.allow_cut_copy", false);

user_pref("dom.targetBlankNoOpener.enabled", true);

user_pref("accessibility.force_disabled", 1);
user_pref("beacon.enabled", false);

user_pref("browser.cache.offline.enable", false);
user_pref("offline-apps.allow_by_default", false);

//note to self: disabled now because of too many annoyances (being forced into
//UTC timezone, being forced into light mode, etc.; arkenfox/user.js has full
//list of restrictions in a comment)
user_pref("privacy.resistFingerprinting", false);

