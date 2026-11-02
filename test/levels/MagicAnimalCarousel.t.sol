// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import {Utils} from "test/utils/Utils.sol";

import {MagicAnimalCarousel} from "src/levels/MagicAnimalCarousel.sol";
import {MagicAnimalCarouselFactory} from "src/levels/MagicAnimalCarouselFactory.sol";
import {Level} from "src/levels/base/Level.sol";
import {Ethernaut} from "src/Ethernaut.sol";

contract TestMagicAnimalCarousel is Test, Utils {
    Ethernaut ethernaut;
    MagicAnimalCarousel instance;

    address payable owner;
    address payable player;

    /*//////////////////////////////////////////////////////////////
                                 HELPERS
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        address payable[] memory users = createUsers(2);

        owner = users[0];
        vm.label(owner, "Owner");

        player = users[1];
        vm.label(player, "Player");

        vm.startPrank(owner);
        ethernaut = getEthernautWithStatsProxy(owner);
        MagicAnimalCarouselFactory factory = new MagicAnimalCarouselFactory();
        ethernaut.registerLevel(Level(address(factory)));
        vm.stopPrank();

        vm.startPrank(player);
        instance = MagicAnimalCarousel(payable(createLevelInstance(ethernaut, Level(address(factory)), 0)));
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                                 TESTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Check the intial state of the level and enviroment.
    function testInit() public {
        vm.startPrank(player);
        assertEq(instance.currentCrateId(), 0);
        assertEq(instance.carousel(0), 1 << 160);
        submitLevelInstance(ethernaut, address(instance));
        assertFalse(submitLevelInstance(ethernaut, address(instance)));
    }
}
