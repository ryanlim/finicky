// Route links to Safari profiles through local hostnames.
// See README.md for the one-time /etc/hosts and Safari setup.
const PORT = 48731; // must match FINICKY_HELPER_PORT used with install.sh
const route = (profile) => (url) =>
  `http://${profile}.finicky.test:${PORT}/#${encodeURIComponent(url.href)}`;

export default {
  defaultBrowser: "Safari",
  rewrite: [
    { match: "github.com/my-work-org/*", url: route("work") },
    { match: "*.example.com/*", url: route("personal") },
  ],
};
