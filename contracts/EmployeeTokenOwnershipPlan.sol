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
    mapping (address => Record) public records;

    event Withdrawal(
        address indexed transactor,
        address indexed member,
        uint            amount
    );

    constructor() public
    {
        owner = 0x96f16FdB8Cd37C02DEeb7025C1C7618E1bB34d97;

        address payable[28] memory _members = [
            0x056757881C358b8E1A3Cc6374f2cb545c587d3FA,
            0x1fcBAb8012177540fb8e121d0073f81219Fc828E,
            0xe865759DF485c11070504e76B900938D2d9A7738,
            0x51cDF96c9b6EC28A0241c4Be433854bd3dc0bc79,
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
            0xb63b22f3ddcc7f469bcb757a5b64a3848f4c4f03,
            0x6087bfe868d52b15399d06b16742214c1ca722ac,
            0x3AC6061A50b8145b54b76Be9CF485c80DFF20589,
            0x8d26A876917e79916E70e23b34A23aC91EC5E591,
            0xebFF93D8ac49C037519e84a075bf231023224ddC,
            0x63830F62C44BE28703B66e5679A42eBED1d48C8a,
            0x0C3499a325B47b5950F731263fEA144AC95f6bbb,
            0x64F2741920b7df046b7fE8df2e6b0bEad2452bea,
            0x4f90c157CdA2856dB9780BafE13ccECB569cC74a,
            0x2a14Ae2411B6D681c48781037F15f2610034ebFb,
            0xd888B723b8C6BBA8b27ea9B0690094B3b564F618
        ];

        uint88[28] memory _amounts = [
            // pool 2 + pool 1 + special
            (5000000 + 2209239) ether,
            (5000000 +  441848) ether,
            (5000000 +       0) ether,
            (5000000 + 1767391) ether,
            (1491300 + 1546467) ether,
            (1491300 + 1215081) ether,
            (1491300 +  883696) ether,
            (1491300 +       0) ether,
            (1118400 +  883696) ether,
            (1118400 +  883696) ether,
            (1118400 +  331386) ether,
            (1118400 +       0) ether,
            (1006600 + 1546467 + 300000) ether,
            (1006600 +  441848) ether,
            ( 560000 +  331386) ether,
            ( 248500 +  191099) ether,
            ( 248500 +       0) ether,
            (      0 + 1325543) ether,
            (      0 + 1104619) ether,
            (      0 +  441848) ether,
            (      0 +  331386) ether,
            (      0 +  331386) ether,
            (      0 +  331386) ether,
            (      0 +  331386) ether,
            (      0 +  331386) ether,
            (      0 +  331386) ether,
            (      0 +  110462) ether,
            (      0 + 4546912) ether
        ];

        uint _totalReward = 56000000 ether;
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
