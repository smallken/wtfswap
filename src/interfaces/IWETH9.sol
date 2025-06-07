pragma solidity ^0.8.13;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function transferFrom(address src, address dst, uint wad) external returns (bool);
}
