// ecosystem.config.js.template
module.exports = {
    apps: [{
      name: "auth-authentication",
      script: "index.js",
      cwd: "/var/www/html/scrapeable/service/auth",
      env: {
        NODE_ENV: "production"
      },
      watch: true,
      max_memory_restart: '50M'
    }]
  };