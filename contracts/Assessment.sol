// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Assessment {
    address payable public owner;
    uint256 public balance;
    mapping(address => bool) public isConnected;
    uint256 public connectedAccountsCount;

    event Deposit(uint256 amount);
    event Withdraw(uint256 amount);
    event TransferBalance(address indexed recipient, uint256 amount);

    constructor(uint initBalance) payable {
        owner = payable(msg.sender);
        balance = initBalance;
        isConnected[msg.sender] = true; // Connect the contract deployer by default
        connectedAccountsCount = 1; // Initialize the count with one connected account-145
    }

    function getBalance() public view returns (uint256) {
        return balance;
    }

    function deposit(uint256 _amount) public payable {
        uint256 _previousBalance = balance;

        // make sure this is the owner
        require(msg.sender == owner, "You are not the owner of this account");

        // perform transaction
        balance += _amount;

        // assert transaction completed successfully
        assert(balance == _previousBalance + _amount);

        // emit the event
        emit Deposit(_amount);
    }

    // custom error
    error InsufficientBalance(uint256 balance, uint256 withdrawAmount);

    function withdraw(uint256 _withdrawAmount) public {
        require(msg.sender == owner, "You are not the owner of this account");
        uint256 _previousBalance = balance;
        if (balance < _withdrawAmount) {
            revert InsufficientBalance({
                balance: balance,
                withdrawAmount: _withdrawAmount
            });
        }

        // withdraw the given amount
        balance -= _withdrawAmount;

        // assert the balance is correct
        assert(balance == (_previousBalance - _withdrawAmount));

        // emit the event
        emit Withdraw(_withdrawAmount);
    }

    function transferBalance(address _recipient, uint256 _amount) public {
        require(msg.sender == owner, "You are not the owner of this account");
        require(_amount <= balance, "Insufficient balance for transfer");

        balance -= _amount;
        payable(_recipient).transfer(_amount);

        emit TransferBalance(_recipient, _amount);
    }

    function isContractOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    function connectAccount(address _account) public {
        require(isConnected[_account] == false, "Account is already connected");
        isConnected[_account] = true;
        connectedAccountsCount++;
    }

    function disconnectAccount(address _account) public {
        require(isConnected[_account] == true, "Account is not connected");
        isConnected[_account] = false;
        connectedAccountsCount--;
    }

    function getConnectedAccountsCount() public view returns (uint256) {
        return connectedAccountsCount;
    }
}