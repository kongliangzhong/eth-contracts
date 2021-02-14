//SPDX-License-Identifier: Apache2
pragma solidity ^0.7.0;

import "./Claimable.sol";
import "./ERC20.sol";
import "./MathUint.sol";


/// @title LockBox
/// @author Freeman Zhong - <kongliang@loopring.org>
contract LockBox is Claimable
{
    using MathUint for uint;

    struct Record {
        uint lastWithdrawTime;
        uint total;
        uint withdrawed;
    }

    uint public startAt;
    uint public period;
    mapping (address => Record) public records;

    address public lrcAddress;

    event Withdrawal(address member, uint amount);
    event WithdrawalByOwner(address member, uint amount);

    function setup(
        address _lrcAddress,
        uint _period,
        address[] calldata _members,
        uint[] calldata _amounts
        )
        external
        onlyOwner
    {
        require(period == 0, "ALREADY_INITIALIZED");
        require(
            _period > 0 &&
            _lrcAddress != address(0) &&
            _members.length == _amounts.length,
            "INVALID_PARAMETERS"
        );

        lrcAddress = _lrcAddress;

        startAt = block.timestamp;
        period = _period;

        for (uint i = 0; i < _members.length; i++) {
            Record memory record = Record(block.timestamp, _amounts[i], 0);
            records[_members[i]] = record;
        }
    }

    function withdraw()
        external
    {
        Record storage r = records[msg.sender];
        uint amount = r.total.mul(block.timestamp.sub(r.lastWithdrawTime)) / period;

        r.lastWithdrawTime = block.timestamp;
        r.withdrawed = r.withdrawed.add(amount);

        require(ERC20(lrcAddress).transfer(msg.sender, amount), "transfer failed");

        emit Withdrawal(msg.sender, amount);
    }

    function withdrawToByOwner(address recipient, uint amount)
        external
        onlyOwner
    {
        require(ERC20(lrcAddress).transfer(recipient, amount), "transfer failed");
        emit WithdrawalByOwner(recipient, amount);
    }

}
