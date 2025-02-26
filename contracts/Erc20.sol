// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Erc20 {

    string public name;
    string public symbol;
    uint8 public immutable decimals;
    address public immutable owner;

    uint256 private _totalSupply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    error InvalidAddress();
    error InsufficientFunds();
    error InsufficientAllowance();
    error OnlyOwnerAllowed();
    error InvalidAmount();

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Minted(address indexed _to, uint256 _value);

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwnerAllowed();
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;

        _totalSupply = initialSupply * (10 ** uint256(decimals));
        balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        if (_owner == address(0)) revert InvalidAddress();
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (_to == address(0)) revert InvalidAddress();
        if (_value > balances[msg.sender]) revert InsufficientFunds();

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (_from == address(0) || _to == address(0)) revert InvalidAddress();
        if (_value > balances[_from]) revert InsufficientFunds();
        if (_value > allowances[_from][msg.sender]) revert InsufficientAllowance();

        balances[_from] -= _value;
        allowances[_from][msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (_spender == address(0)) revert InvalidAddress();
        if (_value > balances[msg.sender]) revert InsufficientFunds();

        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    function mint(address _to, uint256 _value) public onlyOwner returns (bool success) {
        if (_to == address(0)) revert InvalidAddress();
        if (_value <= 0) revert InvalidAmount();

        _totalSupply += _value;
        balances[_to] += _value;

        emit Minted(_to, _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }

}
