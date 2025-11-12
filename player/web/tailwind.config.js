/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{html,js,ts,jsx,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        sans: ['"Onest Variable", sans-serif'],
        oswald: ['"Oswald Variable", sans-serif'],
      },
      colors: {
        primary: "#ffcc03",
      },
    },
  },
  plugins: [],
};
