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

    function save(uint withdrawTimeStamp) public isValidSaving(withdrawTimeStamp) payable returns (uint value, uint timestamp, uint withdrawTimestamp) {
        uint timeStamp = block.timestamp;
        Saving memory saving = Saving({
             owner:msg.sender,
             value:msg.value,
             timestamp: timeStamp,
             withdrawTimestamp: withdrawTimeStamp
        });
        addressByTimestamp[msg.sender].push(timestamp);
        timeStampBySavings[timeStamp] =  saving;
        return (msg.value, timeStamp, withdrawTimeStamp);
    }

    
}
