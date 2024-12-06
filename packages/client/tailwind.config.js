/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{html,js,jsx,ts,tsx}"],
  theme: {
    extend: {
      colors: {
        dark: {
          200: '#cccccc', // lighter text
          300: '#969696', // darker text
          400: '#3c3c3c', // outer ui
          500: '#252526', // ui
          600: '#1c1b1b', // back
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
}