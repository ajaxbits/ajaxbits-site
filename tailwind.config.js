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
        darkGrey: "#3d3d3d",
        lightGrey: "#c2c2c2",
      },
    },
    extend: {
      typography: ({ theme }) => ({
        DEFAULT: {
          css: {
            "--tw-prose-body": theme("colors.main.dark"),
            "--tw-prose-headings": theme("colors.main.dark"),
            "--tw-prose-links": theme("colors.main.dark"),
            "--tw-prose-bold": theme("colors.main.dark"),
            "--tw-prose-bullets": theme("colors.main.darkGrey"),
            "--tw-prose-hr": theme("colors.main.darkGrey"),

            "--tw-prose-invert-body": theme("colors.main.light"),
            "--tw-prose-invert-headings": theme("colors.main.light"),
            "--tw-prose-invert-links": theme("colors.main.light"),
            "--tw-prose-invert-bold": theme("colors.main.light"),
            "--tw-prose-invert-bullets": theme("colors.main.lightGrey"),
            "--tw-prose-invert-hr": theme("colors.main.lightGrey"),

            "blockquote p:first-of-type::before": { content: "none" },
            "blockquote p:first-of-type::after": { content: "none" },
            "code::before": { content: "none" },
            "code::after": { content: "none" },
            ".highlight div, .highlight pre": {
              overflowX: "auto",
            },
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
      }),
    },
  },
  plugins: [require("postcss-import"), require("@tailwindcss/typography")],
};
