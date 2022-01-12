//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
// import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

// import { SafeMath } from "./Libraries.sol";

contract StableCoin is 
    ERC20Pausable, 
    Ownable
{
    string public constant TOKEN_NAME = "StableCoin";
    string public constant TOKEN_SYMBOL = "SC";
    uint256 public initialSupply = 10 ** 12 * 10 ** 18;

    mapping(address => bool) internal frozen;

    //event
    event AddressFrozen(address indexed addr);
    event AddressUnfrozen(address indexed addr);
    event FrozenAddressWiped(address indexed addr);
    
    event SupplyIncreased(address indexed to, uint256 value);
    event SupplyDecreased(address indexed from, uint256 value);
    event SupplyControllerSet(
        address indexed oldSupplyController,
        address indexed newSupplyController
    );

    
    constructor() ERC20(TOKEN_NAME, TOKEN_SYMBOL) {
        _mint(_msgSender(), initialSupply);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!frozen[from] && !frozen[to] && !frozen[msg.sender], "address frozen");
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function reclaimBUSD() external onlyOwner {
        uint256 _balance = balanceOf(address(this));
        _transfer(address(this), owner(), _balance);
    }

    function freeze(address _addr) public onlyOwner {
        require(!frozen[_addr], "address already frozen");
        frozen[_addr] = true;
        emit AddressFrozen(_addr);
    }

    function unfreeze(address _addr) public onlyOwner {
        require(frozen[_addr], "address already unfrozen");
        frozen[_addr] = false;
        emit AddressUnfrozen(_addr);
    }

    function wipeFrozenAddress(address _addr) public onlyOwner {
        require(frozen[_addr], "address is not frozen");
        uint256 _balance = balanceOf(_addr);

        _burn(_addr, _balance);
        emit FrozenAddressWiped(_addr);
        emit SupplyDecreased(_addr, _balance);
    }

    function isFrozen(address _addr) public view returns (bool) {
        return frozen[_addr];
    }

    function increaseSupply(uint256 _value) public onlyOwner returns (bool success) {
        _mint(owner(), _value);
        emit SupplyIncreased(owner(), _value);
        return true;
    }

    function decreaseSupply(uint256 _value) public onlyOwner returns (bool success) {
        _burn(owner(), _value);
        emit SupplyDecreased(owner(), _value);
        return true;
    }
}