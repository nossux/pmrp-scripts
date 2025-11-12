/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{html,js,ts,jsx,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        sans: ['"Onest Variable", sans-serif'],
        heading: ['"Akzid Gro Pro", sans-serif'],
      },
      colors: {
        primary: '#38b6ff'
      }
    },
  },
  plugins: [],
}
