module.exports = {
  apps: [{
    name: "auth-authentication",
    script: "index.js",
    cwd: "/var/www/html/scrapeable/service/git",
    env: {
      NODE_ENV: "production"
    },
    watch: true,
    watch_delay: 1000,        // Delay between restarts
    ignore_watch: [           // Ignore these files/folders
      "node_modules",
      "logs",
      ".git",
      "*.log"
    ],
    max_memory_restart: '200M',
    exp_backoff_restart_delay: 100,
    time: true
  }]
};