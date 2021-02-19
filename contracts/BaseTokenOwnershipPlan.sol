//SPDX-License-Identifier: Apache2
pragma solidity ^0.7.0;

import "./Claimable.sol";
import "./ERC20.sol";
import "./MathUint.sol";


/// @title EmployeeTokenOwnershipPlan
/// @author Freeman Zhong - <kongliang@loopring.org>
/// added at 2021-02-19
abstract contract BaseTokenOwnershipPlan is Claimable
{
    using MathUint for uint;

    struct Record {
        uint lastWithdrawTime;
        uint rewarded;
        uint withdrawn;
    }

    uint    public constant vestPeriod = 2 * 365 days;
    address public constant lrcAddress = 0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD;

    uint public totalReward;
    uint public vestStart;
    mapping (address => Record) public records;

    event Withdrawal(
        address indexed transactor,
        address indexed member,
        uint            amount
    );
    event MemberAddressChanged(
        address oldAddress,
        address newAddress
    );

    function withdrawFor(address recipient)
        external
    {
        _withdraw(recipient);
    }

    function updateRecipient(address newRecipient)
        external
    {
        require(newRecipient != address(0), "INVALID_ADDRESS");
        require(records[newRecipient].rewarded == 0, "INVALID_NEW_RECIPIENT");

        Record storage r = records[msg.sender];
        require(r.rewarded > 0, "INVALID_SENDER");

        records[newRecipient] = r;
        delete records[msg.sender];
        emit MemberAddressChanged(msg.sender, newRecipient);
    }

    function vested(address recipient)
        public
        view
        returns(uint)
    {
        if (block.timestamp.sub(vestStart) < vestPeriod) {
            return records[recipient].rewarded.mul(block.timestamp.sub(vestStart)) / vestPeriod;
        } else {
            return records[recipient].rewarded;
        }
    }

    function withdrawable(address recipient)
        public
        view
        returns(uint)
    {
        return vested(recipient).sub(records[recipient].withdrawn);
    }

    function _withdraw(address recipient)
        internal
    {
        uint amount = withdrawable(recipient);
        require(amount > 0, "INVALID_AMOUNT");

        Record storage r = records[recipient];
        r.lastWithdrawTime = block.timestamp;
        r.withdrawn = r.withdrawn.add(amount);

        require(ERC20(lrcAddress).transfer(recipient, amount), "transfer failed");

        emit Withdrawal(msg.sender, recipient, amount);
    }

    receive() external payable {
        require(msg.value == 0, "INVALID_VALUE");
        _withdraw(msg.sender);
    }

    function collect()
        external
        onlyOwner
    {
        require(block.timestamp > vestStart + vestPeriod + 60 days, "TOO_EARLY");
        uint amount = ERC20(lrcAddress).balanceOf(address(this));
        require(ERC20(lrcAddress).transfer(msg.sender, amount), "transfer failed");
    }
}
