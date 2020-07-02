/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
pragma solidity ^0.6.6;

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

        startAt = now;
        period = _period;

        for (uint i = 0; i < _members.length; i++) {
            Record memory record = Record(now, _amounts[i], 0);
            records[_members[i]] = record;
        }
    }

    function withdraw()
        external
    {
        Record storage r = records[msg.sender];
        uint amount = r.total.mul(now.sub(r.lastWithdrawTime)) / period;

        r.lastWithdrawTime = now;
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
