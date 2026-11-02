// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Utils} from "test/utils/Utils.sol";

import {ImpersonatorTwo} from "src/levels/ImpersonatorTwo.sol";
import {ImpersonatorTwoFactory} from "src/levels/ImpersonatorTwoFactory.sol";
import {Level} from "src/levels/base/Level.sol";
import {Ethernaut} from "src/Ethernaut.sol";

contract TestImpersonatorTwo is Test, Utils {
    Ethernaut ethernaut;
    ImpersonatorTwo instance;

    address payable initializer;
    address payable player;

    /*//////////////////////////////////////////////////////////////
                                 HELPERS
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        address payable[] memory users = createUsers(2);

        initializer = users[0];
        vm.label(initializer, "Initializer");

        player = payable(address(0xF16989b7A9970Ac3a117Ad45b5eCEa6CEF31f208));
        vm.deal(player, 5 ether);
        vm.label(player, "Player");

        vm.startPrank(initializer);
        ethernaut = getEthernautWithStatsProxy(initializer);
        ImpersonatorTwoFactory factory = new ImpersonatorTwoFactory();
        ethernaut.registerLevel(Level(address(factory)));
        vm.stopPrank();

        vm.startPrank(player);
        instance = ImpersonatorTwo(payable(createLevelInstance(ethernaut, Level(address(factory)), 0.001 ether)));
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                                 TESTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Check the initial state of the level and environment.
    function testInit() public {
        vm.startPrank(player);
        assertFalse(submitLevelInstance(ethernaut, address(instance)));
    }
}
