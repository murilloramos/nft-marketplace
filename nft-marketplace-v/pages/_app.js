// What is this file?
// _app.js is a special file in Next.js because it will act as a "wrapper" for all the pages inside the web application. Every page component in the app will get rendered inside the "MyApp" component

import "@/styles/globals.css";

// Internal global import of NavBar and Footer, they will be in every single page in the entire application

import { NavBar } from "@/components/componentsindex";

const MyApp = ({ Component, pageProps }) => (
    <div>
        <NavBar />
        <Component {...pageProps} />
    </div>
)

export default MyApp
