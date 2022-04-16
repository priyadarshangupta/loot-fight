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
contract myerc721 is
Context,
AccessControlEnumerable,
ERC721Enumerable,
ERC721Burnable,
ERC721Pausable
{
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    address constant LOOK_TOKEN_CONTRACT = 0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7;

    Counters.Counter private _tokenIdTracker;

    string private _baseTokenURI;

    struct Attributes {
        uint256 attack;
        uint256 defence;
        uint256 intelligence;
        uint256 strength;
        uint256 agility;
        uint256 health;
        uint256 magic;
    }

    struct ItemAttributes {
        uint256 attack;
        uint256 defence;
        uint256 intelligence;
        uint256 strength;
        uint256 agility;
        uint256 health;
        uint256 magic;
    }

    struct LootItem {
        uint256 tokenId;
        string itemType;
        string fullName;
    }

    struct Character {
        Attributes attributes;
        LootItem weapon;
        LootItem chest;
        LootItem head;
        LootItem waist;
        LootItem foot;
        LootItem hand;
        LootItem neck;
        LootItem ring;
        address owner;

        address assetAddress;
        uint256 assetId;
        uint256 startTime;
        uint256 minPrice;
        uint256 endTime;
        uint256 currentBidAmount;
        address currentBidOwner;
        uint256 bidCount;
        uint256 instantBuyPrice;
        bool finished;
        bool isWonBidSent;
        address trc20tokenAddress; //If we prefer to accept trc20 token (like USDT) instead of trx;
        address creator;
        mapping(address => uint) pendingReturns;
    }

    mapping(uint256 => Character) characters;
    mapping(string => ItemAttributes) itemsAttributes;

    string constant ITEM_TYPE_WEAPON = "WEAPON";
    string constant ITEM_TYPE_CHEST = "CHEST";
    string constant ITEM_TYPE_HEAD = "HEAD";
    string constant ITEM_TYPE_WAIST = "WAIST";
    string constant ITEM_TYPE_FOOT = "FOOT";
    string constant ITEM_TYPE_HAND = "HAND";
    string constant ITEM_TYPE_NECK = "NECK";
    string constant ITEM_TYPE_RING = "RING";
    mapping(string => bool) item_types;

    string constant WEAPON_WARHAMMER = "Warhammer";
    string constant WEAPON_QUARTERSTAFF = "Quarterstaff";
    string constant WEAPON_MAUL = "Maul";
    string constant WEAPON_MACE = "Mace";
    string constant WEAPON_CLUB = "Club";
    string constant WEAPON_KATANA = "Katana";
    string constant WEAPON_FALCHION = "Falchion";
    string constant WEAPON_SCIMITAR = "Scimitar";
    string constant WEAPON_LONG_SWORD = "Long Sword";
    string constant WEAPON_SHORT_SWORD = "Short Sword";
    string constant WEAPON_GHOST_WAND = "Ghost Wand";
    string constant WEAPON_GRAVE_WAND = "Grave Wand";
    string constant WEAPON_BONE_WAND = "Bone Wand";
    string constant WEAPON_WAND = "Wand";
    string constant WEAPON_GRIMOIRE = "Grimoire";
    string constant WEAPON_CHRONICLE = "Chronicle";
    string constant WEAPON_TOME = "Tome";
    string constant WEAPON_BOOK = "Book";

    string[] private weapons = [
    WEAPON_WARHAMMER,
    WEAPON_QUARTERSTAFF,
    WEAPON_MAUL,
    WEAPON_MACE,
    WEAPON_CLUB,
    WEAPON_KATANA,
    WEAPON_FALCHION,
    WEAPON_SCIMITAR,
    WEAPON_LONG_SWORD,
    WEAPON_SHORT_SWORD,
    WEAPON_GHOST_WAND,
    WEAPON_GRAVE_WAND,
    WEAPON_BONE_WAND,
    WEAPON_WAND,
    WEAPON_GRIMOIRE,
    WEAPON_CHRONICLE,
    WEAPON_TOME,
    WEAPON_BOOK
    ];

    string constant CHEST_DIVINE_ROBE = "Divine Robe";
    string constant CHEST_SILK_ROBE = "Silk Robe";
    string constant CHEST_LINEN_ROBE = "Linen Robe";
    string constant CHEST_ROBE = "Robe";
    string constant CHEST_SHIRT = "Shirt";
    string constant CHEST_DEMON_HUSK = "Demon Husk";
    string constant CHEST_DRAGONSKIN_ARMOR = "Dragonskin Armor";
    string constant CHEST_STUDDED_LEATHER_ARMOR = "Studded Leather Armor";
    string constant CHEST_HARD_LEATHER_ARMOR = "Hard Leather Armor";
    string constant CHEST_LEATHER_ARMOR = "Leather Armor";
    string constant CHEST_HOLY_CHESTPLATE = "Holy Chestplate";
    string constant CHEST_ORNATE_CHESTPLATE = "Ornate Chestplate";
    string constant CHEST_PLATE_MAIL = "Plate Mail";
    string constant CHEST_CHAIN_MAIL = "Chain Mail";
    string constant CHEST_RING_MAIL = "Ring Mail";

    string[] private chestArmor = [
    CHEST_DIVINE_ROBE,
    CHEST_SILK_ROBE,
    CHEST_LINEN_ROBE,
    CHEST_ROBE,
    CHEST_SHIRT,
    CHEST_DEMON_HUSK,
    CHEST_DRAGONSKIN_ARMOR,
    CHEST_STUDDED_LEATHER_ARMOR,
    CHEST_HARD_LEATHER_ARMOR,
    CHEST_LEATHER_ARMOR,
    CHEST_HOLY_CHESTPLATE,
    CHEST_ORNATE_CHESTPLATE,
    CHEST_PLATE_MAIL,
    CHEST_CHAIN_MAIL,
    CHEST_RING_MAIL
    ];

    string constant HEAD_ANCIENT_HELM = "Ancient Helm";
    string constant HEAD_ORNATE_HELM = "Ornate Helm";
    string constant HEAD_GREAT_HELM = "Great Helm";
    string constant HEAD_FULL_HELM = "Full Helm";
    string constant HEAD_HELM = "Helm";
    string constant HEAD_DEMON_CROWN = "Demon Crown";
    string constant HEAD_DRAGONS_CROWN = "Dragon's Crown";
    string constant HEAD_WAR_CAP = "War Cap";
    string constant HEAD_LEATHER_CAP = "Leather Cap";
    string constant HEAD_CAP = "Cap";
    string constant HEAD_CROWN = "Crown";
    string constant HEAD_DIVINE_HOOD = "Divine Hood";
    string constant HEAD_SILK_HOOD = "Silk Hood";
    string constant HEAD_LINEN_HOOD = "Linen Hood";
    string constant HEAD_HOOD = "Hood";

    string[] private headArmor = [
    HEAD_ANCIENT_HELM,
    HEAD_ORNATE_HELM,
    HEAD_GREAT_HELM,
    HEAD_FULL_HELM,
    HEAD_HELM,
    HEAD_DEMON_CROWN,
    HEAD_DRAGONS_CROWN,
    HEAD_WAR_CAP,
    HEAD_LEATHER_CAP,
    HEAD_CAP,
    HEAD_CROWN,
    HEAD_DIVINE_HOOD,
    HEAD_SILK_HOOD,
    HEAD_LINEN_HOOD,
    HEAD_HOOD
    ];

    string constant WAIST_ORNATE_BELT = "Ornate Belt";
    string constant WAIST_WAR_BELT = "War Belt";
    string constant WAIST_PLATED_BELT = "Plated Belt";
    string constant WAIST_MESH_BELT = "Mesh Belt";
    string constant WAIST_HEAVY_BELT = "Heavy Belt";
    string constant WAIST_DEMONHIDE_BELT = "Demonhide Belt";
    string constant WAIST_DRAGONSKIN_BELT = "Dragonskin Belt";
    string constant WAIST_STUDDED_LEATHER_BELT = "Studded Leather Belt";
    string constant WAIST_HARD_LEATHER_BELT = "Hard Leather Belt";
    string constant WAIST_LEATHER_BELT = "Leather Belt";
    string constant WAIST_BRIGHTSILK_SASH = "Brightsilk Sash";
    string constant WAIST_SILK_SASH = "Silk Sash";
    string constant WAIST_WOOL_SASH = "Wool Sash";
    string constant WAIST_LINEN_SASH = "Linen Sash";
    string constant WAIST_SASH = "Sash";

    string[] private waistArmor = [
    WAIST_ORNATE_BELT,
    WAIST_WAR_BELT,
    WAIST_PLATED_BELT,
    WAIST_MESH_BELT,
    WAIST_HEAVY_BELT,
    WAIST_DEMONHIDE_BELT,
    WAIST_DRAGONSKIN_BELT,
    WAIST_STUDDED_LEATHER_BELT,
    WAIST_HARD_LEATHER_BELT,
    WAIST_LEATHER_BELT,
    WAIST_BRIGHTSILK_SASH,
    WAIST_SILK_SASH,
    WAIST_WOOL_SASH,
    WAIST_LINEN_SASH,
    WAIST_SASH
    ];

    string constant FOOT_HOLY_GREAVES = "Holy Greaves";
    string constant FOOT_ORNATE_GREAVES = "Ornate Greaves";
    string constant FOOT_GREAVES = "Greaves";
    string constant FOOT_CHAIN_BOOTS = "Chain Boots";
    string constant FOOT_HEAVY_BOOTS = "Heavy Boots";
    string constant FOOT_DEMONHIDE_BOOTS = "Demonhide Boots";
    string constant FOOT_DRAGONSKIN_BOOTS = "Dragonskin Boots";
    string constant FOOT_STUDDED_LEATHER_BOOTS = "Studded Leather Boots";
    string constant FOOT_HARD_LEATHER_BOOTS = "Hard Leather Boots";
    string constant FOOT_LEATHER_BOOTS = "Leather Boots";
    string constant FOOT_DIVINE_SLIPPERS = "Divine Slippers";
    string constant FOOT_SILK_SLIPPERS = "Silk Slippers";
    string constant FOOT_WOOL_SHOES = "Wool Shoes";
    string constant FOOT_LINEN_SHOES = "Linen Shoes";
    string constant FOOT_SHOES = "Shoes";

    string[] private footArmor = [
    FOOT_HOLY_GREAVES,
    FOOT_ORNATE_GREAVES,
    FOOT_GREAVES,
    FOOT_CHAIN_BOOTS,
    FOOT_HEAVY_BOOTS,
    FOOT_DEMONHIDE_BOOTS,
    FOOT_DRAGONSKIN_BOOTS,
    FOOT_STUDDED_LEATHER_BOOTS,
    FOOT_HARD_LEATHER_BOOTS,
    FOOT_LEATHER_BOOTS,
    FOOT_DIVINE_SLIPPERS,
    FOOT_SILK_SLIPPERS,
    FOOT_WOOL_SHOES,
    FOOT_LINEN_SHOES,
    FOOT_SHOES
    ];

    string constant HAND_HOLY_GAUNTLETS = "Holy Gauntlets";
    string constant HAND_ORNATE_GAUNTLETS = "Ornate Gauntlets";
    string constant HAND_GAUNTLETS = "Gauntlets";
    string constant HAND_CHAIN_GLOVES = "Chain Gloves";
    string constant HAND_HEAVY_GLOVES = "Heavy Gloves";
    string constant HAND_DEMONS_HANDS = "Demon's Hands";
    string constant HAND_DRAGONSKIN_GLOVES = "Dragonskin Gloves";
    string constant HAND_STUDDED_LEATHER_GLOVES = "Studded Leather Gloves";
    string constant HAND_HARD_LEATHER_GLOVES = "Hard Leather Gloves";
    string constant HAND_LEATHER_GLOVES = "Leather Gloves";
    string constant HAND_DIVINE_GLOVES = "Divine Gloves";
    string constant HAND_SILK_GLOVES = "Silk Gloves";
    string constant HAND_WOOL_GLOVES = "Wool Gloves";
    string constant HAND_LINEN_GLOVES = "Linen Gloves";
    string constant HAND_GLOVES = "Gloves";

    string[] private handArmor = [
    HAND_HOLY_GAUNTLETS,
    HAND_ORNATE_GAUNTLETS,
    HAND_GAUNTLETS,
    HAND_CHAIN_GLOVES,
    HAND_HEAVY_GLOVES,
    HAND_DEMONS_HANDS,
    HAND_DRAGONSKIN_GLOVES,
    HAND_STUDDED_LEATHER_GLOVES,
    HAND_HARD_LEATHER_GLOVES,
    HAND_LEATHER_GLOVES,
    HAND_DIVINE_GLOVES,
    HAND_SILK_GLOVES,
    HAND_WOOL_GLOVES,
    HAND_LINEN_GLOVES,
    HAND_GLOVES
    ];

    string constant NECKLACE_NECKLACE = "Necklace";
    string constant NECKLACE_AMULET = "Amulet";
    string constant NECKLACE_PENDANT = "Pendant";

    string[] private necklaces = [
    NECKLACE_NECKLACE,
    NECKLACE_AMULET,
    NECKLACE_PENDANT
    ];

    string constant RING_GOLD_RING = "Gold Ring";
    string constant RING_SILVER_RING = "Silver Ring";
    string constant RING_BRONZE_RING = "Bronze Ring";
    string constant RING_PLATINUM_RING = "Platinum Ring";
    string constant RING_TITANIUM_RING = "Titanium Ring";

    string[] private rings = [
    RING_GOLD_RING,
    RING_SILVER_RING,
    RING_BRONZE_RING,
    RING_PLATINUM_RING,
    RING_TITANIUM_RING
    ];

    string constant SUFFIXE_OF_POWER = "of Power";
    string constant SUFFIXE_OF_GIANTS = "of Giants";
    string constant SUFFIXE_OF_TITANS = "of Titans";
    string constant SUFFIXE_OF_SKILL = "of Skill";
    string constant SUFFIXE_OF_PERFECTION = "of Perfection";
    string constant SUFFIXE_OF_BRILLIANCE = "of Brilliance";
    string constant SUFFIXE_OF_ENLIGHTENMENT = "of Enlightenment";
    string constant SUFFIXE_OF_PROTECTION = "of Protection";
    string constant SUFFIXE_OF_ANGER = "of Anger";
    string constant SUFFIXE_OF_RAGE = "of Rage";
    string constant SUFFIXE_OF_FURY = "of Fury";
    string constant SUFFIXE_OF_VITRIOL = "of Vitriol";
    string constant SUFFIXE_OFTHE_FOX = "of the Fox";
    string constant SUFFIXE_OF_DETECTION = "of Detection";
    string constant SUFFIXE_OF_REFLECTION = "of Reflection";
    string constant SUFFIXE_OFTHE_TWINS = "of the Twins";

    string[] private suffixes = [
    SUFFIXE_OF_POWER,
    SUFFIXE_OF_GIANTS,
    SUFFIXE_OF_TITANS,
    SUFFIXE_OF_SKILL,
    SUFFIXE_OF_PERFECTION,
    SUFFIXE_OF_BRILLIANCE,
    SUFFIXE_OF_ENLIGHTENMENT,
    SUFFIXE_OF_PROTECTION,
    SUFFIXE_OF_ANGER,
    SUFFIXE_OF_RAGE,
    SUFFIXE_OF_FURY,
    SUFFIXE_OF_VITRIOL,
    SUFFIXE_OFTHE_FOX,
    SUFFIXE_OF_DETECTION,
    SUFFIXE_OF_REFLECTION,
    SUFFIXE_OFTHE_TWINS
    ];

    string constant NAMEPREFIXE_AGONY = "Agony";
    string constant NAMEPREFIXE_APOCALYPSE = "Apocalypse";
    string constant NAMEPREFIXE_ARMAGEDDON = "Armageddon";
    string constant NAMEPREFIXE_BEAST = "Beast";
    string constant NAMEPREFIXE_BEHEMOTH = "Behemoth";
    string constant NAMEPREFIXE_BLIGHT = "Blight";
    string constant NAMEPREFIXE_BLOOD = "Blood";
    string constant NAMEPREFIXE_BRAMBLE = "Bramble";
    string constant NAMEPREFIXE_BRIMSTONE = "Brimstone";
    string constant NAMEPREFIXE_BROOD = "Brood";
    string constant NAMEPREFIXE_CARRION = "Carrion";
    string constant NAMEPREFIXE_CATACLYSM = "Cataclysm";
    string constant NAMEPREFIXE_CHIMERIC = "Chimeric";
    string constant NAMEPREFIXE_CORPSE = "Corpse";
    string constant NAMEPREFIXE_CORRUPTION = "Corruption";
    string constant NAMEPREFIXE_DAMNATION = "Damnation";
    string constant NAMEPREFIXE_DEATH = "Death";
    string constant NAMEPREFIXE_DEMON = "Demon";
    string constant NAMEPREFIXE_DIRE = "Dire";
    string constant NAMEPREFIXE_DRAGON = "Dragon";
    string constant NAMEPREFIXE_DREAD = "Dread";
    string constant NAMEPREFIXE_DOOM = "Doom";
    string constant NAMEPREFIXE_DUSK = "Dusk";
    string constant NAMEPREFIXE_EAGLE = "Eagle";
    string constant NAMEPREFIXE_EMPYREAN = "Empyrean";
    string constant NAMEPREFIXE_FATE = "Fate";
    string constant NAMEPREFIXE_FOE = "Foe";
    string constant NAMEPREFIXE_GALE = "Gale";
    string constant NAMEPREFIXE_GHOUL = "Ghoul";
    string constant NAMEPREFIXE_GLOOM = "Gloom";
    string constant NAMEPREFIXE_GLYPH = "Glyph";
    string constant NAMEPREFIXE_GOLEM = "Golem";
    string constant NAMEPREFIXE_GRIM = "Grim";
    string constant NAMEPREFIXE_HATE = "Hate";
    string constant NAMEPREFIXE_HAVOC = "Havoc";
    string constant NAMEPREFIXE_HONOUR = "Honour";
    string constant NAMEPREFIXE_HORROR = "Horror";
    string constant NAMEPREFIXE_HYPNOTIC = "Hypnotic";
    string constant NAMEPREFIXE_KRAKEN = "Kraken";
    string constant NAMEPREFIXE_LOATH = "Loath";
    string constant NAMEPREFIXE_MAELSTROM = "Maelstrom";
    string constant NAMEPREFIXE_MIND = "Mind";
    string constant NAMEPREFIXE_MIRACLE = "Miracle";
    string constant NAMEPREFIXE_MORBID = "Morbid";
    string constant NAMEPREFIXE_OBLIVION = "Oblivion";
    string constant NAMEPREFIXE_ONSLAUGHT = "Onslaught";
    string constant NAMEPREFIXE_PAIN = "Pain";
    string constant NAMEPREFIXE_PANDEMONIUM = "Pandemonium";
    string constant NAMEPREFIXE_PHOENIX = "Phoenix";
    string constant NAMEPREFIXE_PLAGUE = "Plague";
    string constant NAMEPREFIXE_RAGE = "Rage";
    string constant NAMEPREFIXE_RAPTURE = "Rapture";
    string constant NAMEPREFIXE_RUNE = "Rune";
    string constant NAMEPREFIXE_SKULL = "Skull";
    string constant NAMEPREFIXE_SOL = "Sol";
    string constant NAMEPREFIXE_SOUL = "Soul";
    string constant NAMEPREFIXE_SORROW = "Sorrow";
    string constant NAMEPREFIXE_SPIRIT = "Spirit";
    string constant NAMEPREFIXE_STORM = "Storm";
    string constant NAMEPREFIXE_TEMPEST = "Tempest";
    string constant NAMEPREFIXE_TORMENT = "Torment";
    string constant NAMEPREFIXE_VENGEANCE = "Vengeance";
    string constant NAMEPREFIXE_VICTORY = "Victory";
    string constant NAMEPREFIXE_VIPER = "Viper";
    string constant NAMEPREFIXE_VORTEX = "Vortex";
    string constant NAMEPREFIXE_WOE = "Woe";
    string constant NAMEPREFIXE_WRATH = "Wrath";
    string constant NAMEPREFIXE_LIGHTS = "Light's";
    string constant NAMEPREFIXE_SHIMMERING = "Shimmering";

    string[] private namePrefixes = [
    NAMEPREFIXE_AGONY,
    NAMEPREFIXE_APOCALYPSE,
    NAMEPREFIXE_ARMAGEDDON,
    NAMEPREFIXE_BEAST,
    NAMEPREFIXE_BEHEMOTH,
    NAMEPREFIXE_BLIGHT,
    NAMEPREFIXE_BLOOD,
    NAMEPREFIXE_BRAMBLE,
    NAMEPREFIXE_BRIMSTONE,
    NAMEPREFIXE_BROOD,
    NAMEPREFIXE_CARRION,
    NAMEPREFIXE_CATACLYSM,
    NAMEPREFIXE_CHIMERIC,
    NAMEPREFIXE_CORPSE,
    NAMEPREFIXE_CORRUPTION,
    NAMEPREFIXE_DAMNATION,
    NAMEPREFIXE_DEATH,
    NAMEPREFIXE_DEMON,
    NAMEPREFIXE_DIRE,
    NAMEPREFIXE_DRAGON,
    NAMEPREFIXE_DREAD,
    NAMEPREFIXE_DOOM,
    NAMEPREFIXE_DUSK,
    NAMEPREFIXE_EAGLE,
    NAMEPREFIXE_EMPYREAN,
    NAMEPREFIXE_FATE,
    NAMEPREFIXE_FOE,
    NAMEPREFIXE_GALE,
    NAMEPREFIXE_GHOUL,
    NAMEPREFIXE_GLOOM,
    NAMEPREFIXE_GLYPH,
    NAMEPREFIXE_GOLEM,
    NAMEPREFIXE_GRIM,
    NAMEPREFIXE_HATE,
    NAMEPREFIXE_HAVOC,
    NAMEPREFIXE_HONOUR,
    NAMEPREFIXE_HORROR,
    NAMEPREFIXE_HYPNOTIC,
    NAMEPREFIXE_KRAKEN,
    NAMEPREFIXE_LOATH,
    NAMEPREFIXE_MAELSTROM,
    NAMEPREFIXE_MIND,
    NAMEPREFIXE_MIRACLE,
    NAMEPREFIXE_MORBID,
    NAMEPREFIXE_OBLIVION,
    NAMEPREFIXE_ONSLAUGHT,
    NAMEPREFIXE_PAIN,
    NAMEPREFIXE_PANDEMONIUM,
    NAMEPREFIXE_PHOENIX,
    NAMEPREFIXE_PLAGUE,
    NAMEPREFIXE_RAGE,
    NAMEPREFIXE_RAPTURE,
    NAMEPREFIXE_RUNE,
    NAMEPREFIXE_SKULL,
    NAMEPREFIXE_SOL,
    NAMEPREFIXE_SOUL,
    NAMEPREFIXE_SORROW,
    NAMEPREFIXE_SPIRIT,
    NAMEPREFIXE_STORM,
    NAMEPREFIXE_TEMPEST,
    NAMEPREFIXE_TORMENT,
    NAMEPREFIXE_VENGEANCE,
    NAMEPREFIXE_VICTORY,
    NAMEPREFIXE_VIPER,
    NAMEPREFIXE_VORTEX,
    NAMEPREFIXE_WOE,
    NAMEPREFIXE_WRATH,
    NAMEPREFIXE_LIGHTS,
    NAMEPREFIXE_SHIMMERING
    ];

    string constant NAMESUFFIXE_BANE = "Bane";
    string constant NAMESUFFIXE_ROOT = "Root";
    string constant NAMESUFFIXE_BITE = "Bite";
    string constant NAMESUFFIXE_SONG = "Song";
    string constant NAMESUFFIXE_ROAR = "Roar";
    string constant NAMESUFFIXE_GRASP = "Grasp";
    string constant NAMESUFFIXE_INSTRUMENT = "Instrument";
    string constant NAMESUFFIXE_GLOW = "Glow";
    string constant NAMESUFFIXE_BENDER = "Bender";
    string constant NAMESUFFIXE_SHADOW = "Shadow";
    string constant NAMESUFFIXE_WHISPER = "Whisper";
    string constant NAMESUFFIXE_SHOUT = "Shout";
    string constant NAMESUFFIXE_GROWL = "Growl";
    string constant NAMESUFFIXE_TEAR = "Tear";
    string constant NAMESUFFIXE_PEAK = "Peak";
    string constant NAMESUFFIXE_FORM = "Form";
    string constant NAMESUFFIXE_SUN = "Sun";
    string constant NAMESUFFIXE_MOON = "Moon";

    string[] private nameSuffixes = [
    NAMESUFFIXE_BANE,
    NAMESUFFIXE_ROOT,
    NAMESUFFIXE_BITE,
    NAMESUFFIXE_SONG,
    NAMESUFFIXE_ROAR,
    NAMESUFFIXE_GRASP,
    NAMESUFFIXE_INSTRUMENT,
    NAMESUFFIXE_GLOW,
    NAMESUFFIXE_BENDER,
    NAMESUFFIXE_SHADOW,
    NAMESUFFIXE_WHISPER,
    NAMESUFFIXE_SHOUT,
    NAMESUFFIXE_GROWL,
    NAMESUFFIXE_TEAR,
    NAMESUFFIXE_PEAK,
    NAMESUFFIXE_FORM,
    NAMESUFFIXE_SUN,
    NAMESUFFIXE_MOON
    ];

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function getWeapon(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, ITEM_TYPE_WEAPON, weapons);
    }

    function getChest(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, ITEM_TYPE_CHEST, chestArmor);
    }

    function getHead(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, ITEM_TYPE_HEAD, headArmor);
    }

    function getWaist(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, ITEM_TYPE_WAIST, waistArmor);
    }

    function getFoot(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, ITEM_TYPE_FOOT, footArmor);
    }

    function getHand(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, ITEM_TYPE_HAND, handArmor);
    }

    function getNeck(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, ITEM_TYPE_NECK, necklaces);
    }

    function getRing(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, ITEM_TYPE_RING, rings);
    }

    function pluck(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, Strings.toString(tokenId))));
        string memory output = sourceArray[rand % sourceArray.length];
        uint256 greatness = rand % 21;
        if (greatness > 14) {
            output = string(abi.encodePacked(output, " ", suffixes[rand % suffixes.length]));
        }
        if (greatness >= 19) {
            string[2] memory name;
            name[0] = namePrefixes[rand % namePrefixes.length];
            name[1] = nameSuffixes[rand % nameSuffixes.length];
            if (greatness == 19) {
                output = string(abi.encodePacked('"', name[0], ' ', name[1], '" ', output));
            } else {
                output = string(abi.encodePacked('"', name[0], ' ', name[1], '" ', output, " +1"));
            }
        }
        return output;
    }

    function getMinItemAttributes() internal view returns (ItemAttributes memory) {
        ItemAttributes memory attrs = ItemAttributes(1, 1, 1, 1, 1, 1, 1);
        return attrs;
    }

    function getItemAttributes(string memory itemName) internal view returns (ItemAttributes memory) {
        ItemAttributes memory gotAttrs = itemsAttributes[itemName];
        if (gotAttrs.attack == 0) {
            //can not be zero, meaning not found, so return default with all values set to 1
            return getMinItemAttributes();
        }
        return gotAttrs;
    }

    function multiplyAttrs(ItemAttributes memory a1, ItemAttributes memory a2) internal view returns (ItemAttributes memory) {
        ItemAttributes memory resultAttrs = ItemAttributes(1, 1, 1, 1, 1, 1, 1);

        resultAttrs.attack = a1.attack * a2.attack;
        resultAttrs.defence = a1.defence * a2.defence;
        resultAttrs.intelligence = a1.intelligence * a2.intelligence;
        resultAttrs.strength = a1.strength * a2.strength;
        resultAttrs.agility = a1.agility * a2.agility;
        resultAttrs.health = a1.health * a2.health;
        resultAttrs.magic = a1.magic * a2.magic;

        return resultAttrs;
    }

    function pluckAttributes(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (ItemAttributes memory) {
        ItemAttributes memory resultAttrs = ItemAttributes(1, 1, 1, 1, 1, 1, 1);

        uint256 rand = random(string(abi.encodePacked(keyPrefix, Strings.toString(tokenId))));
        string memory output = sourceArray[rand % sourceArray.length];

        ItemAttributes memory attrs = getItemAttributes(output);
        resultAttrs = multiplyAttrs(resultAttrs, attrs);

        uint256 greatness = rand % 21;
        if (greatness > 14) {
            string memory suffix = suffixes[rand % suffixes.length];
            attrs = getItemAttributes(suffix);
            resultAttrs = multiplyAttrs(resultAttrs, attrs);
        }
        if (greatness >= 19) {
            string memory namePrefix = namePrefixes[rand % namePrefixes.length];
            attrs = getItemAttributes(namePrefix);
            resultAttrs = multiplyAttrs(resultAttrs, attrs);

            string memory nameSuffix = nameSuffixes[rand % nameSuffixes.length];
            attrs = getItemAttributes(nameSuffix);
            resultAttrs = multiplyAttrs(resultAttrs, attrs);

            if (greatness == 20) {
                uint256 mp = 1000;
                attrs = ItemAttributes(mp, mp, mp, mp, mp, mp, mp);
                resultAttrs = multiplyAttrs(resultAttrs, attrs);
            }
        }
        return resultAttrs;
    }

    function validItemType(string memory itemType) internal view returns (bool) {
        return item_types[itemType];
    }

    function addItemType(string memory itemType) internal {
        item_types[ITEM_TYPE_HAND] = true;
    }

    function addItemAttributes(string memory itemName, uint256 attack, uint256 defence, uint256 intelligence, uint256 strength, uint256 agility, uint256 magic) internal {
        uint256 health = 1;
        itemsAttributes[itemName] = ItemAttributes(attack, defence, intelligence, strength, agility, health, magic);
    }

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

        addItemType(ITEM_TYPE_HAND);
        addItemType(ITEM_TYPE_WEAPON);
        addItemType(ITEM_TYPE_CHEST);
        addItemType(ITEM_TYPE_HEAD);
        addItemType(ITEM_TYPE_WAIST);
        addItemType(ITEM_TYPE_FOOT);
        addItemType(ITEM_TYPE_HAND);
        addItemType(ITEM_TYPE_NECK);
        addItemType(ITEM_TYPE_RING);

        addItemAttributes(WEAPON_WARHAMMER, 9562, 1, 1, 9562, 1, 1);
        addItemAttributes(WEAPON_QUARTERSTAFF, 9495, 1, 1, 1, 9495, 1);
        addItemAttributes(WEAPON_MAUL, 9523, 1, 1, 9523, 1, 1);
        addItemAttributes(WEAPON_MACE, 9527, 1, 1, 1, 1, 1);
        addItemAttributes(WEAPON_CLUB, 9566, 1, 1, 9566, 1, 1);
        addItemAttributes(WEAPON_KATANA, 9482, 1, 1, 1, 9482, 1);
        addItemAttributes(WEAPON_FALCHION, 9496, 1, 1, 1, 9496, 1);
        addItemAttributes(WEAPON_SCIMITAR, 9525, 1, 1, 1, 9525, 1);
        addItemAttributes(WEAPON_LONG_SWORD, 9539, 1, 1, 9539, 1, 1);
        addItemAttributes(WEAPON_SHORT_SWORD, 9540, 1, 1, 1, 9540, 1);
        addItemAttributes(WEAPON_GHOST_WAND, 1, 1, 9558, 1, 1, 9558);
        addItemAttributes(WEAPON_GRAVE_WAND, 1, 1, 9492, 1, 1, 9492);
        addItemAttributes(WEAPON_BONE_WAND, 1, 1, 9542, 1, 1, 9542);
        addItemAttributes(WEAPON_WAND, 1, 1, 8114, 1, 1, 8114);
        addItemAttributes(WEAPON_GRIMOIRE, 9507, 1, 1, 1, 1, 9507);
        addItemAttributes(WEAPON_CHRONICLE, 9525, 1, 1, 1, 1, 9525);
        addItemAttributes(WEAPON_TOME, 1, 1, 9504, 1, 1, 9504);
        addItemAttributes(WEAPON_BOOK, 1, 9513, 1, 1, 1, 9513);
        addItemAttributes(CHEST_DIVINE_ROBE, 1, 9509, 1, 1, 1, 9509);
        addItemAttributes(CHEST_SILK_ROBE, 1, 9524, 1, 1, 1, 9524);
        addItemAttributes(CHEST_LINEN_ROBE, 1, 9483, 1, 1, 1, 9483);
        addItemAttributes(CHEST_ROBE, 1, 8009, 1, 1, 1, 8009);
        addItemAttributes(CHEST_SHIRT, 1, 9509, 1, 1, 9509, 1);
        addItemAttributes(CHEST_DEMON_HUSK, 1, 9514, 1, 9514, 1, 1);
        addItemAttributes(CHEST_DRAGONSKIN_ARMOR, 1, 9529, 1, 9529, 1, 1);
        addItemAttributes(CHEST_STUDDED_LEATHER_ARMOR, 1, 9482, 1, 9482, 1, 1);
        addItemAttributes(CHEST_HARD_LEATHER_ARMOR, 1, 9502, 1, 9502, 1, 1);
        addItemAttributes(CHEST_LEATHER_ARMOR, 1, 8477, 1, 1, 8477, 1);
        addItemAttributes(CHEST_HOLY_CHESTPLATE, 1, 9497, 1, 1, 1, 9497);
        addItemAttributes(CHEST_ORNATE_CHESTPLATE, 1, 9504, 1, 1, 1, 9504);
        addItemAttributes(CHEST_PLATE_MAIL, 1, 9477, 1, 9477, 1, 1);
        addItemAttributes(CHEST_CHAIN_MAIL, 1, 9461, 1, 9461, 1, 1);
        addItemAttributes(CHEST_RING_MAIL, 1, 9531, 1, 1, 9531, 1);
        addItemAttributes(HEAD_ANCIENT_HELM, 1, 1, 9629, 9629, 1, 1);
        addItemAttributes(HEAD_ORNATE_HELM, 1, 1, 9598, 1, 1, 9598);
        addItemAttributes(HEAD_GREAT_HELM, 1, 1, 9603, 9603, 1, 1);
        addItemAttributes(HEAD_FULL_HELM, 1, 1, 9634, 9634, 1, 1);
        addItemAttributes(HEAD_HELM, 1, 1, 8083, 1, 8083, 1);
        addItemAttributes(HEAD_DEMON_CROWN, 1, 1, 9625, 1, 1, 1);
        addItemAttributes(HEAD_DRAGONS_CROWN, 1, 1, 9616, 1, 1, 1);
        addItemAttributes(HEAD_WAR_CAP, 1, 9645, 1, 1, 1, 1);
        addItemAttributes(HEAD_LEATHER_CAP, 1, 9618, 1, 1, 1, 1);
        addItemAttributes(HEAD_CAP, 1, 8870, 1, 1, 1, 1);
        addItemAttributes(HEAD_CROWN, 8854, 1, 1, 1, 8854, 1);
        addItemAttributes(HEAD_DIVINE_HOOD, 1, 1, 9595, 1, 1, 9595);
        addItemAttributes(HEAD_SILK_HOOD, 1, 1, 9640, 1, 9640, 1);
        addItemAttributes(HEAD_LINEN_HOOD, 1, 1, 9587, 1, 9587, 1);
        addItemAttributes(HEAD_HOOD, 1, 1, 8411, 1, 8411, 1);
        addItemAttributes(WAIST_ORNATE_BELT, 1, 9530, 1, 1, 1, 9530);
        addItemAttributes(WAIST_WAR_BELT, 1, 9484, 1, 9484, 1, 1);
        addItemAttributes(WAIST_PLATED_BELT, 1, 9531, 1, 9531, 1, 1);
        addItemAttributes(WAIST_MESH_BELT, 1, 9558, 1, 1, 9558, 1);
        addItemAttributes(WAIST_HEAVY_BELT, 1, 9488, 1, 9488, 1, 1);
        addItemAttributes(WAIST_DEMONHIDE_BELT, 1, 9534, 1, 9534, 1, 1);
        addItemAttributes(WAIST_DRAGONSKIN_BELT, 1, 9522, 1, 9522, 1, 1);
        addItemAttributes(WAIST_STUDDED_LEATHER_BELT, 1, 9520, 1, 1, 1, 9520);
        addItemAttributes(WAIST_HARD_LEATHER_BELT, 1, 9538, 1, 9538, 1, 1);
        addItemAttributes(WAIST_LEATHER_BELT, 1, 8570, 1, 1, 8570, 1);
        addItemAttributes(WAIST_BRIGHTSILK_SASH, 1, 9537, 1, 1, 9537, 1);
        addItemAttributes(WAIST_SILK_SASH, 1, 9505, 1, 1, 9505, 1);
        addItemAttributes(WAIST_WOOL_SASH, 1, 9513, 1, 1, 9513, 1);
        addItemAttributes(WAIST_LINEN_SASH, 1, 9540, 1, 1, 9540, 1);
        addItemAttributes(WAIST_SASH, 1, 7637, 1, 1, 7637, 1);
        addItemAttributes(FOOT_HOLY_GREAVES, 9525, 1, 1, 1, 9525, 1);
        addItemAttributes(FOOT_ORNATE_GREAVES, 9548, 1, 1, 1, 9548, 1);
        addItemAttributes(FOOT_GREAVES, 8589, 1, 1, 1, 8589, 1);
        addItemAttributes(FOOT_CHAIN_BOOTS, 9477, 1, 1, 9477, 1, 1);
        addItemAttributes(FOOT_HEAVY_BOOTS, 9544, 1, 1, 9544, 1, 1);
        addItemAttributes(FOOT_DEMONHIDE_BOOTS, 9543, 1, 1, 9543, 1, 1);
        addItemAttributes(FOOT_DRAGONSKIN_BOOTS, 9515, 1, 1, 9515, 1, 1);
        addItemAttributes(FOOT_STUDDED_LEATHER_BOOTS, 9523, 1, 1, 1, 1, 9523);
        addItemAttributes(FOOT_HARD_LEATHER_BOOTS, 9557, 1, 1, 9557, 1, 1);
        addItemAttributes(FOOT_LEATHER_BOOTS, 8596, 1, 1, 1, 8596, 1);
        addItemAttributes(FOOT_DIVINE_SLIPPERS, 9507, 1, 1, 1, 1, 9507);
        addItemAttributes(FOOT_SILK_SLIPPERS, 9520, 1, 1, 1, 9520, 1);
        addItemAttributes(FOOT_WOOL_SHOES, 9507, 1, 1, 1, 9507, 1);
        addItemAttributes(FOOT_LINEN_SHOES, 9516, 1, 1, 1, 9516, 1);
        addItemAttributes(FOOT_SHOES, 8540, 1, 1, 1, 8540, 1);
        addItemAttributes(HAND_HOLY_GAUNTLETS, 1, 1, 9642, 1, 1, 9642);
        addItemAttributes(HAND_ORNATE_GAUNTLETS, 1, 1, 9670, 1, 1, 9670);
        addItemAttributes(HAND_GAUNTLETS, 1, 1, 8962, 1, 1, 8962);
        addItemAttributes(HAND_CHAIN_GLOVES, 9673, 1, 1, 9673, 1, 1);
        addItemAttributes(HAND_HEAVY_GLOVES, 9649, 1, 1, 9649, 1, 1);
        addItemAttributes(HAND_DEMONS_HANDS, 1, 1, 9668, 9668, 1, 1);
        addItemAttributes(HAND_DRAGONSKIN_GLOVES, 9664, 1, 1, 9664, 1, 1);
        addItemAttributes(HAND_STUDDED_LEATHER_GLOVES, 9648, 1, 1, 9648, 1, 1);
        addItemAttributes(HAND_HARD_LEATHER_GLOVES, 9651, 1, 1, 9651, 1, 1);
        addItemAttributes(HAND_LEATHER_GLOVES, 8961, 1, 1, 8961, 1, 1);
        addItemAttributes(HAND_DIVINE_GLOVES, 1, 1, 9662, 1, 9662, 1);
        addItemAttributes(HAND_SILK_GLOVES, 1, 9646, 1, 1, 9646, 1);
        addItemAttributes(HAND_WOOL_GLOVES, 1, 9657, 1, 1, 9657, 1);
        addItemAttributes(HAND_LINEN_GLOVES, 1, 9645, 1, 1, 9645, 1);
        addItemAttributes(HAND_GLOVES, 1, 6209, 1, 1, 6209, 1);
        addItemAttributes(NECKLACE_NECKLACE, 1, 6608, 1, 6608, 1, 1);
        addItemAttributes(NECKLACE_AMULET, 1, 6818, 1, 1, 6818, 1);
        addItemAttributes(NECKLACE_PENDANT, 1, 6575, 1, 1, 1, 6575);
        addItemAttributes(RING_GOLD_RING, 1, 1, 8089, 1, 1, 8089);
        addItemAttributes(RING_SILVER_RING, 1, 1, 7952, 1, 1, 7952);
        addItemAttributes(RING_BRONZE_RING, 1, 1, 8003, 1, 1, 8003);
        addItemAttributes(RING_PLATINUM_RING, 1, 1, 7956, 1, 1, 7956);
        addItemAttributes(RING_TITANIUM_RING, 1, 1, 8002, 1, 1, 8002);
        addItemAttributes(NAMESUFFIXE_BANE, 1, 1, 1, 10000, 1, 1);
        addItemAttributes(NAMESUFFIXE_ROOT, 1, 1, 1, 1, 1, 9234);
        addItemAttributes(NAMESUFFIXE_BITE, 1, 1, 1, 9168, 1, 1);
        addItemAttributes(NAMESUFFIXE_SONG, 1, 1, 1, 1, 1, 10000);
        addItemAttributes(NAMESUFFIXE_ROAR, 1, 1, 1, 9137, 1, 1);
        addItemAttributes(NAMESUFFIXE_GRASP, 1, 1, 1, 1, 9124, 1);
        addItemAttributes(NAMESUFFIXE_INSTRUMENT, 1, 1, 1, 10000, 1, 1);
        addItemAttributes(NAMESUFFIXE_GLOW, 1, 1, 1, 1, 1, 9178);
        addItemAttributes(NAMESUFFIXE_BENDER, 1, 1, 1, 1, 9185, 1);
        addItemAttributes(NAMESUFFIXE_SHADOW, 1, 1, 1, 1, 1, 10000);
        addItemAttributes(NAMESUFFIXE_SHOUT, 9187, 1, 1, 9187, 1, 1);
        addItemAttributes(NAMESUFFIXE_GROWL, 1, 10000, 1, 10000, 1, 1);
        addItemAttributes(NAMESUFFIXE_TEAR, 1, 1, 9200, 1, 1, 1);
        addItemAttributes(NAMESUFFIXE_PEAK, 1, 9099, 1, 1, 9099, 1);
        addItemAttributes(NAMESUFFIXE_FORM, 1, 10000, 1, 1, 10000, 1);
        addItemAttributes(NAMESUFFIXE_SUN, 9158, 1, 1, 9158, 1, 1);
        addItemAttributes(NAMESUFFIXE_MOON, 1, 9122, 1, 1, 9122, 1);
        addItemAttributes(NAMEPREFIXE_AGONY, 1, 10000, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_APOCALYPSE, 9888, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_ARMAGEDDON, 1, 9896, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_BEAST, 10000, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_BEHEMOTH, 1, 9914, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_BLIGHT, 9894, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_BLOOD, 10000, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_BRAMBLE, 1, 9894, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_BRIMSTONE, 1, 1, 9910, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_BROOD, 1, 1, 10000, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_CARRION, 1, 9891, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_CATACLYSM, 9896, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_CHIMERIC, 1, 1, 10000, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_CORPSE, 9914, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_CORRUPTION, 9892, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_DAMNATION, 10000, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_DEATH, 9905, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_DEMON, 7865, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_DIRE, 10000, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_DRAGON, 7844, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_DREAD, 9896, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_DOOM, 10000, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_DUSK, 9912, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_EAGLE, 9894, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_EMPYREAN, 1, 1, 10000, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_FATE, 1, 1, 9909, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_FOE, 9901, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_GALE, 1, 10000, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_GHOUL, 9900, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_GLOOM, 1, 1, 9902, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_GLYPH, 1, 1, 10000, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_GOLEM, 1, 9888, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_GRIM, 9544, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_HATE, 10000, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_HAVOC, 9897, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_HONOUR, 9902, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_HORROR, 10000, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_HYPNOTIC, 1, 1, 9902, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_KRAKEN, 9889, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_LOATH, 1, 10000, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_MAELSTROM, 1, 9905, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_MIND, 1, 9887, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_MIRACLE, 1, 1, 10000, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_MORBID, 9888, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_OBLIVION, 1, 9907, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_ONSLAUGHT, 10000, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_PAIN, 9901, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_PANDEMONIUM, 1, 9887, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_PHOENIX, 1, 1, 10000, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_PLAGUE, 9903, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_RAGE, 9053, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_RAPTURE, 10000, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_RUNE, 1, 1, 9898, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_SKULL, 9889, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_SOL, 1, 1, 10000, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_SOUL, 1, 1, 9894, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_SORROW, 9894, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_SPIRIT, 1, 1, 10000, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_STORM, 9914, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_TEMPEST, 9887, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_TORMENT, 10000, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_VENGEANCE, 1, 9892, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_VICTORY, 9891, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_VIPER, 10000, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_VORTEX, 1, 9911, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_WOE, 9891, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_WRATH, 10000, 1, 1, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_LIGHTS, 1, 1, 9889, 1, 1, 1);
        addItemAttributes(NAMEPREFIXE_SHIMMERING, 1, 1, 9902, 1, 1, 1);

        //itemsAttributes["long anme"] = Attributes(1, 2, 3, 4, 5, 6 );
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

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return "blah";
    }

    function ownerOfToken(uint256 tokenId) internal view returns (bool) {
        return IERC721(LOOK_TOKEN_CONTRACT).ownerOf(tokenId) == _msgSender();
    }

    function getItemMultiplier(uint256 tokenId, string memory itemType) internal returns (ItemAttributes memory) {
        if (strcmp(itemType, ITEM_TYPE_WEAPON)) {
            return pluckAttributes(tokenId, ITEM_TYPE_WEAPON, weapons);
        } else if (strcmp(itemType, ITEM_TYPE_CHEST)) {
            return pluckAttributes(tokenId, ITEM_TYPE_CHEST, chestArmor);
        } else if (strcmp(itemType, ITEM_TYPE_HEAD)) {
            return pluckAttributes(tokenId, ITEM_TYPE_HEAD, headArmor);
        } else if (strcmp(itemType, ITEM_TYPE_WAIST)) {
            return pluckAttributes(tokenId, ITEM_TYPE_WAIST, waistArmor);
        } else if (strcmp(itemType, ITEM_TYPE_FOOT)) {
            return pluckAttributes(tokenId, ITEM_TYPE_FOOT, footArmor);
        } else if (strcmp(itemType, ITEM_TYPE_HAND)) {
            return pluckAttributes(tokenId, ITEM_TYPE_HAND, handArmor);
        } else if (strcmp(itemType, ITEM_TYPE_NECK)) {
            return pluckAttributes(tokenId, ITEM_TYPE_NECK, necklaces);
        } else if (strcmp(itemType, ITEM_TYPE_RING)) {
            return pluckAttributes(tokenId, ITEM_TYPE_RING, rings);
        }

        return getMinItemAttributes();
    }

    function getItemName(uint256 tokenId, string memory itemType) internal returns (string memory) {
        if (strcmp(itemType, ITEM_TYPE_WEAPON)) {
            return getWeapon(tokenId);
        } else if (strcmp(itemType, ITEM_TYPE_CHEST)) {
            return getChest(tokenId);
        } else if (strcmp(itemType, ITEM_TYPE_HEAD)) {
            return getHead(tokenId);
        } else if (strcmp(itemType, ITEM_TYPE_WAIST)) {
            return getWaist(tokenId);
        } else if (strcmp(itemType, ITEM_TYPE_FOOT)) {
            return getFoot(tokenId);
        } else if (strcmp(itemType, ITEM_TYPE_HAND)) {
            return getHand(tokenId);
        } else if (strcmp(itemType, ITEM_TYPE_NECK)) {
            return getNeck(tokenId);
        } else if (strcmp(itemType, ITEM_TYPE_RING)) {
            return getRing(tokenId);
        }

        return "";
    }

    function getLootItem(uint256 characterId, string memory itemType) internal view returns (LootItem memory) {
        LootItem memory a = LootItem(1, "", "");
        return a;
    }

    function unwearItem(uint256 characterId, string memory itemType) internal {
        LootItem memory lootItem = getLootItem(characterId, itemType);
        if (lootItem.tokenId == 0) {
            //nothing is there
            return;
        }

        ItemAttributes memory multiplier = getItemMultiplier(lootItem.tokenId, itemType);
        Character storage c = characters[characterId];

        c.attributes.attack /= multiplier.attack;
        c.attributes.defence /= multiplier.defence;
        c.attributes.intelligence /= multiplier.intelligence;
        c.attributes.strength /= multiplier.strength;
        c.attributes.agility /= multiplier.agility;
        c.attributes.magic /= multiplier.magic;
        c.attributes.health /= multiplier.health;

        setItemData(characterId, itemType, 0, "");
    }

    function wearItem(uint256 characterId, uint256 tokenId, string memory itemType) internal {
        ItemAttributes memory multiplier = getItemMultiplier(tokenId, itemType);
        Character storage c = characters[characterId];

        c.attributes.attack *= multiplier.attack;
        c.attributes.defence *= multiplier.defence;
        c.attributes.intelligence *= multiplier.intelligence;
        c.attributes.strength *= multiplier.strength;
        c.attributes.agility *= multiplier.agility;
        c.attributes.health *= multiplier.health;
        c.attributes.magic *= multiplier.magic;

        string memory fullName = getItemName(tokenId, itemType);
        setItemData(characterId, itemType, tokenId, fullName);
    }

    function setItemData(uint256 characterId, string memory itemType, uint256 tokenId, string memory fullName) internal {
        Character storage c = characters[characterId];
        LootItem memory a = LootItem(tokenId, itemType, fullName);

        if (strcmp(itemType, ITEM_TYPE_WEAPON)) {
            c.weapon = a;
        } else if (strcmp(itemType, ITEM_TYPE_CHEST)) {
            c.chest = a;
        } else if (strcmp(itemType, ITEM_TYPE_HEAD)) {
            c.head = a;
        } else if (strcmp(itemType, ITEM_TYPE_WAIST)) {
            c.waist = a;
        } else if (strcmp(itemType, ITEM_TYPE_FOOT)) {
            c.foot = a;
        } else if (strcmp(itemType, ITEM_TYPE_HAND)) {
            c.hand = a;
        } else if (strcmp(itemType, ITEM_TYPE_NECK)) {
            c.neck = a;
        } else if (strcmp(itemType, ITEM_TYPE_RING)) {
            c.ring = a;
        }
    }

    function wear(uint256 characterId, uint256 itemTokenId, string memory itemType) public {
        require(validItemType(itemType), "invalid item type");
        require(itemTokenId > 0 && itemTokenId < 8001, "invalid item tokenId");
        require(ownerOfToken(itemTokenId), "you do not own Loot Bag");

        Character storage c = characters[characterId];
        require(c.owner == _msgSender(), "you do not own this character");

        unwearItem(characterId, itemType);
        wearItem(characterId, itemTokenId, itemType);
    }

    function unwear(uint256 characterId, string memory itemType) public {
        require(validItemType(itemType), "invalid item type");

        Character storage c = characters[characterId];
        require(c.owner == _msgSender(), "you do not own this character");

        unwearItem(characterId, itemType);
    }

    function strcmp(string memory a, string memory b) internal returns (bool) {
        if (bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
        }
    }
}
