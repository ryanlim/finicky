# Opening links in a specific Safari profile

Safari has no API or command-line flag for choosing a profile, but it can be told
to open a given website in a given profile. This recipe uses that: Finicky rewrites
a link to a local hostname (one per profile), Safari opens that hostname in the
matching profile, and a tiny local page forwards the browser to the real URL.

```
Finicky rewrite ──▶ http://work.finicky.test:48731/#<encoded url>
                      │  Safari opens it in the "Work" profile
                      ▼
              local server returns redirect.html ──▶ JS sends the tab to <url>
```

Nothing leaves your machine: the server listens on `127.0.0.1` only, and the
target URL lives in the `#fragment`, which browsers never send to a server.

This is based on the idea in
[discussion #531](https://github.com/johnste/finicky/discussions/531), run locally.

## Setup

1. **Start the redirect server** (launchd user agent, default port 48731):

   ```sh
   ./install.sh
   ```

   This copies `server.py` and `redirect.html` to `~/.finicky-helper` (override with
   `FINICKY_HELPER_DIR`) and runs the copy with `/usr/bin/python3`, so this
   directory isn't needed afterwards. Re-run it to update. To use another port,
   change it in the installed plist and in `finicky.config.js`.

2. **Add a hostname per profile to `/etc/hosts`** (needs `sudo`):

   ```
   127.0.0.1  work.finicky.test  personal.finicky.test
   ```

   `.test` is reserved for local use. Avoid `.local`, which macOS sends to mDNS.
   If a name doesn't resolve right away: `sudo dscacheutil -flushcache`.

3. **Assign each hostname to a profile in Safari.** In Safari's settings, set
   `work.finicky.test` to open in your Work profile, and so on. Where this lives
   depends on your Safari version, so look in the profile settings.

4. **Add rewrite rules to your Finicky config**, see `finicky.config.js`:

   ```js
   const route = (profile) => (url) =>
     `http://${profile}.finicky.test:48731/#${encodeURIComponent(url.href)}`;

   export default {
     defaultBrowser: "Safari",
     rewrite: [{ match: "github.com/my-work-org/*", url: route("work") }],
   };
   ```

   Use `http://`, not `https://`: there is no certificate for these names.

## Notes and limits

- Only `http` and `https` targets are forwarded; anything else shows an error.
- A link makes one extra hop through the local page, and fails if the server is
  down. launchd restarts it (`KeepAlive`).
- It routes by hostname, so each profile needs its own entry in `/etc/hosts` and
  its own assignment in Safari.
- Untested assumption: Safari's domain-to-profile rule matches on host and ignores
  the port. If links open in the wrong profile, serve on port 80 instead (needs root).

## Uninstall

```sh
launchctl bootout gui/$(id -u)/se.johnste.finicky.safari-profiles
rm ~/Library/LaunchAgents/se.johnste.finicky.safari-profiles.plist
rm -r ~/.finicky-helper
```

Then remove the lines you added to `/etc/hosts`.
