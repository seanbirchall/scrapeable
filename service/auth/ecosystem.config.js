module.exports = {
  apps: [{
    name: "auth-authentication",
    script: "index.js",
    cwd: "/var/www/html/scrapeable/service/auth",
    env: {
      NODE_ENV: "production",
      COGNITO_TOKEN_URL: process.env.COGNITO_TOKEN_URL,
      COGNITO_CLIENT_ID: process.env.COGNITO_CLIENT_ID,
      COGNITO_CLIENT_SECRET: process.env.COGNITO_CLIENT_SECRET
    },
    watch: true,
    watch_delay: 1000,        // Delay between restarts
    ignore_watch: [           // Ignore these files/folders
      "node_modules",
      "logs",
      ".git",
      "*.log"
    ],
    max_memory_restart: '750M',
    exp_backoff_restart_delay: 100,
    time: true
  }]
};