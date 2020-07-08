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

    uint    public constant vestPeriod = 2 * 365 days;
    address public constant lrcAddress = 0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD;

    uint public totalReward;
    uint public vestStart;
    mapping (address => Record) private records;

    event Withdrawal(
        address indexed transactor,
        address indexed member,
        uint            amount
    );

    constructor() public
    {
        owner = 0x96f16FdB8Cd37C02DEeb7025C1C7618E1bB34d97;

        address payable[17] memory _members = [
            0xb18768c26f0922056b3550a24f421618Fe12D126,
            0x2Ff7eD213B4E5Cf813048d3fBC50E77BA80B26B0,
            0xd3725C997B580E36707f73880aC006B6757b5009,
            0x522c9A3e5857a58373F072e127F00F7dac6D6969,
            0x45a98C1B46d8a1D5c4cC52Cc18a4569b27F61939,
            0xBe4C1cb10C2Be76798c4186ADbbC34356b358b52,
            0x8db15c6883B61588C54961f1401CC71C6206Fe38,
            0x6b1029C9AE8Aa5EEA9e045E8ba3C93d380D5BDDa,
            0x95C6E2D5EAD1Aa2a5aAab33d735739c82D623C88,
            0x07A7191de1BA70dBe875F12e744B020416a5712b,
            0x59962c3078852Ff7757babf525F90CDffD3FdDf0,
            0x7154a02BA6eEaB9300D056e25f3EEA3481680f87,
            0x2bbFe5650e9876fb313D6b32352c6Dc5966A7B68,
            0x056757881C358b8E1A3Cc6374f2cb545c587d3FA,
            0x1fcBAb8012177540fb8e121d0073f81219Fc828E,
            0xe865759DF485c11070504e76B900938D2d9A7738,
            0x51cDF96c9b6EC28A0241c4Be433854bd3dc0bc79
        ];

        uint88[17] memory _amounts = [
            1491300 ether,
            1491300 ether,
            1491300 ether,
            1491300 ether,
            1118400 ether,
            1118400 ether,
            1118400 ether,
            1118400 ether,
            1006600 ether,
            1006600 ether,
            560000  ether,
            248500  ether,
            248500  ether,
            5000000 ether,
            5000000 ether,
            5000000 ether,
            5000000 ether
        ];

        uint _totalReward = 33509000 ether;
        vestStart = now;

        for (uint i = 0; i < _members.length; i++) {
            Record memory record = Record(now, _amounts[i], 0);
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
        return vested(recipient).sub(records[recipient].withdrawn);
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

        emit Withdrawal(msg.sender, recipient, amount);
    }

    function collect()
        external
        onlyOwner
    {
        require(now > vestStart + vestPeriod + 60 days, "TOO_EARLY");
        uint amount = ERC20(lrcAddress).balanceOf(address(this));
        require(ERC20(lrcAddress).transfer(msg.sender, amount), "transfer failed");
    }
}
