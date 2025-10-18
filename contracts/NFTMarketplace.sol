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
        uint256 price = idMarketItem[tokenId].price;

        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        idMarketItem[tokenId].owner = payable(msg.sender);
        idMarketItem[tokenId].sold = true;
        idMarketItem[tokenId].owner = payable(address(0));

        _itemsSold--;
    }
}
