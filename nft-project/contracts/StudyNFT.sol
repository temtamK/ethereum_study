// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StudyNFT is ERC721, Ownable {
  uint256 totalSupply;
  bool isSaleActive;
  uint256 MAX_SUPPLY = 100;

  constructor() ERC721("StudyNFT", "STUDY") {}

  function _baseURI() internal view override returns (string memory) {
      return "ipfs://Qmd3cY6wnjEUFtUCP3R9M9vxyJKqsiZNxoAWhXR3YHiqxM";
  }

  function setSale(bool active) external onlyOwner {
      isSaleActive = active;
  }

  function mintPlanet(uint256 count) external payable {
    require(isSaleActive, "Sale is not active");
    require(msg.value >= 0.001 ether * count, "Insufficient ETH");
    require(count <= 10, "Can mint max 10 planets at a time");

    for (uint i = 0; i < count; i++) {
        require(totalSupply < MAX_SUPPLY, "Max supply reached");
        _safeMint(msg.sender, totalSupply++);
    }
  }

  function withdraw() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }
}
