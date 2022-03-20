// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./ERC20Token.sol";
import "./LiquidityPool.sol";

contract Dex {
    mapping(address => mapping(address => address)) public liquidityPools;

    function createLiquidityPool(
        address _addrTokenA,
        address _addrTokenB,
        uint256 _initialTokenA,
        uint256 _initialTokenB
    ) public {
        require(
            liquidityPools[_addrTokenA][_addrTokenB] == address(0) &&
                liquidityPools[_addrTokenB][_addrTokenA] == address(0),
            "Liquidity pool already created."
        );

        // check that user has enough tokens
        require(
            ERC20Token(_addrTokenA).balanceOf(msg.sender) >= _initialTokenA,
            "Not enough of token A"
        );
        require(
            ERC20Token(_addrTokenB).balanceOf(msg.sender) >= _initialTokenB,
            "Not enough of token B"
        );

        LiquidityPool nextLiquidityPool = new LiquidityPool(
            _addrTokenA,
            _addrTokenB,
            _initialTokenA,
            _initialTokenB
        );

        // send tokens to liquidityPool
        ERC20Token(_addrTokenA).transferFrom(
            msg.sender,
            address(nextLiquidityPool),
            _initialTokenA
        );
        ERC20Token(_addrTokenB).transferFrom(
            msg.sender,
            address(nextLiquidityPool),
            _initialTokenB
        );

        // transfer LP tokens from this contract to the caller
        ERC20Token liquidityPoolToken = ERC20Token(
            nextLiquidityPool.getLiquidityTokenAddress()
        );
        liquidityPoolToken.transfer(
            msg.sender,
            liquidityPoolToken.balanceOf(address(this))
        );

        require(
            liquidityPoolToken.balanceOf(msg.sender) > 0,
            "LP tokens never recieved by pool creator"
        );

        liquidityPools[_addrTokenA][_addrTokenB] = address(nextLiquidityPool);
        liquidityPools[_addrTokenB][_addrTokenA] = address(nextLiquidityPool);
    }

    // TODO: offer path/chain of swaps across multiple pools in Dex
}
