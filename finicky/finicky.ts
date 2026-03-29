export default {
  defaultBrowser: "Arc",
  handlers: [
    {
      match: ["https://docs.google.com/*", "https://calendar.google.com/*", "https://mail.google.com/*", "https://drive.google.com/*"],
      browser: "Google Chrome"
    },
    {
      match: /^https?:\/\/meet\.google\.com\//,
      browser: (url) => ({
        name: "Google Chrome",
        profile: "Default",
        args: [
          "--app-id=kjgfgldnnfoeklkmfkjfagphfepbbdan",
          `--app-launch-url-for-shortcuts-menu-item=${url.toString()}`
        ]
      })
    }
  ]
}
