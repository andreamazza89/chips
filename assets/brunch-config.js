exports.config = {
  files: {
    javascripts: {
      joinTo: "js/app.js"
    },
    stylesheets: {
      joinTo: "css/app.css"
    }
  },

  conventions: {
    assets: /^(static)/
  },

  paths: {
    watched: ["css", "elm", "js"],
    public: "../priv/static"
  },

  plugins: {
    babel: {
      ignore: [/vendor/]
    },

    elmBrunch: {
      elmFolder: "elm",
      executablePath: '../node_modules/elm/binwrappers',
      mainModules: ["Main.elm"],
      outputFolder: "./compiled",
    },
  },

  modules: {
    autoRequire: {
      "js/app.js": ["js/app"]
    }
  }
};
