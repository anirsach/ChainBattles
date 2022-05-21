// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct attributes {
        uint256 levels;
        uint256 hp;
        uint256 strength;
        uint256 speed;
    }

    mapping(uint256 => attributes) public tokenIdToLevels;

    //track levels
    //track hp
    //track strength
    //track speed

    constructor() ERC721("Chain Battles", "CBTLS") {}

    //Random number generator

    function random(uint256 _variation) private view returns (uint256) {
        return (uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.difficulty, _variation)
            )
        ) % 100);
    }

    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        attributes memory edit_attri = getLevels(tokenId);
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels: ",
            edit_attri.levels.toString(),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "HP: ",
            edit_attri.hp.toString(),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Strength ",
            edit_attri.strength.toString(),
            "</text>",
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Speed: ",
            edit_attri.speed.toString(),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getLevels(uint256 tokenId)
        public
        view
        returns (attributes memory)
    {
        attributes memory levels = tokenIdToLevels[tokenId];
        return levels;
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        attributes storage edit_attri = tokenIdToLevels[newItemId];
        edit_attri.levels = random(1);
        edit_attri.hp = random(2);
        edit_attri.strength = random(3);
        edit_attri.speed = random(4);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this NFT to train it!"
        );

        attributes storage edit_attributes = tokenIdToLevels[tokenId];
        edit_attributes.levels = edit_attributes.levels + 1;
        edit_attributes.hp = edit_attributes.hp + 1;
        edit_attributes.strength = edit_attributes.strength + 1;
        edit_attributes.speed = edit_attributes.speed + 1;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
