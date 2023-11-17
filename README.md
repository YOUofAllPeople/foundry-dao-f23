# Foundry DAO Governance

Building a DAO and Governance Token with Foundry & OpenZeppelin

1. We are going to have a contract controlled by a DAO
2. Every transaction that the DAO wants to send has to be voted on
3. We will use ERC20 tokens for voting (Bad model, please research better models in the future!)

(Please note: ERC20 based voting is not always recommended, and I encourage you to explore other forms of governance like reputation based or "skin-in-the-game" based)

(This is a section of the Cyfrin Foundry Solidity Course)

[One of my favorite articles on money-based voting being bad](https://vitalik.ca/general/2018/03/28/plutocracy.html)

# Getting Started

## Requirements

-   [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
    -   You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
-   [foundry](https://getfoundry.sh/)
    -   You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

## Quickstart

```
git clone https://github.com/Cyfrin/foundry-dao-f23
cd foundry-dao-f23
forge install
forge build
```

### Optional Gitpod

If you can't or don't want to run and install locally, you can work with this repo in Gitpod. If you do this, you can skip the `clone this repo` part.

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#github.com/PatrickAlphaC/foundry-dao-f23)

# Usage

## Test

```
forge test
```

## Deploy

I did not write deploy scripts for this project, you can if you'd like!

## Estimate gas

You can estimate how much gas things cost by running:

```
forge snapshot
```

And you'll see and output file called `.gas-snapshot`

# Formatting

To run code formatting:

```
forge fmt
```
