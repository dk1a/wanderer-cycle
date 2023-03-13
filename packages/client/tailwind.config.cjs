/** @type {import('tailwindcss').Config} */

module.exports = {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        curiousBlue: {
          '600': '#228ce9',
          '700': '#1e78d7',
          '800': '#1f60ae',
          '900': '#1f5189',
        },
        dark: {
          200: '#cccccc', // lighter text
          300: '#969696', // darker text
          400: '#3c3c3c', // outer ui
          500: '#252526', // ui
          600: '#1e1e1e', // back
          key: '#9cdcfe',
          //enum: '#4fc1ff',
          keyword: '#569cd6',
          number: '#b5cea8',
          string: '#ce9178',
          method: '#dcdcaa',
          type: '#4ec9b0',
          control: '#c586c0',
          comment: '#6a9955',
          highlight: '#202a34'
        }
      },
    },
  },
  plugins: [],
};
