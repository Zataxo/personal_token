// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
// Token Design
// 1 - Intial Supply -> 5M intial supply done
// 2 - Max Supply -> Set it to 10M
// 3 - Minting Strategy
// 4 - Block reward -> set in the constructor
// 5 - Burnable
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract TestToken is ERC20Capped, ERC20Burnable {
    address payable public owner;
    uint public blockReward;

    constructor(
        uint _maxSupply,
        uint _reward
    ) ERC20("ZataxToken", "ZTX") ERC20Capped(_maxSupply * (10 ** decimals())) {
        owner = payable(msg.sender);
        _mint(msg.sender, 5000000 * (10 ** decimals()));
        blockReward = _reward * (10 ** decimals());
    }

    // overriding mint function cuz its defined in two inheirted contracts
    function _mint(
        address account,
        uint256 amount
    ) internal override(ERC20Capped, ERC20) {
        require(
            ERC20.totalSupply() + amount <= cap(),
            "ERC20Capped: cap exceeded"
        );
        super._mint(account, amount);
    }

    // function for minting the miner the block reward he inculded in the blockchain
    function _mintMinerReward() internal {
        _mint(block.coinbase, blockReward);
    }

    // function to check before transfering miner reward
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint _value
    ) internal virtual override {
        if (
            _from == address(0) &&
            _to != block.coinbase &&
            block.coinbase != address(0)
        ) {
            _mintMinerReward();
        }
        super._beforeTokenTransfer(_from, _to, _value);
    }

    // function for setting up the block reward
    function setBlockReward(uint _reward) public onlyOwner {
        blockReward = _reward * (10 ** decimals());
    }

    // function to destroy the token (in case u need it)
    function destroy() public onlyOwner {
        selfdestruct(owner); // selfdestruct is deprecated but you can still use it , but not for a long
    }

    // modifer to restrict function excution to be only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }
}
