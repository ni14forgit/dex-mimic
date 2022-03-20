# dex-mimic

## Applies the Uniswap-V2 protocols.

-   AMM invariant x \* y = k. For x = number of Token A, y = number of token B, constant k.
-   Swap: trade one token for another while maintaining simple v2 AMM invariant
-   Provide Liquidity: Deposit tokens A and B of equal value (determined by the liquidity pool) and earn Liquidity Pool tokens. _ = ((\_amountTokenA + \_amountTokenB) \* liquidityTokensMinted) / (reserveTokenA + reserveTokenB)_
-   Withdraw Liquidity: Burn liquidity pool tokens and receive corresponding percentage of liquidity pool.
-   Initialize pools within the dex if token pairings have not been created, and receive Liquidity Pool tokens. _ = Math.sqrt(\_reserveTokenA \* \_reserveTokenB)_
-   Follows ERC20 standards and OpenZeppelin v4 packages

## Testing

1. Mint 1000 ERC20 TokenA & 1000 ERC20 TokenB.
2. Initialize Liquidity Pool with 200 Token A & 50 Token B
    - Verify earning of 100 Liquidity Pool tokens.
    - Very pool has 200 TokenA and 50 TokenB.
3. Swap 50 Token B for 100 Token B. (100 is calculated by solving _x = 200 \* 50 / (50 + 50)_).
    - Verify liquidity pool has 100 TokenA and 100 TokenB.
    - Verify external contract has 900 TokenA and 900 TokenB.
4. Add liquidity of 20 TokenA and 20 TokenB.
    - Verify pool has 120 TokenA and 120 TokenB.
    - Verify external account has 880TokenA and 880TokenB.
5. Withdraw liquidity of 40 Liquidity Pool Tokens.
    - Verify pool has 80 TokenA and 80 TokenB
    - Verify external account has 80 Liquidity Pool tokens remaining.

## To Add

-   Incorporate fees on trades. Uniswap-v2 implements 0.3% fee that is allocated to the token reserves of the liquidity pool.
-   Minimum liquidity in pool and minimum amount of liquidity contribution to avoid rounding-to-zero errors.
