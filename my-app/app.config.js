const appJson = require("./app.json");
require("dotenv").config();

module.exports = () => {
  const base = appJson.expo;
  return {
    ...base,
    extra: {
      ...(base.extra || {}),
      GEMINI_API_KEY: process.env.GEMINI_API_KEY || "",
    },
  };
};