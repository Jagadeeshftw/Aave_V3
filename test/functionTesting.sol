// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IPool} from "../src/interfaces/IPool.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IPoolAddressesProvider} from "../src/interfaces/IPoolAddressesProvider.sol";
import {IPoolDataProvider} from "../src/interfaces/IPoolDataProvider.sol";
import {DAI} from "../src/utils/Contants.sol";
contract FunctionTest is Test {
    event ReserveUsedAsCollateralEnabled(
        address indexed reserve,
        address indexed user
    );

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

    function supply(address asset, address a, uint amount) public {
        vm.startPrank(a);
        dai.approve(address(ipool), amount);
        vm.expectEmit(true, true, false, false);
        emit ReserveUsedAsCollateralEnabled(asset, address(a));

        ipool.supply({
            asset: address(dai),
            amount: 900 * 1e18,
            onBehalfOf: address(a),
            referralCode: 0
        });
        vm.stopPrank();
    }

    function test_supply_token() public {
        uint256 supply_amount = 900 * 1e18;
        supply(address(dai), alice, supply_amount);
        (address aDAI, , ) = dataProvider.getReserveTokensAddresses(
            address(dai)
        );
        assertEq(IERC20(aDAI).balanceOf(alice), supply_amount);
        assertEq(dai.balanceOf(alice), 100 * 1e18);
        vm.stopPrank();
    }

    function withdraw(address asset, uint256 amount, address to) public {
        vm.prank(alice);
        ipool.withdraw(asset, amount, to);
    }

    function test_withdraw_token() public {
        uint256 supply_amount = 900 * 1e18;
        uint256 withdraw_amount = 800 * 1e18;
        supply(address(dai), alice, supply_amount);
        withdraw(address(dai), withdraw_amount, alice);
        assertEq(
            dai.balanceOf(alice),
            1000 * 1e18 - supply_amount + withdraw_amount
        );
    }
}
