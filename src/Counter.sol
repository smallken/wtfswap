// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;
     uint8[] public intArry;
        //  intArry = [1,3,4,5,6,8];
    

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
         intArry.push(1);
        intArry.push(2);
        intArry.push(3);
        intArry.push(4);
        // intArry[0] = 1;

         uint8[3] memory dynamicArray1 = [1, 2, 3];
        // intArry.pop;
        for (uint i= 0 ; i < intArry.length; i ++) {
            // dynamicArray1.pop();
            intArry.pop;
        }
        for(uint i= 0 ; i < intArry.length; i ++){
            
        }
    }
}
