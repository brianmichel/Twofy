const defaultTheme = require('tailwindcss/defaultTheme')
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{html,js}"],
  theme: {
    screens: {
      'xs': '475px',
      ...defaultTheme.screens,
    },
    keyframes: {
      'code-reveal': {
        '0%': { content: "•••" },
        '100%': { content: '2FA)' },
      }
    },
    animation: {
      'code-reveal': 'code-reveal 3s linear infinite',
    }
  },
  plugins: [],
}
