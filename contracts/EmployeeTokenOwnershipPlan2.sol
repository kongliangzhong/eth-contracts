//SPDX-License-Identifier: Apache2
pragma solidity ^0.7.0;

import "./Claimable.sol";
import "./ERC20.sol";
import "./MathUint.sol";


/// @title EmployeeTokenOwnershipPlan2
/// added at 2021-02-14
/// @author Freeman Zhong - <kongliang@loopring.org>
contract EmployeeTokenOwnershipPlan2 is Claimable
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

    constructor()
    {
        owner = 0x96f16FdB8Cd37C02DEeb7025C1C7618E1bB34d97;
    }

    function init(uint _totalReward, address[] calldata _members, uint[] calldata _amounts)
        external
        onlyOwner
    {
        require(_members.length == _amounts.length, "DATA_LENGTH_MISMATCH");

        vestStart = block.timestamp;
        for (uint i = 0; i < _members.length; i++) {
            Record memory record = Record(block.timestamp, _amounts[i], 0);
            records[_members[i]] = record;
            totalReward = totalReward.add(_amounts[i]);
        }
        require(_totalReward == totalReward, "VALUE_MISMATCH");

    }

    function withdrawFor(address recipient)
        external
    {
        _withdraw(recipient);
    }

    function vested(address recipient)
        public
        view
        returns(uint)
    {
        return records[recipient].rewarded.mul(block.timestamp.sub(vestStart)) / vestPeriod;
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

    function changeMemberAddress(address oldAddr, address newAddr)
        external
        onlyOwner
    {
        require(newAddr != oldAddr && newAddr != address(0), "INVALID_NEW_ADDRESS");
        Record storage r = records[oldAddr];
        records[newAddr] = r;
        delete records[oldAddr];
        emit MemberAddressChanged(oldAddr, newAddr);
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
