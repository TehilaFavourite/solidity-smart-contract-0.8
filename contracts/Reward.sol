// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Allocation is Ownable {

    IERC721 public parentNFT;
    address public admin;
    bool stop;

    struct ClaimEth {
        uint256 amtReward;
        uint256 balance;
        uint256 amtNFT;
        uint256 timestamp;
    }



    mapping(address => ClaimEth) public claimed;

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin can call this function");
        _;
    }


    constructor(address _admin, address _parentNFT) payable {
        parentNFT = IERC721(_parentNFT);
        admin = _admin;
        
    }

    function depositEth() external payable onlyAdmin {
        
    }

    
    function claimEth() external {
        uint256 NFTHeld = 1 ether;
        uint256 calcReward = parentNFT.balanceOf(msg.sender) * NFTHeld;
        require(parentNFT.balanceOf(msg.sender) > 0, "You do not own an NFT");

        require(calcReward < address(this).balance, "no enough Eth in the pool, please wait");

        require(!stop, "Reward has stopped");

        ClaimEth storage _claim = claimed[msg.sender];
        _claim.balance += calcReward;
        payable(msg.sender).transfer(calcReward);
        _claim.amtReward = calcReward;
        _claim.amtNFT = parentNFT.balanceOf(msg.sender);
        _claim.timestamp = block.timestamp;
        

    }

    function stopClaimEth() external onlyAdmin {
        stop = true;
    }

    function AdminWithdrawEth(uint256 amt) external  onlyAdmin {
        require(address(this).balance > 0, "Insufficient Eth");
        payable(msg.sender).transfer(amt);
    }

    function userNFTBal(address _addr) external view returns (uint256) {
        return parentNFT.balanceOf(_addr);
    }

    function getContractBalance() public view onlyAdmin returns (uint) {
        return address(this).balance;
    }




}