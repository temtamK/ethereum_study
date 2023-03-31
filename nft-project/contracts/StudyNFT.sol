// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract StudyNFT is ERC721 {
    constructor() ERC721("StudyNFT", "STUDY") {
        for (uint i = 0; i < 10; i++) {
            _safeMint(msg.sender, i + 1);
        }
    }
}