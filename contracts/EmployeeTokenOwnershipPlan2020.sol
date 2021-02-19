//SPDX-License-Identifier: Apache2
pragma solidity ^0.7.0;

import "./Claimable.sol";
import "./ERC20.sol";
import "./MathUint.sol";


/// @title EmployeeTokenOwnershipPlan
/// @author Freeman Zhong - <kongliang@loopring.org>
/// added at 2021-02-17
contract EmployeeTokenOwnershipPlan2020 is Claimable
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

        address payable[45] memory _members = [
            0xD984D096B4bF9DCF5fd75D9cBaf052D00EBe74c4,
            0x813C12326A0E8C2aC91d584f025E50072CDb4467,
            0x067eceAd820BC54805A2412B06946b184d11CB4b,
            0xf21e66578372Ea62BCb0D1cDfC070f231CF56898,
            0xD984D096B4bF9DCF5fd75D9cBaf052D00EBe74c4,
            0xDB5C4078eC50Ad4Cdc47F4597a377528B1d7bcdB,
            0x6b1029C9AE8Aa5EEA9e045E8ba3C93d380D5BDDa,
            0x21870650F40Fe8249DECc96525249a43829E9A32,
            0x33CDbeB3e060bf6973e28492BE3D469C05D32786,
            0xe0807d8E14F2BCbF3Cc58637259CCF3fDd1D3ce5,
            0x1F28F10176F89F4E9985873B84d14e75751BB3D1,
            0xad05c57e06a80b8EC92383b3e10Fea0E2b4e571D,
            0x5a03a928b332EC269f68684A8e9c1881b4Da5f3d,
            0xa817c7a0690F17029b756b2EedAA089E0C94c900,
            0xF5E2359644f61cDeEcFbD068294EB0d2ff7Dc706,
            0x41cDd7034AD6b2a5d24397189802048E97b6532D,
            0x7F81D533B2ea31BE2591d89394ADD9A12499ff17,
            0x7154a02BA6eEaB9300D056e25f3EEA3481680f87,
            0xEBE85822e75D2B4716e228818B54154E4AfFD202,
            0xd3725C997B580E36707f73880aC006B6757b5009,
            0xBe4C1cb10C2Be76798c4186ADbbC34356b358b52,
            0x7414eA41bd1844f61e8990b209a1Dc301489baa9,
            0xf493af7DFd0e47869Aac4770B2221a259CA77Ac8,
            0x650EACf9AD1576680f1af6eC6cC598A484d796Ad,
            0xFF6f7B2afdd33671503705098dd3c4c26a0F0705,
            0x4c381276F4847255C675Eab90c3409FA2fce68bC,
            0xBc5F996840118B580C4452440351b601862c5672,
            0x11a8632b5089c6a061760F0b03285e2cC1388E36,
            0xa26cFCeCb07e401547be07eEe26E6FD608f77d1a,
            0x7F6Dd0c1BeB26CFf8ABA5B020E78D7C0Ed54B8Cc,
            0x55634e271BCa62dDFb9B5f7eae19f3Ae94Fb96b7,
            0x10Bd72a6AfbF8860ec90f7aeCdB8e937a758f351,
            0x07A7191de1BA70dBe875F12e744B020416a5712b,
            0x7b3B1F252169Ff83E3E91106230c36bE672aFdE3,
            0x7809D08edBBBC401c430e5D3862a1Fdfcb8094A2,
            0xeB4c50dF06cEb2Ea700ea127eA589A99a3aAe1Ec,
            0x933650184994CFce9D64A9F3Ed14F1Fd017fF89A,
            0x4bA63ac57b45087d03Abfd8E98987705Fa56B1ab,
            0x2234C96681E9533FDfD122baCBBc634EfbafA0F0,
            0xbd860737F32b7a43e197370606f7eb32c5caD347,
            0xaBad5427278F99c9b9393Cc46FDb0Cb4CB6C33f5,
            0x87adb1BEa935649E607f615F41ae8f4cA96566fa,
            0x6D0228303D0608CACc8a262deA95932DCAc12c8D,
            0x49c268e3F2119fCf71f70dF987432689dd4145Ad,
            0x24C08921717bf5C0029e2b8013B70f1D203cCDac
        ];

        uint80[45] memory _amounts = [
            308310 ether,
            453078 ether,
            485991 ether,
            538180 ether,
            573806 ether,
            482910 ether,
            517196 ether,
            330598 ether,
            519363 ether,
            530065 ether,
            470891 ether,
            667795 ether,
            730172 ether,
            750079 ether,
            500053 ether,
            145641 ether,
            775175 ether,
            180661 ether,
            340060 ether,
            398740 ether,
            120010 ether,
            692576 ether,
            384004 ether,
            475260 ether,
            187520 ether,
            150834 ether,
            31254 ether,
            398740 ether,
            435961 ether,
            500972 ether,
            549381 ether,
            561055 ether,
            221724 ether,
            375040 ether,
            425292 ether,
            433972 ether,
            459366 ether,
            501058 ether,
            539577 ether,
            750079 ether,
            824272 ether,
            750083 ether,
            797479 ether,
            1076356 ether,
            162000 ether
        ];

        uint _totalReward = 21502629 ether;
        vestStart = block.timestamp;

        for (uint i = 0; i < _members.length; i++) {
            require(records[_members[i]].rewarded == 0, "DUPLICATED_MEMBER");

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
