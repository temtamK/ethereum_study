pragma solidity ^0.8.18;

// // Auction wrapper functions
import "./kitty-minting.sol";

/// @title CryptoKitties: Collectible, breedable, and oh-so-adorable cats on the Ethereum blockchain.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev The main CryptoKitties contract, keeps track of kittens so they don't wander around and get lost.
contract KittyCore is KittyMinting {
    // This is the main CryptoKitties contract. In order to keep our code seperated into logical sections,
    // we've broken it up in two ways. First, we have several seperately-instantiated sibling contracts
    // that handle auctions and our super-top-secret genetic combination algorithm. The auctions are
    // seperate since their logic is somewhat complex and there's always a risk of subtle bugs. By keeping
    // them in their own contracts, we can upgrade them without disrupting the main contract that tracks
    // kitty ownership. The genetic combination algorithm is kept seperate so we can open-source all of
    // the rest of our code without making it _too_ easy for folks to figure out how the genetics work.
    // Don't worry, I'm sure someone will reverse engineer it soon enough!
    //
    // Secondly, we break the core contract into multiple files using inheritence, one for each major
    // facet of functionality of CK. This allows us to keep related code bundled together while still
    // avoiding a single giant file with everything in it. The breakdown is as follows:
    //
    //      - KittyBase: This is where we define the most fundamental code shared throughout the core
    //             functionality. This includes our main data storage, constants and data types, plus
    //             internal functions for managing these items.
    //
    //      - KittyAccessControl: This contract manages the various addresses and constraints for operations
    //             that can be executed only by specific roles. Namely CEO, CFO and COO.
    //
    //      - KittyOwnership: This provides the methods required for basic non-fungible token
    //             transactions, following the draft ERC-721 spec (https://github.com/ethereum/EIPs/issues/721).
    //
    //      - KittyBreeding: This file contains the methods necessary to breed cats together, including
    //             keeping track of siring offers, and relies on an external genetic combination contract.
    //
    //      - KittyAuctions: Here we have the public methods for auctioning or bidding on cats or siring
    //             services. The actual auction functionality is handled in two sibling contracts (one
    //             for sales and one for siring), while auction creation and bidding is mostly mediated
    //             through this facet of the core contract.
    //
    //      - KittyMinting: This final facet contains the functionality we use for creating new gen0 cats.
    //             We can make up to 5000 "promo" cats that can be given away (especially important when
    //             the community is new), and all others can only be created and then immediately put up
    //             for auction via an algorithmically determined starting price. Regardless of how they
    //             are created, there is a hard limit of 50k gen0 cats. After that, it's all up to the
    //             community to breed, breed, breed!

    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    /// @notice Creates the main CryptoKitties smart contract instance.
    function KittyCore() public {
        //// Pausable 컨트랙트의 _pause()로 대체
        // Starts paused.
        // paused = true;
        _pause();

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;

        //// 더이상 타입의 언더, 오버플로우를 활용할 수 없기 때문에 type(uint256).max로 uint256의 최대값을 구한다.
        //// creatKitty를 구현할 때 _safeMint()를 사용했는데, _safeMint()에서는 0번 주소로 토큰을 발행할 수 없도록 예외처리를 했기 때문에 dead 주소로 변경한다.
        // start with the mythical kitten 0 - so we don't have generation-0 parent issues
        // _createKitty(0, 0, 0, uint256(-1), address(0));
        _createKitty(
            0,
            0,
            0,
            type(uint256).max,
            address(0x000000000000000000000000000000000000dEaD),
        );
    }

    /// @dev Used to mark the smart contract as upgraded, in case there is a serious
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    function setNewAddress(address _v2Address) public onlyCEO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        //// 이벤트 발생을 위한 emit 키워드 추가
        emit ContractUpgrade(_v2Address);
    }

    //// 이더를 받기 위해 존재했던 함수를 receive()로 문법 업데이트
    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here, unless it's from one of the
    ///  two auction contracts. (Hopefully, we can prevent user accidents.)
    // function() external payable {
    //     require(
    //         msg.sender == address(saleAuction) ||
    //             msg.sender == address(siringAuction)
    //     );
    // }
    receive() external payable {
        require(
            msg.sender == address(saleAuction)
            //// siringAution 생략으로 삭제
            // || msg.sender == address(siringAuction)
        );
    }

    /// @notice Returns all the relevant information about a specific kitty.
    /// @param _id The ID of the kitty of interest.
    function getKitty(
        uint256 _id
    )
        public
        view
        returns (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        )
    {
        Kitty storage kit = kitties[_id];

        // if this variable is 0 then it's not gestating
        isGestating = (kit.siringWithId != 0);
        //// now는 deprecated 됐기 때문에 block.timestamp으로 변경
        // isReady = (kit.cooldownEndTime <= now);
        isReady = (kit.cooldownEndTime <= block.timestamp);
        cooldownIndex = uint256(kit.cooldownIndex);
        nextActionAt = uint256(kit.cooldownEndTime);
        siringWithId = uint256(kit.siringWithId);
        birthTime = uint256(kit.birthTime);
        matronId = uint256(kit.matronId);
        sireId = uint256(kit.sireId);
        generation = uint256(kit.generation);
        genes = kit.genes;
    }

    //// unpause() 함수는 KittyAccessControl 컨트랙트의 unpause()를 override하여 의미 확장 하는 것이기에 override 타입 지정
    //// 추후에 다시 override 할 수 있기 때문에 virtual 타입 지정
    //// whenPaused modifier는 Pausalbe의 _unpause()에 지정돼 있으므로 생략
    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    function unpause() public override virtual onlyCEO {
        //// type 맞춤
        require(address(saleAuction) != address(0));
        //// 구현 X
        // require(siringAuction != address(0));
        // require(geneScience != address(0));
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }
}
