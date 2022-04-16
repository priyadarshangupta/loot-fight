// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ICharacter {
    function characterOwner(uint256 characterId) public returns (address);

    function getCharacterAttack(uint256 characterId) public returns (uint256);

    function getCharacterDefence(uint256 characterId) public returns (uint256);

    function getCharacterIntelligence(uint256 characterId) public returns (uint256);

    function getCharacterStrength(uint256 characterId) public returns (uint256);

    function getCharacterAgility(uint256 characterId) public returns (uint256);

    function getCharacterHealth(uint256 characterId) public returns (uint256);

    function getCharacterMagic(uint256 characterId) public returns (uint256);
}

/**
 * @dev {ERC721} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract ERC721PresetMinterPauserAutoId is
Context,
AccessControlEnumerable,
ERC721Enumerable,
ERC721Burnable,
ERC721Pausable
{
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    address constant CHARACTERS_CONTRACT = 0xBB9C1b15B16263C61d017ee9F65C50e4AE0113AA;

    Counters.Counter private _tokenIdTracker;
    Counters.Counter private _fightIdTracker;

    struct FightPrize {
        address nftAddress;
        uint256 nftId;
    }

    enum FightStatus {
        Uninitialized,
        Initialized,
        Accepted,
        Finished,
        PrizeCollected
    }

    struct Fight {
        uint256 id;
        uint256 c1Id;
        uint256 c2Id;
        uint256 winner;
        address c1Owner;
        address c2Owner;
        FightStatus status;
        FightPrize[] prizes;
    }

    mapping(uint256 => Fight) fights;

    string private _baseTokenURI;

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     * See {ERC721-tokenURI}.
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Creates a new token for `to`. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to pause");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(AccessControlEnumerable, ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function fightExists(uint256 fightId) public returns (bool) {
        Fight storage f = fights[fightId];
        return f.status == FightStatus.Uninitialized;
    }

    function ownerOfCharacter(uint256 characterId) internal view returns (bool) {
        return ICharacter(CHARACTERS_CONTRACT).characterOwner(characterId) == _msgSender();

    }

    function getCharacterAttack(uint256 characterId) public returns (uint256) {
        return ICharacter(CHARACTERS_CONTRACT).getCharacterAttack();
    }

    function getCharacterDefence(uint256 characterId) public returns (uint256) {
        return ICharacter(CHARACTERS_CONTRACT).getCharacterDefence();
    }

    function getCharacterIntelligence(uint256 characterId) public returns (uint256) {
        return ICharacter(CHARACTERS_CONTRACT).getCharacterIntelligence();
    }

    function getCharacterStrength(uint256 characterId) public returns (uint256) {
        return ICharacter(CHARACTERS_CONTRACT).getCharacterStrength();
    }

    function getCharacterAgility(uint256 characterId) public returns (uint256) {
        return ICharacter(CHARACTERS_CONTRACT).getCharacterAgility();
    }

    function getCharacterHealth(uint256 characterId) public returns (uint256) {
        return ICharacter(CHARACTERS_CONTRACT).getCharacterHealth();
    }

    function getCharacterMagic(uint256 characterId) public returns (uint256) {
        return ICharacter(CHARACTERS_CONTRACT).getCharacterMagic();
    }

    function createFight(uint256 characterId) public returns (uint256) {
        require(ownerOfCharacter(characterId), "you are not character owner");

        uint256 curId = _fightIdTracker.current();

        Fight storage f = fights[curId];
        f.id = curId;
        f.c1Id = characterId;
        f.c1Owner = _msgSender();
        f.status = FightStatus.Initialized;

        _fightIdTracker.increment();
        return curId;
    }

    function acceptFight(uint256 fightId, uint256 characterId) public {
        require(ownerOfCharacter(characterId), "you are not character owner");

        Fight storage f = fights[fightId];

        require(f.status == FightStatus.Initialized, "fight is not initialized yet");
        require(f.c1Id != characterId, "c1 can not be equal to c2");

        f.c2Id = characterId;
        f.c2Owner = _msgSender();
        f.status = FightStatus.Accepted;
    }

    function addFightPrize(uint256 fightId, address nftAddress, uint256 nftId) public {
        Fight storage f = fights[fightId];
        require(f.status == FightStatus.PrizeCollected, "too late to add winning prizes");

        address from = _msgSender();
        address to = address(this);
        IERC721(nftAddress).safeTransferFrom(from, to, tokenId);

        FightPrize prize = FightPrize(nftAddress, nftId);
        f.prizes.push(prize);
    }

    function fight(uint256 fightId) public returns (int8) {
        Fight storage f = fights[fightId];
        require(f.status == FightStatus.Accepted, "fight is not accepted yet");
        require(f.c1Owner == _msgSender() || f.c2Owner == _msgSender(), "you are not allowed to start fight");

        uint256 c1Power = 0;
        c1Power += getCharacterAttack(f.c1Id);
        c1Power += getCharacterDefence(f.c1Id);
        c1Power += getCharacterIntelligence(f.c1Id);
        c1Power += getCharacterStrength(f.c1Id);
        c1Power += getCharacterAgility(f.c1Id);
        c1Power += getCharacterHealth(f.c1Id);
        c1Power += getCharacterMagic(f.c1Id);

        uint256 c2Power = 0;
        c2Power += getCharacterAttack(f.c2Id);
        c2Power += getCharacterDefence(f.c2Id);
        c2Power += getCharacterIntelligence(f.c2Id);
        c2Power += getCharacterStrength(f.c2Id);
        c2Power += getCharacterAgility(f.c2Id);
        c2Power += getCharacterHealth(f.c2Id);
        c2Power += getCharacterMagic(f.c2Id);

        //update winner c and winner user
        f.status = FightStatus.Finished;


        //returns -1 if first character win
        if (c1Power > c2Power) {
            f.winner = c1;
            return - 1;
        }

        //return 1 if second character win
        if (c1Power < c2Power) {
            f.winner = c2;
            return 1;
        }

        //returns 0 if equal
        return 0;
        // equal
    }

    function collectPrizes(uint256 fightId) public {
        Fight storage f = fights[fightId];
        require(f.status == FightStatus.Accepted, "fight is not accepted yet");
        require(f.winner == _msgSender(), "only winner can collect prizes");

        for (uint i = 0; i < f.prizes.length; i++) {
            FightPrize prize = f.prizes[i];
            address to = _msgSender();
            address from = address(this);
            IERC721(prize.nftAddress).safeTransferFrom(from, to, prize.nftId);
        }
    }
}

/// Add random values and multiple turns!
/// Roll of a dice 