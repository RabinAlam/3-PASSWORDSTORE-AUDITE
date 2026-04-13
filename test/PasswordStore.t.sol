// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {PasswordStore} from "../src/PasswordStore.sol";
import {DeployPasswordStore} from "../script/DeployPasswordStore.s.sol";

contract PasswordStoreTest is Test {
    PasswordStore public passwordStore;
    address public owner = address(1);
    address public attacker = address(2);
    
    function setUp() public {
        vm.prank(owner);
        passwordStore = new PasswordStore();
    }

    function test_OwnerCanSetPassword() public {
        vm.prank(owner);
        passwordStore.setPassword("newPassword");
    }

    function test_OwnerCanGetPassword() public {
        vm.prank(owner);
        passwordStore.setPassword("mySecret");
        
        vm.prank(owner);
        string memory password = passwordStore.getPassword();
        
        assertEq(password, "mySecret");
    }

    function test_NonOwnerCannotSetPassword() public {
        vm.prank(attacker);
        vm.expectRevert(PasswordStore.PasswordStore__NotOwner.selector);
        passwordStore.setPassword("hacked");
    }

    function test_NonOwnerCannotGetPassword() public {
        vm.prank(owner);
        passwordStore.setPassword("secret");
        
        vm.prank(attacker);
        vm.expectRevert(PasswordStore.PasswordStore__NotOwner.selector);
        passwordStore.getPassword();
    }

    // Vulnerability test: Anyone can read password from storage directly
        function test_PasswordIsInStorageSlot1() public {
        vm.prank(owner);
        passwordStore.setPassword("mySecretPassword");
        
        bytes32 slotValue = vm.load(address(passwordStore), bytes32(uint256(1)));
        
        // Just verify slot is not empty (contains our password data)
        assertTrue(slotValue != bytes32(0), "Password should be stored in slot 1");
        
        // Log the raw bytes to see it
        console.logBytes32(slotValue);
    }

    function test_DeployScriptCoverage() public {
    DeployPasswordStore deployer = new DeployPasswordStore();
    deployer.run();
}
    }
