// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Internal imports for the openzeppelin dependecies:
// import "@openzeppelin/contracts/utils/Counters.sol"; -> Counters.sol has been removed
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    uint256 private _tokenIds;
    uint256 private _itemsSold;

    uint256 listingPrice = 0.0025 ether;

    address payable owner;

    // Every NFT will have a ID that will be passed into this mapping
    mapping(uint256 => MarketItem) private idMarketItem;

    // Struct that will store every details about a particular NFT
    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // Will be triggered whenever a transaction is made
    event MarketItemCreated (
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    ); 

    // This modifier will make sure that only the owner can cann the updateListingPrice function
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner of the contract of the Marketplace can change the listing price");
        _; // --> Once this modifier = true the rest of the function will continue
    }

    // Here it will be defined the symbol and the name of the NFT 
    constructor() ERC721("NFT Metaverse Token", "MYNFT") {
        owner == payable(msg.sender); // Whoever deploy the smart contract will be the owner
    }

    function updateListingPrice(uint256 _listingPrice) public payable onlyOwner {
        // This function should be only called by the owner of the smart contract
        listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    // Function that will allow to create a NFT (In the context of NFTs, URI stands for Uniform Resource Identifier. It is a unique address that points to the metadata associated with the NFT)
    function createToken(string memory tokenURI, uint256 price) public payable returns (uint256) {
        _tokenIds++;

        uint256 newTokenId = _tokenIds;

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        createMarketItem(newTokenId, price);

        return newTokenId;
    }

    // Function to create a market item
    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be at least 1");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        idMarketItem[tokenId] = MarketItem (
            tokenId,
            payable(msg.sender), // Here it will be the one that will call the function
            payable(address(this)), // Here the NFT or the money belongs to the contract itself (address(this) means the Smart Contract)
            price,
            false // Currently the NFT is not sold so we have to put this to false
        );

        _transfer(msg.sender, address(this), tokenId); // Here the tokenId variable contains the entire information/data of the NFT

        emit MarketItemCreated(tokenId, msg.sender, address(this), price, false);
    }

    // Function to resale the token
    function reSellToken(uint256 tokenId, uint256 price) public payable {
        require(idMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation"); // All the data of the NFT is inside the "idMarketItem", and here we are checking who is the owner of the particular NFT, so it needs to be the same person that is calling the function

        require(msg.value == listingPrice, "Price must be equal to listing price");

        idMarketItem[tokenId].sold = false;
        // Purpose = Marks the NFT as "avaiable for sale" again
        // Why? When reselling, you're making the token avaiable on the marketplace, so it will no longer be in "sold" state

        idMarketItem[tokenId].price = price;
        // Purpose = Sets the new asking price for the resale
        // Why? The owner specifies a new price at which they want to sell the NFT this time

        idMarketItem[tokenId].seller = payable(msg.sender);
        // Purpose = Updates the seller to the current function caller
        // Why? The person reselling the token becomes the new seller who will receive payament when the NFT sells

        idMarketItem[tokenId].owner = payable(address(this));
        // Purpose = Transfer ownership back to the marketplace contract
        // Why? This is crucial because it moves the NFT from the users's wallet back to the marketplace escrow, making it avaiable for purchase by others

        _itemsSold--;

        _transfer(msg.sender, address(this), tokenId);
    }

    // Function that will create market sale
    function createMarketSale(uint256 tokenId) public payable {
        uint256 price = idMarketItem[tokenId].price; // Here we are getting the price of a particular NFT (based on his Id)

        require(msg.value == price, "Please submit the asking price in order to complete the purchase"); // If someone wants to buy this NFT they have to provide the exact price of the NFT for making the sale

        idMarketItem[tokenId].owner = payable(msg.sender); // Whoever is calling the function will become the owner once he made the payment
        idMarketItem[tokenId].sold = true; // NFT gets solded
        idMarketItem[tokenId].owner = payable(address(0)); // This NFT  will not belong to the contract anymore

        _itemsSold++;

        _transfer(address(this), msg.sender, tokenId);

        payable(owner).transfer(listingPrice); // Here it will get the comission whenever every sales happen that will be avaiable in the owner address (the owner of the Marketplace, the address that will run the Smart Contract into the blockchain)
        payable(idMarketItem[tokenId].seller).transfer(msg.value); // Here the rest amount will be transfered to the NFT owner
    }

    // Getting unsold NFT data (this will return a list of all the NFTs that are currently available for purchase)
    function fetchMarketItem() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenIds; // How many NFTs exists inside the NFT Marketplace
        uint256 unsoldItemCount = _tokenIds - _itemsSold; // How many NFTs are currently avaiable for sale
        uint256 currentIndex = 0; // We will use this variable to keep track of the position in our new "items" array as we add unsold NFTs to it

        // Inside this array will be stored unsold NFTs
        MarketItem[] memory items = new MarketItem[](unsoldItemCount); // We want to fetch only those NFTs which are NOT sold, so it can be possible to display on the frontend application (This line creates that empty "display counter". We are preparing an array (a list) that is just the right size to hold all our unsold items)

        // So we are creating a new array in memory called "items". Its size is exactly "unsoldItemCount" (which was 7 in our example),  we now have an empty list with 7 slots ready to be filled.
        for (uint256 i = 0; i < itemCount; i++) { // This will go through every single NFT we've ever created, one by one, starting from the first one (index 0) up to the last one
            if(idMarketItem[i + 1].owner == address(this)) { // This is the most important check! For each NFT we look at, we ask: "Is this NFT currently owned by the marketplace contract itself?"

            // In our marketplace logic, when an NFT is for sale, its owner is set to address(this) (the contract's own address). When it's sold, the owner is changed to the buyer's address. So, if the owner is the contract, it means the NFT is UNSOLD and available for purchase

                uint256 currentId = i + 1; // This just calculates the actual NFT ID from the loop index. If i is 0, then currentId is 1 (the first NFT)

                MarketItem storage currentItem = idMarketItem[currentId]; // This will return the complete information about the unsold NFT that we just sorted out
                items[currentIndex] = currentItem; // This is where we put the unsold NFT onto our "display counter" (the items array)
                currentIndex += 1;
            }
        }
        return items; // We've looked at every single NFT. Now our items array is filled with all the unsold ones. This line sends that finished list back to whoever called the function (like your website's frontend)
    }

    // Purchase item function
    function fetchMyNFT() public view returns (MarketItem[] memory) {
        uint256 totalCount = _tokenIds;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalCount; i++) {
            if(idMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }
        
        MarketItem[] memory items = new MarketItem[] (itemCount);
        for (uint256 i = 0; i < totalCount; i++) {

            if (idMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
       }
       return items;  
   }
   
   // Single user item - displaying the information of the NFT individually
   function fetchItemsListed() public view returns(MarketItem[] memory) {
        uint256 totalCount = _tokenIds;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for(uint256 i = 0; i < totalCount; i++) {
            if(idMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalCount; i++) {
            if (idMarketItem[i + 1].seller == msg.sender) {
                uint256 currentId = i + 1;

                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
   }
}
