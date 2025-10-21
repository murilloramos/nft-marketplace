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
  return <div>NavBar</div>
}

export default NavBar