# dex-mimic

## Applies the [Uniswap-V2 protocol](https://uniswap.org/whitepaper.pdf).

-   AMM invariant _x \* y = k_. For x = count of TokenA, y = count of TokenB, constant k.
-   Swap: trade one token for another while maintaining Uniswap-v2 AMM invariant.
-   Provide liquidity: deposit TokenA and TokenB of equal value (determined by the liquidity pool) and earn liquidity pool tokens equal to _((\_amountTokenA + \_amountTokenB) \* liquidityTokensMinted) / (reserveTokenA + reserveTokenB)_.
-   Withdraw liquidity: burn liquidity pool tokens and receive corresponding percentage of liquidity pool.
-   Initialize pools within the dex if token pairings have not been created, and receive liquidity pool tokens equal to _Math.sqrt(\_reserveTokenA \* \_reserveTokenB)_
-   Follows ERC20 standards and uses OpenZeppelin v4 ERC20, Ownable contracts.

## Testing

-   [x] Mint 1000 ERC20 TokenA & 1000 ERC20 TokenB from ERC20Token contract.
-   [x] Initialize liquidity pool with 200 TokenA & 50 TokenB
    -   Verify earning of 100 liquidity pool tokens.
    -   Verify pool has 200 TokenA and 50 TokenB.
-   [x] Swap 50 TokenB for 100 TokenA. (100 is calculated from _200 \* 50 / (50 + 50)_.
    -   Verify liquidity pool has 100 TokenA and 100 TokenB.
    -   Verify external contract has 900 TokenA and 900 TokenB.
-   [x] Add liquidity of 20 TokenA and 20 TokenB.
    -   Verify pool has 120 TokenA and 120 TokenB.
    -   Verify external account has 880 TokenA and 880 TokenB.
-   [x] Burn 40 liquidity pool tokens (withdraw liquidity).
    -   Verify pool has 80 TokenA and 80 TokenB
    -   Verify external account has 80 liquidity pool tokens, 920 TokenA, 920 TokenB.

## To Add

-   [ ] Incorporate fees on trades. Uniswap-v2 implements 0.3% fee that is allocated to the token reserves of the liquidity pool.
-   [ ] Maintain minimum liquidity within pool and minimum contribution/withdraw amounts to avoid rounding-to-zero errors.
