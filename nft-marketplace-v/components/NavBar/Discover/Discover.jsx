import React from 'react'
import Link from 'next/link'

// Internal Imports
import Style from './Discover.module.css'

const Discover = () => {

    //========= Discover Navigation Menu =========
    // Inside the below array we will have an object of every single menu
    const discover = [
        {
            name: "Collection",
            link: "collection"
        },
        {
            name: "Search",
            link: "search"
        },
        {
            name: "Author Profile",
            link: "author-profile"
        },
        {
            name: "NFT Details",
            link: "nft-details"
        },
        {
            name: "Account Setting",
            link: "account-setting"
        },
        {
            name: "Connect Wallet",
            link: "connect-wallet"
        },
        {
            name: "Blog",
            link: "blog"
        }
    ]
    return (
        <div>
            {discover.map((el, i) => (
                <div key = {i + 1} className = {Style.discover}>
                    <Link href = {{pathname: `${el.link}`}}/>
                </div>
            ))}
        </div>
    )
}

export default Discover