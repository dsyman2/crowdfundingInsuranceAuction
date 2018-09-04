pragma solidity ^0.4.21;

interface ERC20 {
  function balanceOf(address who) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SealedBidAuction {
    address vendor;

    ERC20 public token;
    uint256 public maxPremium;
    uint256 public T1;
    uint256 public T2;

    constructor(
        ERC20 _token,
        uint256 _maxPremium,
        uint256 biddingTime,
        uint256 revealingTime
    )
        public
    {
        token = _token;
        maxPremium = _maxPremium;

        T1 = now + biddingTime;
        T2 = T1 + revealingTime;

        vendor = msg.sender;
    }

    mapping(address => uint256) public transaction;
    mapping(address => bytes32) public commBidder;
    mapping(address => uint256) public premiumBids;

    function bid(bytes32 comm) public payable {
        require(now < T1);

        commBidder[msg.sender] = comm;
        transaction[msg.sender] = msg.value;
    }

    function reveal(uint256 premium, uint256 secret, uint256 coverage) public {
        require(now >= T1 && now < T2);
        require(premium <= maxPremium);
        require(transaction[msg.sender] == coverage - premium);
        require(keccak256(abi.encodePacked(premium, secret)) == commBidder[msg.sender]);

        premiumBids[msg.sender]= premium;

        }
    }