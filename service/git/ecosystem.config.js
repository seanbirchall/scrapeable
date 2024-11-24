// ecosystem.config.js.template
module.exports = {
    apps: [{
      name: "git-github-webhook",
      script: "index.js",
      cwd: "/var/www/html/scrapeable/service/git",
      env: {
        NODE_ENV: "production"
      },
      watch: true,
      max_memory_restart: '50M'
    }]
  };