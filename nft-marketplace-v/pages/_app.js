// What is this file?
// _app.js is a special file in Next.js because it will act as a "wrapper" for all the pages inside the web application. Every page component in the app will get rendered inside the "MyApp" component

import "@/styles/globals.css";

const MyApp = ({ Component, pageProps }) => <Component {...pageProps} />

export default MyApp
