// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract LockSave {
    struct Saving {
        address owner;
        uint value;
        uint timestamp;
        uint withdrawTimestamp;
    }

    mapping(address => uint[]) private addressByTimestamp;
    mapping(uint => Saving) private timeStampBySavings;

    error UnauthorizedAmount(uint amount, address sender);
    error UnauthorizedWithdrawTime(uint withdrawTimestamp, address sender);
    error NoSavingsFound(address sender);
    error withdrawalFailed(address sender);

    modifier isValidSaving(uint withdrawTimeStamp) {
        if (msg.value < 1) {
            revert UnauthorizedAmount(msg.value, msg.sender);
        }
        if (withdrawTimeStamp < block.timestamp) {
            revert UnauthorizedWithdrawTime({
                withdrawTimestamp: withdrawTimeStamp,
                sender: msg.sender
            });
        }
        _;
    }

    function save(uint withdrawTimeStamp)
        public
        payable
        isValidSaving(withdrawTimeStamp)
        returns (
            uint value,
            uint timestamp,
            uint withdrawTimestamp
        )
    {
        uint timeStamp = block.timestamp;
        Saving memory saving = Saving({
            owner: msg.sender,
            value: msg.value,
            timestamp: timeStamp,
            withdrawTimestamp: withdrawTimeStamp
        });
        addressByTimestamp[msg.sender].push(timestamp);
        timeStampBySavings[timeStamp] = saving;
        return (msg.value, timeStamp, withdrawTimeStamp);
    }

    modifier hasSavings() {
        if (addressByTimestamp[msg.sender].length < 1) {
            revert NoSavingsFound(msg.sender);
        }
        _;
    }
    modifier isWithDrawTime(uint timeStamp) {
        Saving memory saving = timeStampBySavings[timeStamp];
        if(saving.owner == msg.sender && saving.withdrawTimestamp >= block.timestamp) {
            _;
        }
        else {
            revert UnauthorizedWithdrawTime(saving.withdrawTimestamp, msg.sender);
        }
    }
}
