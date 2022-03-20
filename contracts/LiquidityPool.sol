// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */

import "./ERC20Token.sol";
import "./Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiquidityPool is Ownable {
    address public addrTokenA;
    address public addrTokenB;
    address public addrLiquidityToken;
    uint256 public liquidityTokensMinted;

    constructor(
        address _addrTokenA,
        address _addrTokenB,
        uint256 _reserveTokenA,
        uint256 _reserveTokenB
    ) onlyOwner {
        addrTokenA = _addrTokenA;
        addrTokenB = _addrTokenB;
        liquidityTokensMinted = Math.sqrt(_reserveTokenA * _reserveTokenB);

        string memory symbol = string(
            bytes.concat(
                bytes(ERC20(addrTokenA).symbol()),
                "-",
                bytes(ERC20(addrTokenB).symbol())
            )
        );

        // liquidity tokens sent back to Dex, and eventually to initial creator
        // note: change name to something other than symbol
        ERC20Token liquidityToken = new ERC20Token(
            liquidityTokensMinted,
            symbol,
            symbol
        );
        addrLiquidityToken = address(liquidityToken);
        liquidityToken.transfer(msg.sender, liquidityTokensMinted);
    }

    function mintToken(address _to, uint256 _amount) private {
        ERC20Token(addrLiquidityToken).mintToken(_to, _amount);
    }

    function burnToken(address _to, uint256 _amount) private {
        ERC20Token(addrLiquidityToken).burnToken(_to, _amount);
    }

    function getTokenAReserve() public view returns (uint256) {
        return ERC20Token(addrTokenA).balanceOf(address(this));
    }

    function getTokenBReserve() public view returns (uint256) {
        return ERC20Token(addrTokenB).balanceOf(address(this));
    }

    function getLiquidityTokenAddress() public view returns (address) {
        return addrLiquidityToken;
    }

    // called directly by a person
    function addLiquidity(
        address _addrTokenA,
        address _addrTokenB,
        uint256 _amountTokenA,
        uint256 _amountTokenB
    ) public {
        require(
            _addrTokenA == addrTokenA && _addrTokenB == addrTokenB,
            "Must be the right tokens in correct order"
        );

        uint256 reserveTokenA = getTokenAReserve();
        uint256 reserveTokenB = getTokenBReserve();

        require(
            ERC20Token(addrTokenA).balanceOf(msg.sender) >= _amountTokenA,
            "Token 1 of Pool is not enough"
        );
        require(
            ERC20Token(addrTokenB).balanceOf(msg.sender) >= _amountTokenB,
            "Token 2 of Pool is not enough"
        );
        require(
            reserveTokenA * _amountTokenA == reserveTokenB * _amountTokenB,
            "Must maintain pool ratio"
        );

        // send LP tokens to user
        uint256 morePoolMinted = ((_amountTokenA + _amountTokenB) *
            liquidityTokensMinted) / (reserveTokenA + reserveTokenB);
        mintToken(msg.sender, morePoolMinted);
        liquidityTokensMinted += morePoolMinted;

        // collect TokenA, TokenB
        ERC20Token(_addrTokenA).transferFrom(
            msg.sender,
            address(this),
            _amountTokenA
        );
        ERC20Token(_addrTokenB).transferFrom(
            msg.sender,
            address(this),
            _amountTokenB
        );
    }

    function removeLiquidity(uint256 _amountLiquidityToken) public {
        require(
            ERC20Token(addrLiquidityToken).balanceOf(msg.sender) >=
                _amountLiquidityToken,
            "Sender does not enough LP tokens to burn."
        );

        // LP token is a percentage of the pool, used to calculate reserve tokens on each side to recieve
        uint256 tokenAToSend = (_amountLiquidityToken * getTokenAReserve()) /
            liquidityTokensMinted;
        uint256 tokenBToSend = (_amountLiquidityToken * getTokenBReserve()) /
            liquidityTokensMinted;

        ERC20Token(addrTokenA).transfer(msg.sender, tokenAToSend);
        ERC20Token(addrTokenB).transfer(msg.sender, tokenBToSend);

        // burn LP tokens
        burnToken(msg.sender, _amountLiquidityToken);
        // keep track of burned LP tokens
        liquidityTokensMinted -= _amountLiquidityToken;
    }

    function swap(
        address _addrTokenToBuy,
        address _addrCurrencyBuyingWith,
        uint256 _amount
    ) public {
        uint256 reserveTokenA = getTokenAReserve();
        uint256 reserveTokenB = getTokenBReserve();
        bool buyingTokenA = false;

        require(
            (_addrTokenToBuy == addrTokenA &&
                _addrCurrencyBuyingWith == addrTokenB) ||
                (_addrTokenToBuy == addrTokenB &&
                    _addrCurrencyBuyingWith == addrTokenA),
            "This liquidity pool does not contain the token reserves you're looking for."
        );

        if (_addrTokenToBuy == addrTokenA) {
            buyingTokenA = true;
        }

        // ToDo: implement 0.17% fee of _amount and allocate 50/50 split in value towards pool's reserve

        if (buyingTokenA) {
            uint256 updatedReserveA = (reserveTokenA * reserveTokenB) /
                (reserveTokenB + _amount);
            ERC20Token(addrTokenB).transferFrom(
                msg.sender,
                address(this),
                _amount
            );
            ERC20Token(addrTokenA).transfer(
                msg.sender,
                reserveTokenA - updatedReserveA
            );
        } else {
            uint256 updatedReserveB = (reserveTokenA * reserveTokenB) /
                (reserveTokenA + _amount);
            ERC20Token(addrTokenA).transferFrom(
                msg.sender,
                address(this),
                _amount
            );
            ERC20Token(addrTokenB).transfer(
                msg.sender,
                reserveTokenB - updatedReserveB
            );
        }
    }
}
