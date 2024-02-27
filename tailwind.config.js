/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./layouts/**/*.html"],
  theme: {
    fontFamily: {
      mono: ["Iosevka", "monospace"],
      sans: ["Atkinson Hyperlegible", "sans-serif"],
    },
    colors: {
      main: {
        light: "#f6f6f6",
        dark: "#1f1f1f",
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
