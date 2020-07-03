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


/// @title EmployeeTokenOwnershipPlan
/// @author Freeman Zhong - <kongliang@loopring.org>
contract EmployeeTokenOwnershipPlan is Claimable
{
    using MathUint for uint;

    struct Record {
        uint lastWithdrawTime;
        uint rewarded;
        uint withdrawn;
    }

    uint    public constant vestPeriod = 3 years;
    address public constant lrcAddress = 0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD;

    uint public totalReward;
    uint public vestStart;
    mapping (address => Record) private records;

    event WithdrawnTo(
        address indexed transactor,
        address indexed member,
        uint            amount
    );

    constructor(
        address[]  calldata _members,
        uint[]     calldata _amounts
        )
        public
        Claimable()
    {
        require(_members.length == _amounts.length, "INVALID_PARAMETERS");

        vestStart = now;

        for (uint i = 0; i < _members.length; i++) {
            Record memory record = Record(now, _amounts[i], 0);
            records[_members[i]] = record;
            totalReward = totalReward.add(_amounts[i]);
        }
    }

    function withdrawTo(address recipient)
        external
        onlyOwner
    {
        _withdraw(recipient);
    }

    function withdraw()
        external
    {
        _withdraw(msg.sender);
    }

    function vested(address recipient)
        public
        view
        returns(uint)
    {
        return records[recipient].rewarded.mul(now.sub(vestStart)) / vestPeriod;
    }

    function withdrawable(address recipient)
        internal
        view
        returns(uint)
    {
        return vested(recipient).sub([records].withdrawn);
    }

    function _withdraw(address recipient)
        internal
    {
        uint amount = withdrawable(recipient);
        require(amount > 0, "INVALID_AMOUNT");

        Record storage r = records[recipient];
        r.lastWithdrawTime = now;
        r.withdrawn = r.withdrawn.add(amount);

        require(ERC20(lrcAddress).transfer(recipient, amount), "transfer failed");

        emit WithdrawnTo(msg.sender, recipient, amount);
    }
}
