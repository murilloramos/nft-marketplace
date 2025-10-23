import React, {useState, useEffect} from 'react'
import Image from 'next/image'
import Link from 'next/link'

// Import Icons
import {MdNotifications} from 'react-icons/md'
import {BsSearch} from 'react-icons/bs'
import {CgMenuLeft, CgMenuRight} from 'react-icons/cg'

// Internal Import
import Style from './NavBar.module.css'
import {Discover, HelpCenter, Notification, Profile, SideBar} from './index'
import {Button} from "../componentsindex"
import images from "../../img"

const NavBar = () => {
  // Use State -> What is? "useStae" is a React hook allows adding state to functional components. So here this will be the memory of the component, and it will be changing over time and will affect what it will be shown in the screen

  const [discover, setDiscover] = useState(false) // -> So here "discover" is the stateVariable which will be the current value of the state, coming up with "setDiscover" that will be the setStateFunction that will update the state by a function, and finally with "useState(false)" which will be the starting value for the state

  // Why boolean state (false) for the menus
  // The purpose here is to control whether the "Discover" dropdown menu is visible or not, so:
  // discover is true -> Show Discover Menu
  // discover is false -> Hide Discover Menu
  // We will use setDiscover(true) to show, setDiscover(false) to hide
  const [help, setHelp] = useState(false)
  const [notification, setNotification] = useState(false)
  const [profile, setProfile] = useState(false)
  const [openSideMenu, setOpenSideMenu] = useState(false)

  const openMenu = (e) => {
    const btnText = e.target.innerText
    if (btnText == "Discover") {
      setDiscover(true)
      setHelp(false)
      setNotification(false)
      setProfile(false)

      // Whenever we click the Discover button, we have to put the rest of the navbar items to false because we only want to open one component not multiple components

    } else if (btnText == "Help Center") {
      setDiscover(false)
      setHelp(true)
      setNotification(false)
      setProfile(false)
    } else {
      setDiscover(false)
      setHelp(false)
      setNotification(false)
      setProfile(false)
    }
  }

  const openNotification = () => {
    if (!notification) {
      setNotification(true)
      setDiscover(false)
      setHelp(false)
      setProfile(false)
    } else {
     setNotification(false)
    }
  }

  return (
    <div className={Style.navBar}>
      <div className={Style.navbar_container}>
        <div className={Style.navbar_container_left}>  {/* The navigation will be divided in two parts: one is the lft section and the other one is the right section (this rule will be followed by all the components/jsx file) */}
          <div className={Style.logo}>
            <Image src={images.logo} alt='NFT MarketPlace' width={100} height={100}/>
          </div>
          <div className={Style.navbar_container_left_box_input}>
            <div className={Style.navbar_container_left_box_input_box}>
              <input type='text' placeholder='Search NFT'/>
              <BsSearch onClick={() => {}} className={Style.search_icon}/>
            </div>
          </div>
        </div>

        {/* End of the Left Section*/}
        <div className={Style.navbar_container_right}>
          <div className={Style.navbar_container_right_discover}>

            {/* Discover Menu */}
            <p onClick={(e) => openMenu(e)}>Discover</p> {/* Whenever somebody click the Discover component will open */}
            {discover && ( /* Since the discover state is initially false the component will not display, but if it turns it to true then it the entire component will display */
              <div className={Style.navbar_container_right_discover_box}>
                <Discover /> {/* Discover component */}
              </div>
            )}
          </div>

          {/* Help Center Menu */}
          <div className={Style.navbar_container_right_help}>
            <p onClick={(e) => openMenu(e)}>Help Center</p>
            {help && (
              <div className={Style.navbar_container_right_help_box}>
                <HelpCenter /> {/* HelpCenter component */}
              </div>
            )}
          </div>

          {/* Notification */}
          <div className={Style.navbar_container_right_notify}>
            <MdNotifications className={Style.notify} onClick={() => openNotification} />
              {notification && <Notification />}
          </div>

          {/* Creating Button Section */}
          <div className={Style.navbar_container_right_button}>
            <Button btnText = "Create"/>
          </div>

          {/* User Profile */}
          <div className={Style.navbar_container_right_profile_box}>
            <div className={Style.navbar_container_right_profile}>
              <Image src = {images.user1} 
              alt='Profile'
              width={40} 
              height={40} 
              onClick={() => openProfile()} 
              className={Style.navbar_container_right_profile}
              />

              {profile && <Profile />}
            </div>
          </div>

          {/* Menu Button */}
          <div className={Style.navbar_container_right_menuBtn}>
            <CgMenuRight className={Style.menuIcon}
              onClick={() => openSideBar()}
            />
          </div>
        </div>
      </div>
    </div> 
  )
}

export default NavBar