/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./layouts/**/*.html"],
  theme: {
    colors: {
      main: {
        light: "#cecbef",
        dark: "#4b0082",
      },
    },
    extend: {
      typography: {
        quoteless: {
          css: {
            "blockquote p:first-of-type::before": { content: "none" },
            "blockquote p:first-of-type::after": { content: "none" },
            "code::before": { content: "none" },
            "code::after": { content: "none" },
            "> ul > li > input:first-child": {
              marginTop: 0,
            },
            "> ul > li > input:last-child": {
              marginBottom: 0,
            },
            "> ol > li > input:first-child": {
              marginTop: 0,
            },
            "> ol > li > input:last-child": {
              marginBottom: 0,
            },
          },
        },
      },
    },
  },
  plugins: [require("postcss-import"), require("@tailwindcss/typography")],
};
