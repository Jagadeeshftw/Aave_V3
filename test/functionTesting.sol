// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IPool} from "../src/interfaces/IPool.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IPoolAddressesProvider} from "../src/interfaces/IPoolAddressesProvider.sol";
import {IPoolDataProvider} from "../src/interfaces/IPoolDataProvider.sol";
import {DAI} from "../src/utils/Contants.sol";
contract FunctionTest is Test {
    IPoolAddressesProvider public constant addressProvider =
        IPoolAddressesProvider(
            address(0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e)
        );
    IPoolDataProvider public constant dataProvider =
        IPoolDataProvider(address(0x41393e5e337606dc3821075Af65AeE84D7688CBD));
    IERC20 public constant dai = IERC20(address(DAI));
    IPool public ipool;
    address public constant alice =
        address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public constant bob =
        address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    function setUp() public {
        address poolAddress = addressProvider.getPool();
        ipool = IPool(address(poolAddress));

        deal(address(dai), alice, 1000 * 1e18);
    }

    function test_supply_token() public {
        vm.startPrank(alice);
        dai.approve(address(ipool), 900 * 1e18);
        ipool.supply({
            asset: address(dai),
            amount: 900 * 1e18,
            onBehalfOf: address(alice),
            referralCode: 0
        });
        (address aDAI, , ) = dataProvider.getReserveTokensAddresses(
            address(dai)
        );
        assertEq(IERC20(aDAI).balanceOf(alice), 900 * 1e18);
        assertEq(dai.balanceOf(alice), 100 * 1e18);
        vm.stopPrank();
    }
}
